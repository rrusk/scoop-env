### A Dockerfile!
FROM phusion/passenger-ruby19

### Stuff we need
RUN apt-get update
RUN apt-get --yes install nodejs 
RUN apt-get --yes install mongodb  
#install nodejs should also install npm
 
#---http://serverfault.com/questions/529385/the-following-packages-have-unmet-dependencies-nodejs-conflicts-npm

### ENV and User
USER app
ENV HOME /home/app/

### Install endpoint software.
WORKDIR /home/app
RUN git clone https://github.com/PhysiciansDataCollaborative/hubapi
WORKDIR /home/app/hubapi

### Change back to root
USER root

ADD scripts/hubapi.sh /etc/service/hubapi/run
RUN chmod +x /etc/service/hubapi/run

### Expose Ports
EXPOSE 3003 22

### Run Command
CMD ["/sbin/my_init"]


###
# Using SELinux?
# --------------
# chcon -Rt svirt_sandbox_file_t $(pwd)/db
###
# Starting
# --------
# NAME="endpoint-1"
# docker run --name=$NAME -d -p 3001:3001 -p 22:22 -p 27017 --link hub-1:hub endpoint
#
### Backing up the DB
# -------------------
# PORT=$(docker port $NAME 27017 | awk '{split($0,a,":"); print a[2]}')
# docker run --rm --link $NAME\:target -v $(pwd)/db:/restore mongo mongorestore -p $PORT -h target /restore
###
# Namespace entering
# ------------------
# sudo nsenter --target $(docker inspect --format {{.State.Pid}} $NAME) --mount --uts --ipc --net --pid /bin/bash
