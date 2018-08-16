#!/bin/sh
mvn clean package && docker build -t costax-flyway-concurrent:demo .
docker rm -f flyway-concurrent || true && docker run -d -p 8080:8080 -p 9990:9990 --name flyway-concurrent costax-flyway-concurrent:demo