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
yum install -y sudo vim-enhanced docker-io tmux cmake java-1.8.0-openjdk mongodb git

# Leiningen
curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein > /usr/bin/lein

su vagrant << EOF
  # Get the repos.
  git clone https://github.com/Hoverbear/scoop-env scoop-env
  git clone https://github.com/Hoverbear/scoop-provider-clj.git scoop-env/provider
  git clone https://github.com/Hoverbear/scoop-visualizer-clj.git scoop-env/visualizer
EOF
