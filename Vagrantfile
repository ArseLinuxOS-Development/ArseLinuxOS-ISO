# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.box = "archlinux/archlinux"
  config.vm.define "arselinux-dev" do |config|
    config.vm.hostname = "arselinux-dev"
    config.vm.provider :libvirt do |v|
      v.memory = 16096
      v.cpus = 8
    end
  end

  # Install pre-requisites
  config.vm.provision "shell", inline: <<-SHELL
    pacman -Syu
    pacman -S --noconfirm git vim reflector archiso mkinitcpio-archiso
  SHELL
end
