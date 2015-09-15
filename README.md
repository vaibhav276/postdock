# postdock
Just-add-water debuggable postgres DB in a docker container

## Creating docker image

This repository contains a `Dockerfile` which is based on ubuntu:14.04 docker image, and installs all development and debugging dependencies/tools for postgres.
The source code of postgres lives outside the container(s) so that it is easy to edit using your favourite editor. When a container is created, the corresponding directories are mounted as volumes so that the source code is instantly available inside the container for building and debugging.
You can manage the source code independent of the docker images/containers.

0. [Install Docker](https://docs.docker.com/installation/)
1. Clone this repository
2. From root directory of this respository, run `./setup.sh` (This will clone latest postgres source into `postgres/source` directory)
3. Run `docker build -t vaibhav276/postdock .`

(Run `docker images` to view the image just created.)

## Postgres debugging setup
First, create a docker container in which we will debug postgres
```sh
docker create --name pg_dbg --user="root" -t -v $PWD/postgres:/home/docker/postgres -v $PWD/dbg_scripts:/home/docker/postgres/dbg_scripts vaibhav276/postdock
```
This will create a new container named `pg_dbg`. 

(To view all docker containers at any time, run `docker ps -a`. Refer [docker documentation](https://docs.docker.com/articles/basics/) for maintaining containers)

1. Configure postgres for debug build
  ```sh
  docker start pg_dbg && docker exec --user="root" -t pg_dbg /home/docker/postgres/dbg_scripts/1_configure.sh
  ```

2. make !
  ```sh
  docker start pg_dbg && docker exec --user="root" -t pg_dbg /home/docker/postgres/dbg_scripts/2_make.sh
  ```

Above steps will create a non-optimized (all symbols) build of postgres, which is ideal for debugging. Use following commands to play with the setup and debug.

#### (Re) initializing postgres DB
You must initialize postgres DB before you can do anything on it. It involves setting up a data directory accessible by `docker` user and running postgres `initdb` for that directory.

To initialize run following command:
```sh
docker start pg_dbg && docker exec --user="docker" -t pg_dbg /home/docker/postgres/dbg_scripts/3_reinitdb.sh
```
You can reinitialize it whenever you want to start with a clean slate by running above command. Every time you reinitialize, you will loose all existing data and databases.

#### Starting postgres server processes
Following command will start all required processes to run a postgres server
```sh
docker start pg_dbg && docker exec --user="docker" -d pg_dbg /home/docker/postgres/dbg_scripts/4_startdb.sh
```

#### View running postgres processes
To view postgres process running at any time in the container, run 
```sh 
docker start pg_dbg && docker exec --user="docker" -t pg_dbg ps -ef | grep postgres
```

#### Creating a database
A database must exists in the data directory, before we can connect using `psql`. Use following command to create a database:
```sh
docker start pg_dbg && docker exec --user="docker" -t pg_dbg createdb docker
```

#### Running `psql` in container
The docker image contains everthing required to debug postgres, including psql utility and gdb.

Run following command to start a new session using `psql` in the container:
```sh
docker start pg_dbg && docker exec --user="docker" -ti pg_dbg psql
```
**Note**: postgres DB process should be running for this to work.

To find out the process id of postgres instance which you want to debug, run this command from inside the `psql` session you just started:
```sql
select pg_backend_pid();
```
This process ID will be useful for gdb to attach to the process.

#### Running `gdb` in container
With the server running and an active `psql` session, you can attach to the corresponding postgres process by running follwing command: (Yes, you need to run it in a separate terminal session since the `psql` command occupies one terminal for itself)
```sh
docker exec --user="docker" -ti pg_dbg gdb -p <pid>
```

where, `<pid>` should be substituted by the actual PID of the postgres process you want to debug - the one which you got from running `select pg_backend_pid()` inside `psql`

**Thats it!! You are now debugging postgres entirely inside a disposible docker container !!**


#### Stopping postgres server processes
Below command will stop everything started by the startup script above, including the startup script itself, leaving your container clean:
```sh
docker start pg_dbg && docker exec --user="docker" -t pg_dbg /home/docker/postgres/dbg_scripts/0_stopdb.sh
```

#### Stopping the container
You can always treat a container as a disposable debug setup, and tear down everything once debugging is done. To remove the container, use following command:
```sh
docker stop pg_dbg
docker rm pg_dbg
```

To make sure you dont have any leftover containers lying around, you can again use `docker ps -a` command.

# Contributing
Please send a mail to vaibhav276@yahoo.co.in if you want to contribute

# Disclaimer
This readme is intentionally linear because I just wanted to define at least one way of setting up that always works with the least amount of documentation. So I used fixed names for containers etc. rather than having instructions to choose a name that you like.

# License
[WTFPL](http://www.wtfpl.net/txt/copying/)
