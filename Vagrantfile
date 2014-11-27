# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'precise64'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
  config.vm.hostname = 'dagobah'
  
  config.vm.provider 'virtualbox' do |v|
    v.gui = true
    v.customize ['modifyvm', :id, '--memory', 4096]
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'manifests'
    puppet.manifest_file = 'main.pp'
    puppet.options = ['--verbose --debug']
  end
end
