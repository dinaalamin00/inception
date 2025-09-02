FROM debian:bookworm
USER root

RUN apt-get update && apt-get install -y mariadb-server mariadb-client

COPY scripts.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/scripts.sh

ENTRYPOINT ["bash", "/usr/local/bin/scripts.sh"]
