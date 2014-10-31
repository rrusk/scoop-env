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

#### Unexpected EOF

Output:

```
b5094295c793: Pulling metadata
2014/09/17 18:55:41 unexpected EOF
make: *** [pull-mongo] Error 1
```

`make pull` is a composite of the following tasks, try the one that failed:

```bash
make pull-mongo
make pull-wildfly
make pull-keycloak
make pull-phusion
```

Eventually, you'll successfully get a copy.

#### Failed to create rootfs

```bash
eea2821a4553: Download complete
05aea00a321b: Error downloading dependent layers
13e42d0c2a51: Download complete
01e217439a55: Download complete
2014/09/18 16:29:34 Error pulling image (0.9.6) from phusion/passenger-ruby19, Driver devicemapper failed to create image rootfs 05aea00a321b91d34b2c81a2c4b524fd2ed9912ba061ec9416fb919970edf56b: device 05aea00a321b91d34b2c81a2c4b524fd2ed9912ba061ec9416fb919970edf56b already exists
make: *** [pull-phusion] Error 1
```

This commonly happens after the EOF error. In this case, the solution is:

```bash
sudo rm -rf /var/lib/docker/devicemapper/mnt/05aea00a321b91d34b2c81a2c4b524fd2ed9912ba061ec9416fb919970edf56b
```

If you have errors removing this folder, particularly an input/output error, try restarting the virtual machine.

## Building the Images

To build the required images for each component of the system you can just run:

```bash
make build
```

You may be interested in looking at the `Makefile` at the `build-*` tasks, especially if you are hacking on a particular component.  Note that the network connectivity is established through the use of port forwarding from the host to the vagrant box.

## Running the Images

```bash
make run
```

> If this is your first time running, check out the `hosts` job in the `Makefile`, you may want to run `make hosts`

## Populating the databases

Since there is not a publicly available test database for the Hub component, please place your own as `data/hub-dump`. Then,

```bash
make database-populate
```

```
This is necessary if you have no end points to pull from.  Alternatively, you can proceed with user creation 
(step 8 in the query-composer instructions), and arrange a data pull from an endpoint of your choice.  When 
running the command to enable the new user, you must run the command from inside the hub docker container and 
within the /home/app/query-composer/ directory there.
```

## Playing

Visit one of the components in your web browser:

* Auth: [https://auth.scoop.local:8080]()
* Provider: [https://provider.scoop.local:8081/api]()
* Visualizer: [https://visualizer.scoop.local:8082]()
* Hub: [https://hub.scoop.local:8083]()
* Endpoint: [https://endpoint.scoop.local:8084]()
