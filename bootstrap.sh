#!/usr/bin/env bash

# Save trace setting
XTRACE=$(set +o | grep xtrace)
set -o xtrace

#
# Bootstrap script to configure all nodes.
#
# This script is intended to be used by vagrant to provision nodes.
# To use it, set it as 'PROVISION_SCRIPT' inside your Vagrantfile.custom.
# You can use Vagrantfile.custom.example as a template for this.

VM=$1
MODE=$2
PANDA_PATH=$3
GUEST_USER=$4

export http_proxy=
export https_proxy=

if [ "$MODE" = 'aio' ]; then
    # Run registry on port 4000 since it may collide with keystone when doing AIO
    REGISTRY_PORT=4000
else
    REGISTRY_PORT=5000
fi
REGISTRY_URL="operator.local"
REGISTRY=${REGISTRY_URL}:${REGISTRY_PORT}
ADMIN_PROTOCOL="http"

function _ensure_lsb_release {
    if [[ -x $(type lsb_release 2>/dev/null) ]]; then
        return
    fi

    if [[ -x $(type apt-get 2>/dev/null) ]]; then
        apt-get -y install lsb-release
    elif [[ -x $(type yum 2>/dev/null) ]]; then
        yum -y install redhat-lsb-core
    fi
}

function _is_distro {
    if [[ -z "$DISTRO" ]]; then
        _ensure_lsb_release
        DISTRO=$(lsb_release -si)
    fi

    [[ "$DISTRO" == "$1" ]]
}

function is_ubuntu {
    _is_distro "Ubuntu"
}

function is_centos {
    _is_distro "CentOS"
}

# Install common packages and do some prepwork.
function prep_work {
    if [[ "$(systemctl is-enabled firewalld)" = "enabled" ]]; then
        systemctl stop firewalld
        systemctl disable firewalld
    fi

    # This removes the fqdn from /etc/hosts's 127.0.0.1. This name.local will
    # resolve to the public IP instead of localhost.
    sed -i -r "s,^127\.0\.0\.1\s+.*,127\.0\.0\.1   localhost localhost.localdomain localhost4 localhost4.localdomain4," /etc/hosts

    if is_centos; then
        yum -y install epel-release
        rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
        yum -y install MySQL-python vim-enhanced python-pip python-devel gcc openssl-devel libffi-devel libxml2-devel libxslt-devel libvirt-bin libvirt-dev python-libvirt qemu
    elif is_ubuntu; then
        apt-get update
        apt-get -y install vim python-mysqldb python-pip python-dev build-essential libssl-dev libffi-dev libxml2-dev libxslt-dev apt-transport-https libvirt-bin libvirt-dev python-libvirt qemu tmux
    else
        echo "Unsupported Distro: $DISTRO" 1>&2
        exit 1
    fi

    pip install --upgrade pip docker-py graphviz gitpython
}

# Do some cleanup after the installation of panda
function cleanup {
    if is_centos; then
        yum clean all
    elif is_ubuntu; then
        apt-get clean
    else
        echo "Unsupported Distro: $DISTRO" 1>&2
        exit 1
    fi
}

# Install and configure a quick&dirty docker daemon.
function install_docker {
    if is_centos; then
        cat >/etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
        # Also upgrade device-mapper here because of:
        # https://github.com/docker/docker/issues/12108
        # Upgrade lvm2 to get device-mapper installed
        yum -y install docker-engine lvm2 device-mapper

        # Despite it shipping with /etc/sysconfig/docker, Docker is not configured to
        # load it from it's service file.
        sed -i -r "s|(ExecStart)=(.+)|\1=/usr/bin/docker daemon --insecure-registry ${REGISTRY} --registry-mirror=http://${REGISTRY}|" /usr/lib/systemd/system/docker.service
        sed -i 's|^MountFlags=.*|MountFlags=shared|' /usr/lib/systemd/system/docker.service

    elif is_ubuntu; then
        apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
        if [ $? -ne 0 ]; then
	    echo "Try from a different pgp key source"
            apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
	fi
	echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list
	apt-get update
	apt-get -y install docker-engine
	# sed -i -r "s,(ExecStart)=(.+),\1=/usr/bin/docker daemon --insecure-registry ${REGISTRY} --registry-mirror=http://${REGISTRY}|" /lib/systemd/system/docker.service
	rm -rf /lib/systemd/system/docker.service
	echo "[Service]" > /lib/systemd/system/docker.service
	echo "ExecStart=/usr/bin/docker daemon --insecure-registry ${REGISTRY} --registry-mirror=http://${REGISTRY}" >> /lib/systemd/system/docker.service
    else
        echo "Unsupported Distro: $DISTRO" 1>&2
        exit 1
    fi
    usermod -aG docker $GUEST_USER

    if [[ "${http_proxy}" != "" ]]; then
        mkdir -p /etc/systemd/system/docker.service.d
        cat >/etc/systemd/system/docker.service.d/http-proxy.conf <<-EOF
[Service]
Environment="HTTP_PROXY=${http_proxy}" "HTTPS_PROXY=${https_proxy}" "NO_PROXY=localhost,127.0.0.1,${REGISTRY_URL}"
EOF

        if [[ "$(grep http_ /etc/bashrc)" == "" ]]; then
            echo "export http_proxy=${http_proxy}" >> /etc/bashrc
            echo "export https_proxy=${https_proxy}" >> /etc/bashrc
        fi
    fi

    systemctl daemon-reload
    systemctl enable docker
    systemctl restart docker
}

function configure_panda {
    # Use local docker registry
    sed -i -r "s,^[# ]*namespace *=.+$,namespace = ${REGISTRY}/lopanda," /etc/panda/panda-build.conf
    sed -i -r "s,^[# ]*push *=.+$,push = True," /etc/panda/panda-build.conf
    sed -i -r "s,^[# ]*docker_registry:.+$,docker_registry: \"${REGISTRY}\"," /etc/panda/globals.yml
    sed -i -r "s,^[# ]*docker_namespace:.+$,docker_namespace: \"lopanda\"," /etc/panda/globals.yml
    sed -i -r "s,^[# ]*docker_insecure_registry:.+$,docker_insecure_registry: \"True\"," /etc/panda/globals.yml
    # Set network interfaces
    sed -i -r "s,^[# ]*network_interface:.+$,network_interface: \"eth1\"," /etc/panda/globals.yml
    sed -i -r "s,^[# ]*neutron_external_interface:.+$,neutron_external_interface: \"eth2\"," /etc/panda/globals.yml
    # Set VIP address to be on the vagrant private network
}

# Configure the operator node and install some additional packages.
function configure_operator {
    if is_centos; then
        yum -y install git mariadb
    elif is_ubuntu; then
        apt-get -y install git mariadb-client selinux-utils emacs24-nox
    else
        echo "Unsupported Distro: $DISTRO" 1>&2
        exit 1
    fi

    pip install --upgrade "ansible>=2" python-openstackclient python-neutronclient tox

    ${PANDA_PATH}/install-me

    # Set selinux to permissive
    if [[ "$(getenforce)" == "Enforcing" ]]; then
        sed -i -r "s,^SELINUX=.+$,SELINUX=permissive," /etc/selinux/config
        setenforce permissive
    fi

    tox -c ${PANDA_PATH}/tox.ini -e genconfig
    cp -r ${PANDA_PATH}/etc/panda/ /etc/panda
    # ${PANDA_PATH}/tools/generate_passwords.py
    mkdir -p /usr/share/panda
    chown -R $GUEST_USER:$GUEST_USER /etc/panda /usr/share/panda

    configure_panda

    # Make sure Ansible uses scp.
    cat > /home/$GUEST_USER/.ansible.cfg <<EOF
[defaults]
forks=100
remote_user = root
inventory = /usr/local/share/panda/ansible/inventory/multinode

[ssh_connection]
scp_if_ssh=True
EOF
    chown $GUEST_USER:$GUEST_USER /home/$GUEST_USER/.ansible.cfg

    cat > /etc/libvirt/libvirtd.conf <<EOF
[libvirt]
virt_type=qemu
EOF

    # Launch a local registry (and mirror) to speed up pulling images.
    if [[ ! $(docker ps -a -q -f name=registry) ]]; then
        docker run -d \
            --name registry \
            --restart=always \
            -p ${REGISTRY_PORT}:5000 \
            -e STANDALONE=True \
            -e MIRROR_SOURCE=https://registry-1.docker.io \
            -e MIRROR_SOURCE_INDEX=https://index.docker.io \
            -e STORAGE_PATH=/var/lib/registry \
            -v /data/host/registry-storage:/var/lib/registry \
            registry:2
    fi
}

prep_work
install_docker

if is_centos; then
    yum -y install git emacs
elif is_ubuntu; then
    apt-get -y install git emacs24-nox tcpdump tcptrace # zfsutils-linux
else
    echo "Unsupported Distro: $DISTRO" 1>&2
    exit 1
fi

if [[ "$VM" = "operator" ]]; then
    configure_operator
fi

# This function creates a linux bridge br_name and adds a physical interface
# iface to the bridge.
function configure_genesis_br {
    br_name=$1
    iface=$2

    ip=$(ip addr show ${iface} | awk '$1=="inet"{print$2}')

    if route | grep default | grep -q $iface; then
	changeGateway=True
	gatewayIP=`route | grep default | awk '{print $2}'`
    fi

    brctl addbr $br_name
    brctl addif $br_name $iface
    ip link set $br_name up

    ip addr del $ip dev $iface
    ip addr add $ip dev $br_name

    # NOTE(huikang): setup the default gateway if necessary
    if [ "$changeGateway" == "True" ] ; then
	route add default gw $gatewayIP dev $br_name
    fi
}

# Genesis uses a default Linux bridge named br_control
configure_genesis_br br_control eth2
configure_genesis_br br_pub eth0

cleanup

virsh net-destroy default
virsh net-undefine default
/etc/init.d/libvirt-bin stop
# Disable apparmor around libvirtd for now
for apparmor in /etc/apparmor.d/usr.lib.libvirt.virt-aa-helper /etc/apparmor.d/usr.sbin.libvirtd
do
    if [ -e $apparmor ]
    then
        ln -s $apparmor /etc/apparmor.d/disable/
        apparmor_parser -R $apparmor
    fi
done

/etc/init.d/virtlogd stop
/etc/init.d/virtlockd stop

# Restore xtrace
$XTRACE
