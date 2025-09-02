#!/bin/bash
set -e

# Read password from Docker secret

echo "Waiting for database to be ready..."
until mysql -h"$WORDPRESS_DB_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
    echo "Database not ready, retrying..."
    sleep 2
done
echo "Database is ready!"

# Generate wp-config.php if missing
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    sed -i "s/database_name_here/$MYSQL_DATABASE/" /var/www/html/wp-config.php
    sed -i "s/username_here/$MYSQL_USER/" /var/www/html/wp-config.php
    sed -i "s/password_here/$MYSQL_PASSWORD/" /var/www/html/wp-config.php
    sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php
fi

# Set permissions for WordPress files
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Check if WordPress is installed, and set up admin user if not
if ! wp core is-installed --path=${WP_ROUTE} --allow-root; then
    echo "Installing WordPress..."
    wp core install \
        --path=${WP_ROUTE} \
        --url=${WP_URL} \
        --title=${WP_TITLE} \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASS} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root
fi

# Start PHP-FPM
exec "$@"