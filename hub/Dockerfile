# A Dockerfile!
FROM phusion/passenger-ruby19


### Stuff we need
RUN apt-get update && \
    apt-get --yes install ntp libxslt-dev libxml2-dev autossh

### Add Unprivilaged autossh account for tunneling.
# NOTE: Remove `|| true` when https://github.com/dotcloud/docker/issues/6345 is closed.
RUN adduser --disabled-password autossh || true

### ENV and User
USER app
ENV HOME /home/app/

### Install endpoint software.
WORKDIR /home/app
RUN git clone git://github.com/scoophealth/query-composer.git
WORKDIR /home/app/query-composer
RUN bundle install --path vendor/bundle && \
    mkdir -p /home/app/query-composer/tmp/pids && \
    sed -i -e "s/localhost:27017/database:27017/" config/mongoid.yml

### Change back to root
USER root

ADD scripts/hub.sh /etc/service/hub/run
RUN chmod +x /etc/service/hub/run

### Expose Port
EXPOSE 30308 13001 3002

### Run Command
CMD ["/sbin/my_init"]


###
# Using SELinux?
# --------------
# chcon -Rt svirt_sandbox_file_t $(pwd)/db
###
# Starting
# --------
# NAME="hub-1"
# docker run -d --name=$NAME -p 13001:13001 -p 30308:30308 -p 3002:3002 hub
###
# Backing up the Database
# -----------------------
# PORT=$(docker port $NAME 27017 | awk '{split($0,a,":"); print a[2]}')
# docker run --rm --link $NAME\:target -v $(pwd)/db:/restore mongo mongorestore -p $PORT -h target /restore
###
# Namespace entering
# ------------------
# sudo nsenter --target $(docker inspect --format {{.State.Pid}} $NAME) --mount --uts --ipc --net --pid /bin/bash
###
# In the namespace:
# -----------------
# su app
# cd /home/app/query-composer/
# bundle exec rake hquery:users:grant_admin USER_ID=$USER
###
