################
# General Jobs #
################
all: build run
	
pull: pull-mongo pull-wildfly pull-keycloak pull-phusion

build: build-visualizer build-provider build-hub build-endpoint

run: run-hub run-endpoint run-provider run-visualizer 

remove: remove-endpoint remove-hub remove-visualizer remove-provider

clean:
	docker rmi scoop/hub scoop/endpoint scoop/visualizer scoop/provider

database-populate:
	# mongorestore --port 27018 data/visualizer-dump/
	mongorestore --drop --port 27019 data/hub-dump/

hosts:
	# You *must* sudo this.
	echo "127.0.0.1		provider.scoop.local" >> /etc/hosts
	echo "127.0.0.1		visualizer.scoop.local " >> /etc/hosts
	echo "127.0.0.1		hub.scoop.local" >> /etc/hosts
	echo "127.0.0.1		endpoint.scoop.local" >> /etc/hosts

############
# Run Jobs #
############
run-provider:
	#docker run -d -t -i --name provider-db -p 27017:27017 mongo
	#sleep 2 && mongorestore data/provider-dump/
	docker run -d -t -i --name provider -h provider.scoop.local -p 0.0.0.0:8081:8080 -p 127.0.0.1:8889:8888 --link hub-db:database scoop/provider

run-visualizer:
	docker run -d -t -i --name visualizer-db -p 27018:27017 mongo
	docker run -d -t -i --name visualizer -h visualizer.scoop.local -p 0.0.0.0:8082:8080 -p 127.0.0.1:8888:8888 --link provider:provider.scoop.local --link visualizer-db:database scoop/visualizer

run-hub:
	docker run -d -t -i --name hub-db -p 27019:27017 mongo
	docker run -d -t -i --name hub -p 8083:3002 --link hub-db:database scoop/hub

run-endpoint:
	docker run -d -t -i --name endpoint-db -p 27020:27017 mongo
	docker run -d -t -i --name endpoint -p 8084:3001 --link hub:hub --link endpoint-db:database scoop/endpoint
	sleep 10 && util/inject_key.sh

###############
# Remove Jobs #
###############
remove-endpoint:
	docker stop endpoint-db || true
	docker rm endpoint-db || true
	docker stop endpoint || true
	docker rm endpoint || true

remove-hub:
	docker stop hub-db || true
	docker rm hub-db || true
	docker stop hub || true
	docker rm hub || true

remove-visualizer:
	docker stop visualizer-db || true
	docker rm visualizer-db || true
	docker stop visualizer || true
	docker rm visualizer || true

remove-provider:
	docker stop provider-db || true
	docker rm provider-db || true
	docker stop provider || true
	docker rm provider || true

##############
# Build Jobs #
##############
build-hubapi:
	cd hubapi && docker build -t hubapi .

build-visualizer:
	cd visualizer && docker build -t scoop/visualizer .

build-hub:
	docker build -t scoop/hub hub/

build-endpoint:
	docker build -t scoop/endpoint endpoint/

#############
# Pull Jobs #
#############
pull-mongo:
	docker pull mongo

pull-wildfly:
	docker pull jboss/keycloak-adapter-wildfly

pull-keycloak:
	docker pull jboss/keycloak

pull-phusion:
		docker pull phusion/passenger-ruby19
