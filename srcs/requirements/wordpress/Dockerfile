FROM debian:bullseye

# Install necessary packages: PHP-FPM, MariaDB client, and wp-cli
RUN apt-get update && apt-get install -y \
    php-fpm php-mysql mariadb-client wget && \
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Download and set up WordPress
RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Copy PHP-FPM configuration
COPY conf/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf

# Copy initialization script
COPY scripts.sh /usr/local/bin/scripts.sh
RUN chmod +x /usr/local/bin/scripts.sh

# Expose PHP-FPM port
EXPOSE 9000

# Use entrypoint script to initialize and start PHP-FPM
ENTRYPOINT ["/usr/local/bin/scripts.sh"]
CMD ["php-fpm7.4", "-F"]