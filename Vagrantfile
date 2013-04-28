# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.require_plugin "vagrant-guests-openbsd"

Vagrant.configure("2") do |config|
  config.vm.box = "vagrant-openbsd-52"
  config.vm.guest = :openbsd_v2
  config.vm.hostname = "vagrant-openbsd1"
  config.vm.box_url = "http://projects.tsuntsun.net/~nabeken/boxes/vagrant-openbsd-52.box"
  config.vm.network :private_network, ip: "192.168.67.10", netmask: "255.255.255.0"

  config.vm.provision :chef_solo do |chef|
    chef.nfs = true
    chef.cookbooks_path = ".."
    chef.data_bags_path = "data_bags"
    chef.add_recipe "openbsd"
    chef.add_recipe "openbsd::carp"
    chef.add_recipe "openbsd::ipsec_initiator_test"
    chef.add_recipe "minitest-handler-cookbook"
  end
end
