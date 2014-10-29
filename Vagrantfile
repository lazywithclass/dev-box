# -*- mode: ruby -*-
# vi: set ft=ruby :

# remember to add ssh credentials
# mv ~/.ssh ~/.ssh-old
# git clone https://username:password@github.com/username/repository.git ~/.ssh

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  
  # config.vm.provider "virtualbox" do |v|
  #   v.gui = true
  # end

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "main.pp"
    puppet.options = ["--verbose"]
  end
end
