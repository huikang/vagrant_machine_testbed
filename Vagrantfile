# -*- mode: ruby -*-
# vi: set ft=ruby :

require "ipaddr"

# Check for required plugin(s)
['vagrant-hostmanager'].each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    raise "#{plugin} plugin not found. Please install it via 'vagrant plugin install #{plugin}'"
  end
end

class VagrantConfigMissing < StandardError
end

vagrant_dir = File.expand_path(File.dirname(__FILE__))

# Vagrantfile.custom contains user customization for the Vagrantfile
# You shouldn't have to edit the Vagrantfile, ever.
if File.exists?(File.join(vagrant_dir, 'Vagrantfile.custom'))
  eval(IO.read(File.join(vagrant_dir, 'Vagrantfile.custom')), binding)
end

# Either libvirt or virtualbox
PROVIDER ||= "libvirt"
# Either centos or ubuntu
DISTRO ||= "ubuntu"

# The libvirt graphics_ip used for each guest. Only applies if PROVIDER
# is libvirt.
GRAPHICSIP ||= "127.0.0.1"

# Either ubuntu or vagrant, depends on provider or VM disk
GUEST_USER ||= "vagrant"

SECOND_DISK_CONTROLLER ||= "SCSI Controller"
SECOND_DISK_SIZE ||= 20

# The bootstrap.sh provision_script requires CentOS 7 or Ubuntu 15.10.
# Provisioning other boxes than the default ones may therefore
# require changes to bootstrap.sh.
PROVISION_SCRIPT ||= "bootstrap.sh"

PROVIDER_DEFAULTS ||= {
  libvirt: {
    centos: {
      base_image: "centos/7",
      base_image_url: nil,
      base_image_version: nil,
      bridge_interface: "virbr0",
      vagrant_shared_folder: "/home/%s/sync" % GUEST_USER,
      sync_method: "nfs",
      panda_path: "/home/%s/panda" % GUEST_USER
    },
    ubuntu: {
      base_image: "carlb/xenial64-panda-libvirt",
      base_image_url: nil,
      base_image_version: nil,
      bridge_interface: "virbr0",
      vagrant_shared_folder: "/home/%s/sync" % GUEST_USER,
      sync_method: "nfs",
      panda_path: "/home/%s/panda" % GUEST_USER
    }
  },
  virtualbox: {
    centos: {
      base_image: "puppetlabs/centos-7.0-64-puppet",
      base_image_url: nil,
      base_image_version: nil,
      bridge_interface: "wlp3s0b1",
      vagrant_shared_folder: "/home/%s/sync" % GUEST_USER,
      sync_method: "virtualbox",
      panda_path: "/home/%s/panda" % GUEST_USER
    },
    ubuntu: {
      base_image: "ubuntu/xenial64",
      base_image_url: nil,
      base_image_version: nil,
      bridge_interface: "wlp3s0b1",
      vagrant_shared_folder: "/home/%s/sync" % GUEST_USER,
      sync_method: "virtualbox",
      panda_path: "/home/%s/panda" % GUEST_USER
    }
  }
}

# Whether the host network adapter is Wi-Fi.
# On VirtualBox, the user must first manually create a NAT-Network
# named "OSNetwork". The default network CIDR must be changed.
# The Neutron external interface will be connected to this Network.
WIFI = false unless self.class.const_defined?(:WIFI)

# Whether to do Multi-node or All-in-One deployment
MULTINODE = true unless self.class.const_defined?(:MULTINODE)

# The following is only used when deploying in Multi-nodes
NUMBER_OF_DATASTORE_NODES ||= 1
NUMBER_OF_CONTROL_NODES ||= 2
NUMBER_OF_COMPUTE_NODES ||= 1
NUMBER_OF_STORAGE_NODES ||= 1
NUMBER_OF_NETWORK_NODES ||= 0
NUMBER_OF_DOCKERDEV_NODES ||= 7

NODE_SETTINGS ||= {
  aio: {
    cpus: 4,
    memory: 4096
  },
  operator: {
    cpus: 8,
    memory: 8192
  },
  datastore: {
    cpus: 12,
    memory: 32768
  },
  control: {
    cpus: 4,
    memory: 12288
  },
  compute: {
    cpus: 8,
    memory: 40960
  },
  storage: {
    cpus: 4,
    memory: 8192
  },
  network: {
    cpus: 1,
    memory: 1024
  },
  dockerDev: {
    cpus: 4,
    memory: 4096
  }
}

# Configure a new SSH key and config so the operator is able to connect with
# the other cluster nodes.
unless File.file?(File.join(vagrant_dir, 'vagrantkey'))
  system("ssh-keygen -f #{File.join(vagrant_dir, 'vagrantkey')} -N '' -C this-is-vagrant")
end

def get_default(setting)
  PROVIDER_DEFAULTS[PROVIDER.to_sym][DISTRO.to_sym][setting]
rescue
  raise VagrantConfigMissing,
    "Missing configuration for PROVIDER_DEFAULTS[#{PROVIDER}][#{DISTRO}][#{setting}]"
end

def get_setting(node, setting)
  NODE_SETTINGS[node][setting]
rescue
  raise VagrantConfigMissing,
    "Missing configuration for NODE_SETTINGS[#{node}][#{setting}]"
end

def configure_wifi_vbox_networking(vm)
  # Even if adapters 1 & 2 don't need to be modified, if the order is to be
  # maintained, some modification has to be done to them. This will maintain
  # the association inside the guest OS: NIC1 -> eth0, NIC2 -> eth1, NIC3 ->
  # eht2. The modifications for adapters 1 & 2 only change optional properties.
  # Adapter 3 is enabled and connected to the NAT-Network named "OSNetwork",
  # while also changing its optional properties. Since adapter 3 is used by
  # Neutron for the external network, promiscuous mode is set to "allow-all".
  # Also, use virtio as the adapter type, for better performance.
  vm.customize ["modifyvm", :id, "--nictype1", "virtio"]
  vm.customize ["modifyvm", :id, "--cableconnected1", "on"]
  vm.customize ["modifyvm", :id, "--nicpromisc2", "deny"]
  vm.customize ["modifyvm", :id, "--nictype2", "virtio"]
  vm.customize ["modifyvm", :id, "--cableconnected2", "on"]
  vm.customize ["modifyvm", :id, "--nic3", "natnetwork"]
  vm.customize ["modifyvm", :id, "--nat-network3", "OSNetwork"]
  vm.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
  vm.customize ["modifyvm", :id, "--nictype3", "virtio"]
  vm.customize ["modifyvm", :id, "--cableconnected3", "on"]
end

def configure_wifi_if_enabled(vm)
  if WIFI
    case PROVIDER
    when "virtualbox"
      configure_wifi_vbox_networking(vm)
#   TODO(lucian-serb): Configure networking on Wi-Fi for other hypervisors.
#   when "libvirt"
#     configure_wifi_libvirt_networking(vm)
    end
  end
end

def add_secondary_disk_vbox(vm_name, vb, size, vagrant_dir)
  disk_path = File.join(vagrant_dir, "storage", "#{vm_name}-disk-2.vdi")
  unless File.exist?(disk_path)
    # NOTE(huikang): depending on vboxmanager version, choose one of the
    #     commands to create secondary disk
    vb.customize ['createmedium', 'disk', '--filename', disk_path, '--size', size * 1024]
    # vb.customize ['createhd', '--filename', disk_path, '--size', size * 1024]
  end
  vb.customize [
    'storageattach', :id, '--storagectl', SECOND_DISK_CONTROLLER, '--port',
    2, '--device', 0, '--type', 'hdd', '--medium', disk_path
  ]
end

Vagrant.configure(2) do |config|
  config.vm.box = get_default(:base_image)
  version = get_default(:base_image_version)
  if version
    config.vm.box_version = version
  end
  url = get_default(:base_image_url)
  if url
    config.vm.box_url = url
  end

  # Next to the hostonly NAT-network there is a host-only network with all
  # nodes attached. Plus, each node receives a 3rd adapter connected to the
  # outside public network.
  config.vm.network "private_network", type: "dhcp"
  # On VirtualBox hosts with Wi-Fi, do not create a public bridged interface.
  # A NAT-Network will be used instead.
  # TODO(lucian-serb): Do the same for other hypervisors as well?
  unless PROVIDER == "virtualbox" && WIFI
    config.vm.network "public_network", dev: get_default(:bridge_interface), mode: 'bridge', type: 'bridge'
  end

  my_privatekey = File.read(File.join(vagrant_dir, "vagrantkey"))
  my_publickey = File.read(File.join(vagrant_dir, "vagrantkey.pub"))

  config.vm.provision :shell, args: "#{GUEST_USER}", inline: <<-EOS
    GUEST_USER=$1
    mkdir -p /root/.ssh
    echo '#{my_privatekey}' > /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
    echo '#{my_publickey}' > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo '#{my_publickey}' > /root/.ssh/id_rsa.pub
    chmod 644 /root/.ssh/id_rsa.pub
    mkdir -p /home/$GUEST_USER/.ssh
    echo '#{my_privatekey}' > /home/$GUEST_USER/.ssh/id_rsa
    chmod 600 /home/$GUEST_USER/.ssh/*
    echo -e 'Host *\n    StrictHostKeyChecking no' > /home/$GUEST_USER/.ssh/config
    echo -e 'Host *\n    StrictHostKeyChecking no' > /root/.ssh/config
    chown -R $GUEST_USER:$GUEST_USER /home/$GUEST_USER/.ssh
  EOS

  config.hostmanager.enabled = true
  # Make sure hostmanager picks IP address of eth1
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
    case PROVIDER
    when "libvirt"
      if vm.name
        `python newest_dhcp_lease.py #{vm.name}`.chop
      end
    when "virtualbox"
      if vm.id
        `VBoxManage guestproperty get #{vm.id} "/VirtualBox/GuestInfo/Net/1/V4/IP"`.split()[1]
      end
    end
  end

  # The operator controls the deployment
  config.vm.define "operator", primary: true do |admin|
    admin.vm.hostname = "operator.local"
    admin.vm.provision :shell, path: PROVISION_SCRIPT, args: "operator #{MULTINODE ? 'multinode' : 'aio'} #{get_default(:panda_path)} #{GUEST_USER}"
    admin.vm.synced_folder File.join(vagrant_dir, '..'), get_default(:panda_path), create:"True", type: get_default(:sync_method)
    admin.vm.synced_folder File.join(vagrant_dir, 'storage', 'operator'), "/data/host", create:"True", type: get_default(:sync_method)
    admin.vm.synced_folder File.join(vagrant_dir, 'storage', 'shared'), "/data/shared", create:"True", type: get_default(:sync_method)
    admin.vm.synced_folder ".", get_default(:vagrant_shared_folder), disabled: true
    admin.vm.provider PROVIDER do |vm|
      vm.memory = MULTINODE ? get_setting(:operator, :memory) : get_setting(:aio, :memory)
      vm.cpus = MULTINODE ? get_setting(:operator, :cpus) : get_setting(:aio, :cpus)
      if PROVIDER == "libvirt"
        vm.graphics_ip = GRAPHICSIP
      end
      configure_wifi_if_enabled(vm)
    end
    admin.hostmanager.aliases = "operator"
  end

  if MULTINODE
    ['compute', 'storage', 'network', 'datastore', 'control', 'dockerDev'].each do |node_type|
      (1..self.class.const_get("NUMBER_OF_#{node_type.upcase}_NODES")).each do |i|
        hostname = "#{node_type}0#{i}"
        config.vm.define hostname do |node|
          node.vm.hostname = "#{hostname}.local"
          node.vm.provision :shell, path: PROVISION_SCRIPT, args: "#{hostname} multinode #{get_default(:panda_path)} #{GUEST_USER}"
          node.vm.synced_folder File.join(vagrant_dir, 'storage', node_type), "/data/host", create:"True", type: get_default(:sync_method)
          node.vm.synced_folder File.join(vagrant_dir, 'storage', 'shared'), "/data/shared", create:"True", type: get_default(:sync_method)
          node.vm.synced_folder ".", get_default(:vagrant_shared_folder), disabled: true

          if PROVIDER == "libvirt"
            if hostname.include? "storage"
              config.vm.provider :libvirt do |libvirt|
                libvirt.storage :file, :size => SECOND_DISK_SIZE, :type => 'qcow2', :path => 'storage01-disk2.qcow2', :device => 'vdc'
              end
            end
          end

          node.vm.provider PROVIDER do |vm|
            vm.memory = get_setting(node_type.to_sym, :memory)
            vm.cpus = get_setting(node_type.to_sym, :cpus)

            if PROVIDER == "virtualbox"
              if hostname.include? "storage"
                add_secondary_disk_vbox(node.vm.hostname, vm, SECOND_DISK_SIZE, vagrant_dir)
              end
            end

            if PROVIDER == "libvirt"
              vm.graphics_ip = GRAPHICSIP
            end
            configure_wifi_if_enabled(vm)
          end
          node.hostmanager.aliases = hostname
        end
      end
    end
  end

end
