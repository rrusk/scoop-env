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

# Daemons
systemctl enable docker
systemctl start docker

# Add user to docker group.
gpasswd -a vagrant docker

su vagrant << EOF
  # set up dotfiles
  git clone https://github.com/PhysiciansDataCollaborative/dotfiles
  
  # get the environtment repo
  git clone https://github.com/PhysiciansDataCollaborative/scoop-env scoop-env
EOF

echo ''
echo '`cd dotfiles && make` if you would like nicer configs.'
echo ''
