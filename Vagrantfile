# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.require_plugin "vagrant-guests-openbsd"

def setup_chefsolo(chef)
  chef.nfs = true
  chef.cookbooks_path = ".."
  chef.data_bags_path = "data_bags"
  chef.add_recipe "openbsd"
end

Vagrant.configure("2") do |config|
  config.vm.guest = :openbsd_v2
  config.vm.box = "vagrant-openbsd-52"
  config.vm.box_url = "http://projects.tsuntsun.net/~nabeken/boxes/vagrant-openbsd-52.box"

  config.vm.define :openbsd1 do |openbsd1|
    openbsd1.vm.hostname = "vagrant-openbsd1"
    openbsd1.vm.network :private_network, ip: "192.168.67.10", netmask: "255.255.255.0"
    openbsd1.vm.network :private_network, ip: "192.168.67.20", netmask: "255.255.255.0"

    openbsd1.vm.provision :shell do |s|
      s.inline = <<SCRIPT
grep -q 'rdomain 1' /etc/hostname.em2 || {
  mv /etc/hostname.em2{,.orig}
  echo 'rdomain 1' | cat - /etc/hostname.em2.orig > /etc/hostname.em2
  sh /etc/netstart em2
}
SCRIPT
    end

    openbsd1.vm.provision :chef_solo do |chef|
      setup_chefsolo(chef)
      chef.add_recipe "openbsd::carp"
      chef.add_recipe "openbsd::ipsec_initiator_rdomain_test"
      chef.add_recipe "minitest-handler-cookbook"
    end
  end

  config.vm.define :openbsd2 do |openbsd1|
    openbsd1.vm.hostname = "vagrant-openbsd2"
    openbsd1.vm.network :private_network, ip: "192.168.67.11", netmask: "255.255.255.0"

    openbsd1.vm.provision :chef_solo do |chef|
      setup_chefsolo(chef)
      chef.add_recipe "openbsd::carp"
      chef.add_recipe "openbsd::ipsec_initiator_nordomain_test"
      chef.add_recipe "minitest-handler-cookbook"
    end
  end

  config.vm.define :'ipsec-gw1' do |openbsd1|
    openbsd1.vm.hostname = "ipsec-gw1.example.org"

    # em1
    openbsd1.vm.network :private_network, ip: "192.168.67.2", netmask: "255.255.255.0"

    # em2
    openbsd1.vm.network :private_network, ip: "10.0.67.2", netmask: "255.255.255.0"

    openbsd1.vm.provision :chef_solo do |chef|
      setup_chefsolo(chef)
      chef.add_recipe "openbsd::carp"
      chef.add_recipe "openbsd::hostnameif_gw1_test"
      chef.add_recipe "openbsd::ipsec_responder_test"
      chef.add_recipe "minitest-handler-cookbook"
    end
  end

  config.vm.define :'ipsec-gw2' do |openbsd1|
    openbsd1.vm.hostname = "ipsec-gw2.example.org"

    # em1
    openbsd1.vm.network :private_network, ip: "192.168.67.3", netmask: "255.255.255.0"

    # em2
    openbsd1.vm.network :private_network, ip: "10.0.67.3", netmask: "255.255.255.0"

    openbsd1.vm.provision :chef_solo do |chef|
      setup_chefsolo(chef)
      chef.add_recipe "openbsd::carp"
      chef.add_recipe "openbsd::hostnameif_gw2_test"
      chef.add_recipe "openbsd::ipsec_responder_test"
      chef.add_recipe "minitest-handler-cookbook"
    end
  end
end
