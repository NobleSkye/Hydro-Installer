# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.network "private_network", type: "dhcp"

  config.vm.provision "shell",
    inline: "ln -sf /vagrant/lib/lib.sh /tmp/lib.sh"

  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = "4096"
  end

  # Ubuntu
  config.vm.define "ubuntu_resolute" do |ubuntu_resolute|
    ubuntu_resolute.vm.box = "generic/ubuntu2604"
  end

  config.vm.define "ubuntu_noble" do |ubuntu_noble|
    ubuntu_noble.vm.box = "generic/ubuntu2404"
  end

  config.vm.define "ubuntu_jammy" do |ubuntu_jammy|
    ubuntu_jammy.vm.box = "generic/ubuntu2204"
  end

  # Debian
  config.vm.define "debian_trixie" do |debian_trixie|
    debian_trixie.vm.box = "generic/debian13"
  end

  config.vm.define "debian_bookworm" do |debian_bookworm|
    debian_bookworm.vm.box = "generic/debian12"
  end

  config.vm.define "debian_bullseye" do |debian_bullseye|
    debian_bullseye.vm.box = "generic/debian11"
  end

  config.vm.define "debian_buster" do |debian_buster|
    debian_buster.vm.box = "generic/debian10"
  end

  # AlmaLinux
  config.vm.define "almalinux_9" do |almalinux_9|
    almalinux_9.vm.box = "generic/almalinux9"
  end

  config.vm.define "almalinux_8" do |almalinux_8|
    almalinux_8.vm.box = "generic/almalinux8"
  end

  # Rocky Linux
  config.vm.define "rockylinux_9" do |rockylinux_9|
    rockylinux_9.vm.box = "generic/rocky9"
  end

  config.vm.define "rockylinux_8" do |rockylinux_8|
    rockylinux_8.vm.box = "generic/rocky8"
  end
end
