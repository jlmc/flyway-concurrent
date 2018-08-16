#!/bin/sh

mvn clean package && docker rmi -f costax-flyway-concurrent:demo || true && docker build --no-cache -t costax-flyway-concurrent:demo .
# docker rm -f flyway-concurrent || true && docker run -d -p 8080:8080 -p 9990:9990 --name flyway-concurrent costax-flyway-concurrent:demo

rm -rf .flyway-concurrent-postgres-stack

mkdir .flyway-concurrent-postgres-stack

docker swarm init

# docker stack deploy --compose-file docker-stack.yml fc

# docker service logs fc_flyway-concurrent-server -f

# docker stack rm fc

# docker swarm leave --force