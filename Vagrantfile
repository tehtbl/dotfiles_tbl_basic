# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# variables
#
$cpus = Integer(ENV.fetch('VMCPUS', '2'))  # create VMs with that many cpus
$mem = Integer(ENV.fetch('VMMEM', '8192'))  # create VMs with that many cpus

#
# provision user
#
def fs_init(user)
  return <<-EOF
    find /vagrant/ -name '__pycache__' -exec rm -rf {} \\; 2> /dev/null

    chown -R #{user} /vagrant/*
    touch ~#{user}/.bash_profile
    chown #{user} ~#{user}/.bash_profile

    echo 'export LANG=en_US.UTF-8' >> ~#{user}/.bash_profile
    echo 'export LC_CTYPE=en_US.UTF-8' >> ~#{user}/.bash_profile
    echo 'export LC_ALL=en_US.UTF-8' >> ~#{user}/.bash_profile

    export PATH="#{user}/.pyenv/bin:$PATH"
  EOF
end

#
# install packages
#
def packages_debianoid(user)
  return <<-EOF

    apt update
    apt dist-upgrade -y

    usermod -a -G fuse #{user}
    chgrp fuse /dev/fuse
    chmod 666 /dev/fuse

    apt install -y \
      python3-dev \
      python3-setuptools \
      python-virtualenv \
      python3-virtualenv \
      python3-pip \
      python3-venv \
      fontconfig \
      zsh \
      git \
      curl \
      wget \
      python3-powerline

  EOF
end

#
# install pyenv
#
def install_pyenv(boxname)
  return <<-EOF
    curl https://pyenv.run | bash

    echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bash_profile
    echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile

    echo 'export PYTHON_CONFIGURE_OPTS="--enable-shared"' >> ~/.bash_profile
  EOF
end

#
# install pyenvs
#
def install_pythons(boxname)
  return <<-EOF
    . ~/.bash_profile
    pyenv install 3.7.5rc1
    pyenv rehash
  EOF
end

#
# run tests
#
def run_tests(boxname, user)
  return <<-EOF
    . ~/.bash_profile

    sudo chown -R #{user} /vagrant

    # mv /vagrant/ansible-role-#{$rolename} /vagrant/#{$rolename}
    cd /vagrant/#{$rolename}

    # pyenv global 3.7.5rc1
    # pip3 install tox

    rm -rf /vagrant/#{$rolename}/.tox
    IMAGE="ubuntu" TAG="bionic" tox

  EOF
end

#
# MAiN
#
Vagrant.configure(2) do |config|
  # use rsync to copy content to the folder
  config.vm.synced_folder ".",
    "/vagrant/dotfiles",
    :type => "rsync",
    :rsync__args => ["--verbose", "--archive", "--delete", "-z"],
    :rsync__chown => false,
    rsync__exclude: [".git/", ".tox/", ".vagrant/"]

  # do not let the VM access . on the host machine via the default shared folder!
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # # access a port on your host machine (via localhost) and have all data forwarded to a port on the guest machine.
  # config.vm.network "forwarded_port", guest: 8080, host: 8080

  # Create a private network, which allows host-only access to the machine using a specific IP.
  config.vm.network "private_network", ip: "192.168.5.11"

  # set number of CPUs
  config.vm.provider :virtualbox do |v|
    v.cpus = $cpus
  end

  # Ubuntu vm
  config.vm.define "bionic64" do |b|
    b.vm.box = "ubuntu/bionic64"
    b.vm.provider :virtualbox do |v|
      v.memory = $mem
    end
    b.vm.provision "fs init", :run => "once", :type => :shell, :inline => fs_init("vagrant")
    b.vm.provision "packages debianoid", :run => "once", :type => :shell, :inline => packages_debianoid("vagrant")
    b.vm.provision "install pyenv", :run => "once", :type => :shell, :privileged => false, :inline => install_pyenv("bionic64")
    # b.vm.provision "install pythons", :run => "once", :type => :shell, :privileged => false, :inline => install_pythons("bionic64")
    # b.vm.provision :docker, :run => "once"
    b.vm.provision :reload, :run => "once"

    # b.vm.provision "run tests", :run => "always", :type => :shell, :privileged => false, :inline => run_tests("bionic64", "vagrant")
  end

end
