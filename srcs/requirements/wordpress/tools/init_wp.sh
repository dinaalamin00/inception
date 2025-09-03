#!/bin/bash

# set -e

# echo "Waiting for database to be ready..."
# until mysql -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
#     echo "Database not ready, retrying..."
#     sleep 2
# done
# echo "Database is ready!"

# # Generate wp-config.php if missing
# if [ ! -f /var/www/html/wp-config.php ]; then
#     echo "Creating wp-config.php..."
#     cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
#     sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
#     sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
#     sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
#     sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php
# fi

# cat /var/www/html/wp-config.php

# # Set permissions for WordPress files
# chown -R www-data:www-data /var/www/html
# chmod -R 755 /var/www/html

# # Check if WordPress is installed, and set up admin user if not
# if ! wp core is-installed --path=/var/www/html --allow-root; then
#     echo "Installing WordPress..."
#     wp core install \
#         --path=/var/www/html \
#         --url="https://diahmed.42.fr" \
#         --title="Inception Site" \
#         --admin_user="diahmed" \
#         --admin_password="$WORDPRESS_DB_PASSWORD" \
#         --admin_email="diahmed@student.42.fr" \
#         --allow-root
# fi

# # Ensure PHP-FPM socket is available
# if [ ! -d /run/php ]; then
#     mkdir -p /run/php
#     chown www-data:www-data /run/php
# fi

# # Start PHP-FPM
# exec php-fpm8.2 -F

# Execute everything in WP dir
cd $WP_ROUTE

# Download WP if missing, and allow running as root
wp core download --force --allow-root

# Generate WP config
wp config create --path=$WP_ROUTE --allow-root --dbname=$MYSQL_DATABASE --dbuser=$WORDPRESS_DB_USER --dbpass=$WORDPRESS_DB_PASSWORD --dbhost=$WORDPRESS_DB_HOST --dbprefix=wp_

# Install WP if not installed
# Set URL
# Set admin credentials
# Set new user with author role
if ! wp core is-installed --allow-root --path=$WP_ROUTE; then
wp core install --url=$WP_URL --title=$WP_TITLE --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email=$WP_ADMIN_EMAIL --allow-root
wp user create $WP_USER $WP_EMAIL --role=author --user_pass=$WP_PASS --allow-root
fi

# Start PHP in foreground to keep container running
exec php-fpm8.2 -F