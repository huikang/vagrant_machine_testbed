require 'rbconfig'



def create_vm(config, options = {})
  dirname = File.dirname(__FILE__)
  #config.vm.synced_folder "#{dirname}/..", '/root/vagrant', create:"True", type: 'nfs'
  #config.vm.synced_folder "/root/development", '/root/development', create:"True", type: 'nfs'
  osbox = options.fetch(:ostype, "ostype")
  #if osbox != "ubuntu/xenial64"
  #  config.ssh.password = 'vagrant'
  #end

  name = options.fetch(:name, "node")
  id = options.fetch(:id, 1)
  disk2 = options.fetch(:disk2, 0)
  vm_name = "%s-%02d" % [name, id]

  memory = options.fetch(:memory, 1024)
  cpus = options.fetch(:cpus, 1)
  private_net = options.fetch(:private_net, true)

  config.vm.define vm_name do |config|
    config.vm.box = osbox
    if osbox == "sl-ostack-centos-7.0"
      config.vm.box_url = "https://dal05.objectstorage.softlayer.net/v1/AUTH_0d9dffd4-303d-465e-b12a-da4cfad071c9/openstack-images/sl-ostack-centos-7.0.json"
      config.vm.box_version = "0.4.0"
    end

    config.vm.hostname = vm_name

    #config.vm.provision "file", source: "#{dirname}/resolv.conf", destination: "/tmp/resolv.conf"
    #config.vm.provision "shell", inline: "sudo cp -f /tmp/resolv.conf /etc/resolv.conf"

    #if vm_name == "controller-01"
    #  config.vm.provision "shell", inline: "sudo git -c http.sslVerify=false clone https://stash.softlayer.local/scm/devtools/openstack-ansible.git /root/openstack-ansible"
    #end

    pub_ip_prefix = options.fetch(:pub_ip_prefix, "pub_ip_prefix")

    if pub_ip_prefix == ''
      public_ip = "192.168.1.10#{id}"
    else
      public_ip = pub_ip_prefix + ".10#{id}"
    end

    config.vm.network :private_network, ip: public_ip, netmask: "255.255.255.0"

    if private_net
      priv_ip_prefix = options.fetch(:priv_ip_prefix, "priv_ip_prefix")
      if priv_ip_prefix == ''
        private_ip = "192.168.2.10#{id}"
      else
        private_ip = priv_ip_prefix + ".10#{id}"
      end
      config.vm.network :private_network, ip: private_ip, netmask: "255.255.255.0"
      # config.vm.network :public_network, dev: 'virbr1', mode: 'bridge', type: 'bridge'
    end

    my_privatekey = File.read("/root/.ssh/id_rsa")
    my_publickey = File.read("/root/.ssh/id_rsa.pub")

    config.vm.provision :shell, inline: <<-EOS
    mkdir -p /root/.ssh
    echo '#{my_privatekey}' > /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
    echo '#{my_publickey}' > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo '#{my_publickey}' > /root/.ssh/id_rsa.pub
    chmod 644 /root/.ssh/id_rsa.pub
    mkdir -p /home/vagrant/.ssh
    echo '#{my_privatekey}' >> /home/vagrant/.ssh/id_rsa
    chmod 600 /home/vagrant/.ssh/*
    echo 'Host *' > ~vagrant/.ssh/config
    echo StrictHostKeyChecking no >> ~vagrant/.ssh/config
    chown -R vagrant: /home/vagrant/.ssh
    EOS

    config.vm.provider :virtualbox do |vb|
      vb.memory = memory
      vb.cpus = cpus
      vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
      vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
      add_secondary_disk(vm_name, vb, disk2) if disk2 > 0

      if RbConfig::CONFIG['host_os'].downcase =~ /mingw|mswin/
        vb.gui = true
      end
    end

    config.vm.provider :libvirt do |libvirt|
      libvirt.memory = memory
      libvirt.cpus = cpus
      libvirt.disk_bus = 'sata'

      add_secondary_disk_libvirt(vm_name, libvirt, disk2) if disk2 > 0
    end
  end
end

def add_secondary_disk(vm_name, vb, disk2)
  disk_path = "#{vm_name}-disk-2.vdi"
  unless File.exist?(disk_path)
    vb.customize ['createhd', '--filename', disk_path, '--size', disk2 * 1024]
  end
  vb.customize [
    'storageattach', :id, '--storagectl', 'SATA Controller', '--port',
    1, '--device', 0, '--type', 'hdd', '--medium', disk_path
  ]
end

def add_secondary_disk_libvirt(vm_name, libvirt, disk2)
  disk_path = "#{vm_name}-disk-2.img"
  unless File.exist?(disk_path)
    libvirt.storage :file, :path => disk_path, :size => "#{disk2}G", :bus => 'sata'
  else
    libvirt.storage :file, :path => disk_path, :size => "#{disk2}G", :allow_existing => true, :bus => 'sata'
  end
end
