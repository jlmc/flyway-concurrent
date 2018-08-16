#!/usr/bin/env bash

JBOSS_HOME=/opt/jboss/wildfly
JBOSS_CUSTOMIZATION=$JBOSS_HOME/customization
JBOSS_STANDALONE_CONFIG=$JBOSS_HOME/standalone/configuration/
JBOSS_CLI=$JBOSS_HOME/bin/jboss-cli.sh
JBOSS_MODE=${1:-"standalone"}
JBOSS_CONFIG=${2:-"$JBOSS_MODE.xml"}

function wait_for_server() {
  until `$JBOSS_CLI -c ":read-attribute(name=server-state)" 2> /dev/null | grep -q running`; do
    sleep 1
  done
}

echo "=====> Install Keycloak Adapter"
curl --location --output /opt/jboss/wildfly/keycloak-wildfly-adapter-dist-3.4.3.Final.zip --url \
    https://downloads.jboss.org/keycloak/3.4.3.Final/adapters/keycloak-oidc/keycloak-wildfly-adapter-dist-3.4.3.Final.zip \
    && unzip /opt/jboss/wildfly/keycloak-wildfly-adapter-dist-3.4.3.Final.zip  -d /opt/jboss/wildfly \
    && /opt/jboss/wildfly/bin/jboss-cli.sh --file=/opt/jboss/wildfly/bin/adapter-elytron-install-offline.cli \
    && rm -rf /opt/jboss/wildfly/keycloak-wildfly-adapter-dist-3.4.3.Final.zip


echo "=====> Starting WildFly server"
$JBOSS_HOME/bin/$JBOSS_MODE.sh -b 0.0.0.0 -c $JBOSS_CONFIG &

echo "=====> Waiting for the server to boot"
wait_for_server

echo "=====> Download PostgreSQL JDBC driver"
curl --location --output $(pwd)/postgresql-42.1.4.jar --url https://jdbc.postgresql.org/download/postgresql-42.1.4.jar

echo "=====> Configure PostgreSQL JDBC driver module and add datasource"
$JBOSS_CLI -c --file=`dirname "$0"`/configure-postgres.cli

echo "=====> Configure Undertow custom definitions"
$JBOSS_CLI -c --file=`dirname "$0"`/configure-undertow.cli

echo "=====> Add Administration Wildfly user"
/opt/jboss/wildfly/bin/add-user.sh admin admin

echo '=====> Remove PostgreSQL JDBC driver'
rm -rf /opt/jboss/postgresql-42.1.4.jar

echo "=====> Shutting down WildFly"
if [ "$JBOSS_MODE" = "standalone" ]; then
  $JBOSS_CLI -c ":shutdown"
else
  $JBOSS_CLI -c "/host=*:shutdown"
fi