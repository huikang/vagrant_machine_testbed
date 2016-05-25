#!/bin/bash -eux
yum -y install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum -y install https://rdo.fedorapeople.org/rdo-release.rpm
yum -y groupinstall 'Development Tools'
yum -y install git yum-plugin-fastestmirror yum-plugin-priorities ntp vim crudini java-1.7.0-openjdk iptables-services

yum -y install python-pip python-devel sshpass
pip install ansible

#disable yum-plugin-fastestmirror
crudini --set /etc/yum/pluginconf.d/fastestmirror.conf main enabled 0

#disable selinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

yes | pip uninstall pycrypto

systemctl stop NetworkManager
systemctl disable NetworkManager
yum -y remove NetworkManager
chkconfig network on

