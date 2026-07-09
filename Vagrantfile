# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.network "public_network"

  config.vm.provision "shell",
    inline: "ln -sf /vagrant/lib/lib.sh /tmp/lib.sh"

  # Ubuntu
  config.vm.define "ubuntu_resolute" do |ubuntu_resolute|
    ubuntu_resolute.vm.box = "alvistack/ubuntu-26.04"
    ubuntu_resolute.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
  end

  config.vm.define "ubuntu_noble" do |ubuntu_noble|
    ubuntu_noble.vm.box = "alvistack/ubuntu-24.04"
    ubuntu_noble.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
  end

  config.vm.define "ubuntu_jammy" do |ubuntu_jammy|
    ubuntu_jammy.vm.box = "ubuntu/jammy64"
    ubuntu_jammy.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
  end

  # Debian
  config.vm.define "debian_trixie" do |debian_trixie|
    debian_trixie.vm.box = "debian/trixie64"
    debian_trixie.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
  end

  config.vm.define "debian_bookworm" do |debian_bookworm|
    debian_bookworm.vm.box = "debian/bookworm64"
    debian_bookworm.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
  end

  config.vm.define "debian_bullseye" do |debian_bullseye|
    debian_bullseye.vm.box = "debian/bullseye64"
    debian_bullseye.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
  end

  config.vm.define "debian_buster" do |debian_buster|
    debian_buster.vm.box = "debian/buster64"
    debian_buster.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
  end

  # AlmaLinux
  config.vm.define "almalinux_9" do |almalinux_9|
    almalinux_9.vm.box = "almalinux/9"
    almalinux_9.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
  end

  config.vm.define "almalinux_8" do |almalinux_8|
    almalinux_8.vm.box = "almalinux/8"
    almalinux_8.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
  end

  # Rocky Linux
  config.vm.define "rockylinux_9" do |rockylinux_9|
    rockylinux_9.vm.box = "bento/rockylinux-9"
    rockylinux_9.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
  end

  config.vm.define "rockylinux_8" do |rockylinux_8|
    rockylinux_8.vm.box = "bento/rockylinux-8"
    rockylinux_8.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
  end
end
