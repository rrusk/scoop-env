FROM jboss/keycloak
MAINTAINER Andrew Hobden <andrew@hoverbear.org>

ADD realms.json /tmp/realms.json
CMD ["/opt/wildfly/bin/standalone.sh", "-Dkeycloak.migration.action=import", "-Dkeycloak.migration.provider=singleFile", "-Dkeycloak.migration.file=/tmp/realms.json", "-b", "0.0.0.0"]
