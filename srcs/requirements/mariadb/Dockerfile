FROM debian:bullseye
USER root

RUN apt-get update && apt-get install -y mariadb-server mariadb-client
RUN rm -rf /var/lib/apt/lists/* 

COPY init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306

VOLUME /var/lib/mysql

SHELL ["bash", "-c"]

COPY scripts.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/scripts.sh

ENTRYPOINT ["bash", "/usr/local/bin/scripts.sh"]
