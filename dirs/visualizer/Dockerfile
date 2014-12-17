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
RUN git clone https://github.com/PhyDaC/visualizer
WORKDIR /home/app/visualizer

### Change back to root
USER root

### Add scripts
ADD scripts/visualizer.sh /etc/service/visualizer/run
RUN chmod +x /etc/service/visualizer/run

### Expose Ports
EXPOSE 3004 22

### Run Command
CMD ["/sbin/my_init"]

