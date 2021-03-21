# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.boot_timeout = 1800
  config.vm.box = "phlummox/ubuntu-dokku"
  config.vm.hostname = "dokku-vouch-proxy.local"
  config.vm.synced_folder ".", "/vagrant", disabled: true

end
