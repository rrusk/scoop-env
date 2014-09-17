This repo includes a `Vagrantfile` that will boot up a Fedora 20 based host box. The disk has been extended and it will automatically pull down various repos related to the SCOOP project.

## You'll need:

* [Vagrant](http://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)
* >50GB disk space
* Time

Currently, there is no publicly available data for the `data/` folder, we're working on this. For now, please place a hub dump into the `data/hub-dump` folder.

## Getting Started

First, erect the Vagrant box. We supply a `Vagrantfile` in this repo:

```bash
git clone https://github.com/Hoverbear/scoop-env
cd scoop-env
vagrant up
```

**If you don't already have a Fedora 20 Base Box**: This first run will have a considerable wait as it is downloaded.

Check out `util/provision.sh` to see what's being done to the box while you wait. In short:

* Create a second drive and join the two into a volume group, then expand the logical volume and resize the filesystem.
* Install some useful/necessary tools.
* Setup some sane dotfiles.
* Clone relevant SCOOP repos.

## Making it Personal(ish)

First, you probably want to get some decent configuration:

```bash
cd dotfiles
make
chsh -s /usr/bin/zsh
```

During the `make` step there should be an error from `vim` about color schemes, it's okay, just hit return.

## Pulling the Images

```bash
cd scoop-env
make pull
```

Due to some *unreliabilities* with Docker and Virtualbox interactions (We haven't quite figured it out yet), `docker pull` commands will often fail with cryptic errors. 

