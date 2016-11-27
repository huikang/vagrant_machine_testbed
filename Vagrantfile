# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'
require_relative './vagrant/shared.rb'

=begin
  VM creation using the following parameters
  name:   VM name
  id:     id appended to VM name
  memory: memory size in MB
  cpus:   number of cpus
  ostype: sl-ostack-centos-7.0 | baremettle/ubuntu-14.04
  pub_ip_prefix:
  priv_ip_prefix:
=end
# ip_prefix = "172.18"

Vagrant.configure("2") do |config|

  # VMs for quasar testbed
  pub_ip_prefix  = "192.168.1"
  priv_ip_prefix = "192.168.2"
  create_vm(config, name: "quasar-tygris1", id: 1, memory: 4096, cpus: 2, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "quasar-tygris1", id: 2, memory: 4096, cpus: 2, ostype: "sl-ostack-centos-7.0", disk2: 10, pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  # VMs for kolla testbed
  pub_ip_prefix  = "192.168.23"
  priv_ip_prefix = "192.168.24"
  create_vm(config, name: "kolla", id: 1, memory: 4096, cpus: 2, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla", id: 2, memory: 4096, cpus: 4, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla", id: 3, memory: 4096, cpus: 4, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla", id: 4, memory: 4096, cpus: 4, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla", id: 5, memory: 4096, cpus: 4, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla", id: 6, memory: 4096, cpus: 4, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla", id: 7, memory: 4096, cpus: 4, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla", id: 8, memory: 4096, cpus: 4, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  pub_ip_prefix  = "192.168.27"
  priv_ip_prefix = "192.168.28"
  create_vm(config, name: "kolla-upstream", id: 1, memory: 4096, cpus: 2, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla-upstream", id: 2, memory: 4096, cpus: 4, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla-upstream", id: 3, memory: 4096, cpus: 4, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla-upstream", id: 4, memory: 4096, cpus: 4, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla-upstream", id: 5, memory: 4096, cpus: 4, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  create_vm(config, name: "kolla-upstream-ubuntu", id: 5, memory: 8192, cpus: 4, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla-upstream-ubuntu", id: 6, memory: 8192, cpus: 4, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla-upstream-ubuntu", id: 7, memory: 4096, cpus: 4, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "kolla-upstream-ubuntu", id: 8, memory: 4096, cpus: 4, ostype: "ubuntu/vivid64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  # VMs for pcs testbed, pacemaker
  pub_ip_prefix  = "192.168.9"
  priv_ip_prefix = "192.168.10"
  create_vm(config, name: "pcs", id: 1, memory: 4096, cpus: 2, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "pcs", id: 2, memory: 4096, cpus: 2, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "pcs", id: 3, memory: 4096, cpus: 2, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  pub_ip_prefix  = "192.168.15"
  priv_ip_prefix = "192.168.16"
  create_vm(config, name: "docker-dev", id: 1, memory: 4096, cpus: 2, ostype: "centos/7", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "docker-dev", id: 2, memory: 4096, cpus: 2, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "docker-dev", id: 3, memory: 4096, cpus: 2, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  pub_ip_prefix  = "192.168.25"
  priv_ip_prefix = "192.168.26"
  create_vm(config, name: "heroku-dev", id: 1, memory: 1024, cpus: 2, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  # VMs for hyper.sh
  pub_ip_prefix  = "192.168.29"
  priv_ip_prefix = "192.168.30"
  create_vm(config, name: "hyper", id: 1, memory: 4096, cpus: 2, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "hyper", id: 2, memory: 4096, cpus: 2, ostype: "ubuntu/vivid64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  # VMs for OSv host
  pub_ip_prefix  = "192.168.31"
  priv_ip_prefix = "192.168.32"
  create_vm(config, name: "osv-host", id: 1, memory: 4096, cpus: 2, ostype: "sl-ostack-centos-7.0", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  # VMs for OSN host
  pub_ip_prefix  = "192.168.33"
  priv_ip_prefix = "192.168.34"
  create_vm(config, name: "ovn-host", id: 1, memory: 4096, cpus: 2, ostype: "centos/7", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "ovn-host", id: 2, memory: 4096, cpus: 2, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "ovn-host", id: 3, memory: 4096, cpus: 2, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "ovn-host", id: 4, memory: 4096, cpus: 2, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "ovn-host", id: 5, memory: 4096, cpus: 2, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "ovn-host", id: 6, memory: 4096, cpus: 2, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "ovn-host", id: 7, memory: 4096, cpus: 2, ostype: "kja/netbsd-7-amd64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)


  # VMs for Go program
  pub_ip_prefix  = "192.168.35"
  priv_ip_prefix = "192.168.36"
  create_vm(config, name: "go-dev", id: 1, memory: 4096, cpus: 2, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  # VMs for k8s
  pub_ip_prefix  = "192.168.37"
  priv_ip_prefix = "192.168.38"
  create_vm(config, name: "k8s", id: 1, memory: 4096, cpus: 2, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  # VMs for unikernel
  pub_ip_prefix  = "192.168.39"
  priv_ip_prefix = "192.168.40"
  create_vm(config, name: "unikernel-dev", id: 1, memory: 4096, cpus: 2, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "unikernel-dev", id: 2, memory: 4096, cpus: 2, ostype: "decentlab/xenial64-minimal-libvirt", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  # VMs for devstack
  pub_ip_prefix  = "192.168.41"
  priv_ip_prefix = "192.168.42"
  create_vm(config, name: "devstack", id: 1, memory: 4096, cpus: 2, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "devstack", id: 2, memory: 4096, cpus: 2, ostype: "ubuntu/trusty64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  # VMs for panda dev
  pub_ip_prefix  = "192.168.43"
  priv_ip_prefix = "192.168.44"
  create_vm(config, name: "panda", id: 1, memory: 4096, cpus: 2, ostype: "ubuntu/xenial64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "panda", id: 2, memory: 8192, cpus: 4, ostype: "ubuntu/xenial64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "panda", id: 3, memory: 8192, cpus: 4, ostype: "ubuntu/xenial64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "panda", id: 4, memory: 8192, cpus: 4, ostype: "ubuntu/xenial64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  create_vm(config, name: "panda", id: 5, memory: 8192, cpus: 4, ostype: "ubuntu/xenial64", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)

  # Examples:
  #     create_vm(config, name: "docker-test-1", id: 2, memory: 4096, cpus: 2, ostype: "sl-ostack-centos-7.0")
  #     create_vm(config, name: "docker-test-2", id: 3, memory: 2048, cpus: 2, ostype: "baremettle/ubuntu-14.04")
  #     create_vm(config, name: "docker-test-3", id: 4, memory: 2048, cpus: 2, ostype: "baremettle/ubuntu-14.04", pub_ip_prefix: pub_ip_prefix, priv_ip_prefix: priv_ip_prefix)
  #     create_vm(config, name: "docker-test-1", id: 2, memory: 1024, disk2: 1)

end
