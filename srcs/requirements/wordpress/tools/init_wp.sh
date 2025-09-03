#!/bin/bash
set -e

echo "Waiting for database to be ready..."
until mysql -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
    echo "Database not ready, retrying..."
    sleep 2
done
echo "Database is ready!"

# Generate wp-config.php if missing
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
    sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
    sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
    sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php
fi

# Set permissions for WordPress files
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Check if WordPress is installed, and set up admin user if not
if ! wp core is-installed --path=/var/www/html --allow-root; then
    echo "Installing WordPress..."
    wp core install \
        --path=/var/www/html \
        --url="https://diahmed.42.fr" \
        --title="Inception Site" \
        --admin_user="diahmed" \
        --admin_password="$WORDPRESS_DB_PASSWORD" \
        --admin_email="diahmed@student.42.fr" \
        --allow-root
fi

# Ensure PHP-FPM socket is available
if [ ! -d /run/php ]; then
    mkdir -p /run/php
    chown www-data:www-data /run/php
fi

# Start PHP-FPM
exec php-fpm8.2 -F