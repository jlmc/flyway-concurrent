FROM jboss/wildfly:11.0.0.Final


ENV INSTALL_DIR /opt/jboss
ENV WILDFLY_HOME ${INSTALL_DIR}/wildfly
ENV DEPLOYMENT_DIR ${WILDFLY_HOME}/standalone/deployments

# Add customization resources
#ADD ./docker/wildfly/config-wildfly.sh ./docker/wildfly/configure-postgres.cli ${WILDFLY_HOME}/customization/

# Execute the customization commands
#RUN ["/opt/jboss/wildfly/customization/config-wildfly.sh"]

# Run cleanup
RUN rm -rf ${WILDFLY_HOME}/standalone/configuration/standalone_xml_history ${WILDFLY_HOME}/standalone/data ${WILDFLY_HOME}/standalone/log ${WILDFLY_HOME}/standalone/tmp


COPY ./target/flyway-concurrent.war ${DEPLOYMENT_DIR}


ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
EXPOSE 8080 9990
