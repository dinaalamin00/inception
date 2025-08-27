FROM wordpress:php7.4-fpm

ENV WORDPRESS_DB_HOST=db
ENV WORDPRESS_DB_USER=user
ENV WORDPRESS_DB_PASSWORD=userpassword
ENV WORDPRESS_DB_NAME=mydatabase

VOLUME /var/www/html

COPY custom-config.php /usr/src/wordpress/wp-content/
