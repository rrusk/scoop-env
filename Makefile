################
# General Jobs #
################
all: build run
	
pull: pull-mongo pull-phusion

build: build-visualizer build-hubapi build-hub build-endpoint

run: run-hub run-endpoint run-hubapi run-visualizer 

remove: remove-endpoint remove-hub remove-visualizer remove-hubapi

clean:
	docker rmi scoop/hub scoop/endpoint scoop/visualizer scoop/hubapi

database-populate:
	# mongorestore --port 27018 data/visualizer-dump/
	mongorestore --drop --port 27019 data/hub-dump/

hosts:
	# You *must* sudo this.
	echo "127.0.0.1		hubapi.scoop.local" >> /etc/hosts
	echo "127.0.0.1		visualizer.scoop.local " >> /etc/hosts
	echo "127.0.0.1		hub.scoop.local" >> /etc/hosts
	echo "127.0.0.1		endpoint.scoop.local" >> /etc/hosts

############
# Run Jobs #
############
run-hubapi:
	#docker run -d -t -i --name hubapi-db -p 27017:27017 mongo
	#sleep 2 && mongorestore data/hubapi-dump/
	docker run -d -t -i --name hubapi -p 8081:8080 --link hub-db:database hubapi

run-visualizer:
	docker run -d -t -i --name visualizer-db -p 27018:27017 mongo
	docker run -d -t -i --name visualizer -h visualizer.scoop.local -p 0.0.0.0:8082:8080 -p 127.0.0.1:8888:8888 --link hubapi:hubapi.scoop.local --link visualizer-db:database scoop/visualizer

run-hub:
	docker run -d -t -i --name hub-db -p 27019:27017 mongo
	docker run -d -t -i --name hub -p 8083:3002 --link hub-db:database scoop/hub
	sleep 20
	mongorestore -v --port 27019 hub/db
	#docker run --rm -ti --link hub:hub -v $(pwd)/hub/db:/backup mongo mongorestore -p 27019 -h hub-db /backup
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

remove-hubapi:
	docker stop hubapi-db || true
	docker rm hubapi-db || true
	docker stop hubapi || true
	docker rm hubapi || true

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
