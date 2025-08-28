# since we're building it from scratch by installing it via package manager(apt),
# we need full control over dependencies, versions, and configuration
# we can;t use pre-built DB images, so we use debian/alpine

FROM debian:bullseye

# install mariadb server and client
# the server is an actual database engine that listens on port 3306
# the server handles data storage, queries, authentication, and database operations.
# without the server there is no running database.
# the client is a command-line tool(mysql) used to connect to the server
# it allows to test database connectivity inside the container
# it allows running SQL commands manually
# it allows performing administrative tasks during setup(creating databaase, users)
# the client is not always required for production, but useful dor debugging and initialization
# ' -y ' assumes "yes"to all prompts, without it the installation may pause
# in docker builds interaction is not possible so -y isures automatic installation
RUN apt-get update && apt-get install -y mariadb-server mariadb-client

# Cleans up cached package lists to reduce image size.
RUN rm -rf /var/lib/apt/lists/* 

# when you create a mariadb container, certain environment variables helps configure the database on the first setup
# these env-var are mainly used for automated initialization
# - root user password (required)
ENV MYSQL_ROOT_PASSWORD=rootpassword
# - create database automatically at startup (optional)
ENV MYSQL_DATABASE=mydb
# - creat a new non-root user (optional)
ENV MYSQL_USER=myuser
# -  user(MYSQL_USER) password (optional)
ENV MYSQL_PASSWORD=mypass


# copy initialization script to allow the container to automatically run custom setup tasks the first time it starts
# initialization scrpits are SQL files(.sql) or shell scripts(.sh)
# its placede in a special directory (/docker-entrypoint-initdb.d/)
# when mariadb starts it automatically executes them in alphabetical order
# why we need them?
# - automated database setup: create database, tables, schemas automatically. eg, pre-create users table
# - user and permission management
# - insert initial data
# - consistent database: ensure every container starts with the same database state
COPY srcs/requirements/mariadb/init.sql /docker-entrypoint-initdb.d/

# make mariadb accessible from outside the container
EXPOSE 3306

# define a volume to store all db files, its stored in the container's filesystem(/var/lib/mysql  by default)
# if you remove or recreate the container all data is lost because containers are volatile
VOLUME /var/lib/mysql

# tell the container to run all the shell commands using bash instead of /bin/sh
# /bin/sh does not support some bash-specific features like arrays, source command, function keyword, and conditional tests('[[....]]')
# use bash to prevents errors caused by /bin/sh/
SHELL ["bash", "-c"]
# set entrypoint and cmd, to define what the container does when starts
# ENTRYPOIT: defines the main executable that always runs when the container starts
# for mariadb its typically a script that:
# - initialize the database directory (if empty)
# - run any initialization scripts (/docker-entrypoint-initdb.d/)
# - sets up users/passwords
# - finally starts the database server process
# first we copy files from the host to the image
# copy the file containing the script that sets up the mariadb when container starts
# /usr/local/bin/ is a standard directory for executable programs
# after copying change the executable permission to ensure the container can execute the script without any errors
COPY srcs/requirements/mariadb/scripts.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/scripts.sh
ENTRYPOINT ["/usr/local/bin/scripts.sh"]
# CMD provides default arguments to the ENTRYPOINT
# for mariadb this usually tells the container what process to run by default if not other command is specified
# use both; ENTRTPOINT to ensure the db always runs its setup logic(cannot be overridden accidentally)
            # CMD allows you to override the default command easilt if needed
CMD ["mysqld"]
# ["mysqld"] tells Docker to start the MariaDB server by default.