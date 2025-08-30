

FROM debian:bullseye


# Install necessary packages: PHP, PHP-FPM, and WordPress dependencies
RUN apt-get update && apt-get install mariadb-client -y \
    php7.4 php7.4-fpm php7.4-mysql unzip curl wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN wget https://wordpress.org/latest.tar.gz\
    && tar -xvzf latest.tar.gz --strip-component=1\
    && rm latest.tar.gz

COPY scripts.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/scripts.sh

# Expose PHP-FPM port (default is 9000)
EXPOSE 9000

# Start PHP-FPM in foreground mode
ENTRYPOINT ["/usr/local/bin/scripts.sh"]

CMD ["php-fpm7.4", "-F"]
