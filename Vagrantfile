# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.hostname = 'radiator-evaluation'

  config.vm.define 'radiator-ubuntu', primary: true do |ubuntu|
    ubuntu.vm.box = 'bento/ubuntu-16.04'
  end

  config.vm.define 'radiator-centos', autostart: false do |centos|
    centos.vm.box = 'bento/centos-7.4'
  end

  # This requires vagrant-berkshelf plugin
  # Install via `vagrant plugin install vagrant-berkshelf`
  config.berkshelf.enabled = true
  config.berkshelf.berksfile_path = 'Berksfile'

  config.vm.provision :chef_solo do |chef|
    chef.channel = 'stable'
    chef.version = '13.8.5'
    chef.add_recipe 'radiator::evaluation'
    chef.json = {
      'radiator' => {
        'evaluation' => {
          'install_version' => '4.21',
          'show_license' => true,
          'accept_license' => true,
          'download_username' => (ENV['RADIATOR_EVAL_USERNAME'] || 'please-change-me').to_s,
          'download_password' => (ENV['RADIATOR_EVAL_PASSWORD'] || 'please-change-me').to_s,
        },
        'configuration' => {
          'Client' => {
            'DEFAULT' => {
              'Secret' => 'evaluation',
              'Identifier' => 'chef',
            },
          },
        },
      },
    }
  end

  config.vm.network 'forwarded_port', guest: 1812, host: 1812, protocol: 'udp'
  config.vm.network 'forwarded_port', guest: 1813, host: 1813, protocol: 'udp'

  config.vm.post_up_message = "Your Radiator evaluation server is now running!\n\n" \
                              "You can access it by entering `vagrant ssh`.\n" \
                              'UDP ports 1812 and 1813 are also forwarded from localhost to the Vagrant boxva.'
end
