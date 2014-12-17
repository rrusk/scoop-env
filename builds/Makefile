################
# General Jobs #
################
default: pull build run

all: pull build run
	
pull: pull-mongo pull-phusion

build: build-visualizer build-hubapi build-hub build-endpoint

run: run-hub run-endpoint run-hubapi run-visualizer 

remove: remove-endpoint remove-hub remove-visualizer remove-hubapi

clean:
	docker rmi scoop/hub scoop/endpoint scoop/visualizer scoop/hubapi

database-populate:
	# mongorestore --port 27018 data/visualizer-dump/
	mongorestore --drop --port 27019 data/hub-dump/

############
# Run Jobs #
############
run-hubapi:
	#docker run -d -t -i --name hubapi-db -p 27017:27017 mongo
	#sleep 2 && mongorestore data/hubapi-dump/
	docker run -d -t -i --name hubapi -p 8081:8080 --link hub-db:hub-db hubapi

run-visualizer:
	docker run -d -t -i --name visualizer-db -p 27018:27017 mongo
    #docker run -d -t -i --name visualizer -h visualizer.scoop.local -p 0.0.0.0:8082:8080 -p 127.0.0.1:8888:8888 --link hubapi:hubapi.scoop.local --link visualizer-db:database scoop/visualizer

run-hub:
	docker run -d -t -i --name hub-db -p 27019:27017 mongo
	docker run -d -t -i --name hub -p 8083:3002 --link hub-db:database scoop/hub
	sleep 20
	mongorestore -v --port 27019 hub/db #restore the first user - requires that mongo is installed on the host
	#docker run --rm -ti --link hub-db:hub-db -v $(`pwd`)/scoop-hub/db:/backup mongo mongorestore -v --port 27017 --host hub-db /backup
	#WARNING - the pwd portion of this command is not working
	#27017 because this is inter container communication
	#rm remove the container after the process completes
	#hub-db:hub-db hub-db container with alias hub-db .... hub-db at th end is a reference to the alias
	#note --port not -p ... -p is for password
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
	docker stop hubapi || true
	docker rm hubapi || true

##############
# Build Jobs #
##############
build-hubapi:
	docker build -t hubapi hubapi/	

build-visualizer:
	docker build -t visualizer visualizer/

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
