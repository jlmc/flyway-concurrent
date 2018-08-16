# flyway-concurrent


#### to see if the application is running 

http://localhost:8080/flyway-concurrent/resources/messages


docker run --name flyway-concurrent-local-db -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=demodb -v "$(pwd)/.flyway-concurrent-demodb:/var/lib/postgresql/data" -d postgres:10.5


## execute stack


``` bash
rm -rf .flyway-concurrent-postgres-stack

mkdir .flyway-concurrent-postgres-stack

docker swarm init

docker stack deploy --compose-file docker-stack.yml fc


# docker swarm leave --force

# docker stack rm fc
```


http://localhost:8080/flyway-concurrent/resources/matrices


``` bash
curl -i -H "Xtenant: client5" http://localhost:8080/flyway-concurrent/resources/matrices



```