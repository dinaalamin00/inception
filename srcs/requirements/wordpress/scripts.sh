#!/bin/bash
set -e

echo "waiting for database to be ready..."
until mysql -h"$WORDPRESS_DB_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done
echo "database is ready!"

# Generate wp-config.php if Missing
if [! -f wp-config.php]; then
    echo "creating wp-config.php..."
    cp wp-config-sample.php wp-config.php
    sed -i "s/database_name_here/$MYSQL_DATABASE/" wp-config.php
    sed -i "s/username_here/$MYSQL_USER/" wp-config.php
    sed -i "s/password_here/$MYSQL_PASSWORD/" wp-config.php
    sed -i "s/localhost/$WORDPRESS_DB_HOST/" wp-config.php
fi

# Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Run optional initialization scripts
for f in /docker-entrypoint-initwp.d/*; do
    case "$f" in
        *.sh)  echo "Running $f"; . "$f" ;;
        *.sql) echo "Running $f"; mysql -h"$WORDPRESS_DB_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < "$f" ;;
        *)     echo "Ignoring $f" ;;
    esac
done

# Start PHP-FPM
exec "$@"

 