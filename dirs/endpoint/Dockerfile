### A Dockerfile!
FROM phusion/passenger-ruby19

### Stuff we need
RUN apt-get update && \
    apt-get --yes install ntp libxslt-dev libxml2-dev autossh

### ENV and User
USER app
ENV HOME /home/app/

### Install endpoint software.
WORKDIR /home/app
RUN git clone https://github.com/scoophealth/query-gateway endpoint
WORKDIR /home/app/endpoint
RUN bundle install --path vendor/bundle && \
    mkdir -p /home/app/endpoint/tmp/pids && \
    sed -i -e "s/localhost:27017/database:27017/" config/mongoid.yml

### Change back to root
USER root

ADD scripts/endpoint.sh /etc/service/endpoint/run
RUN chmod +x /etc/service/endpoint/run

ADD scripts/keys.sh /etc/service/keys/run
RUN chmod +x /etc/service/keys/run

### AutoSSH
ADD scripts/start_admin_tunnel.sh /etc/service/admin_tunnel/run
RUN chmod +x /etc/service/admin_tunnel/run
ADD scripts/start_endpoint_tunnel.sh /etc/service/endpoint_tunnel/run
RUN chmod +x /etc/service/endpoint_tunnel/run #

ADD EMRConversion.zip /home/app/
ADD scripts/* /home/app/endpoint/script/

### Expose Ports
EXPOSE 3001 22

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
