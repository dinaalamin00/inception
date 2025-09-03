FROM debian:bookworm

# Install necessary packages: PHP-FPM, MariaDB client, and wp-cli
RUN apt-get update && apt-get install -y \
    php-fpm php-mysql mariadb-client wget && \
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp && \
    rm -rf /var/lib/apt/lists/*

# Ensure PHP-FPM PID and log directories exist
RUN mkdir -p /run/php /var/log/php-fpm && chown www-data:www-data /run/php /var/log/php-fpm

# Set working directory
WORKDIR /var/www/html

# Download and set up WordPress
RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Copy PHP-FPM configuration
COPY conf/php-fpm.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copy initialization script
COPY tools/init_wp.sh /usr/local/bin/init_wp.sh
RUN chmod +x /usr/local/bin/init_wp.sh

# Expose PHP-FPM port
EXPOSE 9000

# Use entrypoint script to initialize and start PHP-FPM
ENTRYPOINT ["/usr/local/bin/init_wp.sh"]
CMD ["php-fpm8.2", "-F"]