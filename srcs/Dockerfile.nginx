FROM debian:bullseye

RUN apt -y update 
RUN apt install -y nginx 
RUN apt upgrade -y openssl

COPY ./requirements/nginx/tools/conf.sh /usr/local/bin/conf.sh
RUN chmod +x /usr/local/bin/conf.sh

ENTRYPOINT ["conf.sh"]