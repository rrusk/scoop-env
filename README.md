This repo includes a `Vagrantfile` that will boot up a Fedora 20 based host box. The disk has been extended and it will automatically pull down various repos related to the SCOOP project.


## You'll need:

* [Vagrant](http://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)
* >50GB disk space
* Time

Currently, there is no publicly available data for the `data/` folder, we're working on this. For now, please place a hub dump into the `data/hub-dump` folder.


## Getting Started

First, erect the Vagrant box. A `Vagrantfile` is supplied in this repo:

```bash
git clone https://github.com/PhyDaC/scoop-env
cd scoop-env
vagrant up
```

**If you don't already have a Fedora 20 Base Box**: This first run will have a considerable wait as it is downloaded.

Check out `util/provision.sh` to see what's being done to the box while you wait. In short:

* Create a second drive and join the two into a volume group, then expand the logical volume and resize the filesystem.
* Install some useful/necessary tools.
* Setup some sane dotfiles.
* Clone relevant repos.


## Login to Vagrant With SSH and Access the Shared Folder

```bash
vagrant ssh
cd /vagrant/
```


## Pulling the Images

```bash
cd scoop-env
make pull
```

Due to some *unreliabilities* with Docker and Virtualbox interactions (We haven't quite figured it out yet), `docker pull` commands will often fail with cryptic errors. Please see troubleshooting at the bottom of this document.


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
Note: `make run` fails if the containers are already running.  Please see the troubleshooting section.


## Configuring the Hosts File

On the machine you wish to use to access the aliased address the Hosts file must have the entries below added.  On a Mac or Linux based system it can be added with our Make file as `make hosts`.

127.0.0.1         hubapi.scoop.local
127.0.0.1         visualizer.scoop.local
127.0.0.1         hub.scoop.local
127.0.0.1         endpoint.scoop.local


## Accessing Vagrant

Login with SSH
```bash
vagrant ssh
```

## Accessing Docker Containers

From inside Vagrant:

List Containers
```bash
docker ps -a
```

Verify that hubapi, visualizer-db, hub-db, hub, endpoint-db and endpoint are running

Obtain the endpoints' PID
```bash
docker inspect --format {{.State.Pid}} endpoint
```

Use nsenter and that PID to access the container
```bash
sudo nsenter --target PID_NUMBER --mount --uts --ipc --net --pid /bin/bash
```

Or combine the two into a single command
```bash
sudo nsenter --target $(docker inspect --format {{.State.Pid}} endpoint) --mount --uts --ipc --net --pid /bin/bash
```

## Importing Data

Login to Vagrant and then the endpoint (in docker)

Create the import directory (if not already there)
```bash
mkdir -p /home/app/endpoint/util/files/
```

Navigate to the import directory
```bash
cd /home/app/endpoint/util/files/
```

Use SCP to copy in a ZIP file from the host machine (yours, not Vagrant or Docker)
```bash
scp LOGIN_NAME@IP_OR_HOSTNAME:/PATH_TO_FILE/FILE.zip .
```

Note, OS X: Enable SCP from System Preferences > Sharing > Remote Login [checkbox]
Note, Linux: Pre-installed, but if not use `yum install scp` (Red Hat, Fedora, CentOS) or `apt-get install openssh-server` (Ubuntu, Mint, Debian)
Note, Windows: You're on your own!  Install Linux?

If those E2E (.xml) files extracted to a subdirectory, move them up a level
```bash
mv UNNECESSARY_SUBDIRECTORY/* .
```

Navigate to the directory with relay-service.rb
```bash
cd /home/app/endpoint/util/
```
OR `cd ..`

Start the relay service and push it to the background with `&`
```bash
./relay-service.rb &
```

Note: Press Enter once if not returned to a terminal prompt
Note: Forgetting the & will leave you starting at web server logs indefinitely!

Use lynx to begin the import, which usually takes around 15 minutes
```bash
lynx http://localhost:3000
```

Leave the docker container
```bash
exit
```

## Playing

Start the Hub API from Vagrant
```bash
cd /home/vagrant/hubapi
MONGO_URI=mongodb://localhost:27019/query_composer_development npm start
```

Visit one of the components in your web browser:

* Auth: [https://auth.scoop.local:8080]()
* Provider: [https://provider.scoop.local:8081/api]()
* Visualizer: [https://visualizer.scoop.local:8082]()
* Hub: [https://hub.scoop.local:8083]()
* Endpoint: [https://endpoint.scoop.local:8084]()


## Troubleshooting

### "make run" Returns "already assigned" ... "Error 1"

A container being run is already running.  You can fix this with one of the following methods:

1. Start the containers manually
```bash
docker start hubapi
docker start visualizer
docker start hub-db
docker start hub
docker start endpoint-db
docker start endpoint
```

2. Type `docker ps -a` to see a list of containers.  Stop them manually and run `make run` again.  
```bash
docker stop hubapi
docker stop visualizer
docker stop hub-db
docker stop hub
docker stop endpoint-db
docker stop endpoint
make run
```

### Pulling the Images

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
