#!/bin/bash

# Partitioning
parted /dev/sdb mklabel msdos
parted /dev/sdb mkpart primary xfs 512 100%
parted /dev/sdb set 1 lvm on
vgextend vg_vagrant /dev/sdb1
lvextend /dev/mapper/vg_vagrant-lv_root -L 100G
resize2fs /dev/mapper/vg_vagrant-lv_root

# Install Packages
yum remove -y vim-minimal # Removed sudo :(
yum install -y sudo zsh vim-enhanced docker-io tmux cmake java-1.8.0-openjdk mongodb git

# Leiningen
curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein > /usr/bin/lein
chmod +x /usr/bin/lein

# Daemons
systemctl enable docker
systemctl start docker

# Add user to docker group.
gpasswd -a vagrant docker

# Set up some dotfiles
su vagrant << EOF
  git clone https://github.com/Hoverbear/dotfiles
EOF

# Get the Repos
su vagrant << EOF
  git clone https://github.com/Hoverbear/scoop-env scoop-env
  git clone https://github.com/PhysiciansDataCollaborative/visualizer visualizer
  git clone https://github.com/PhysiciansDataCollaborative/hub-api hub-api
EOF
#these are the deprecated closer provider and visualizer
#git clone https://github.com/Hoverbear/scoop-provider-clj.git scoop-env/provider
#git clone https://github.com/Hoverbear/scoop-visualizer-clj.git scoop-env/visualizer

echo ''
echo '`cd dotfiles && make` if you would like nicer configs.'
echo ''
