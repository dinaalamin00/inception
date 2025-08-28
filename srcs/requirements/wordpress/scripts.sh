#!/bin/bash
set -e

#wordpress environmwnt variables
: "${WP_DB_HOST=mariadb}"
: "${WP_DB_NAME-wordpress}"
: "${WP_DB_USER=wp_user}"
: "${WP_DB_PASSWORD=wp_pass}"

# Wait for Database Availability until …; do … done
# WordPress needs the database to exist before starting.
# This loop tries to connect to the DB every 2 seconds until it succeeds.
# Avoids PHP errors if WordPress starts before MariaDB is ready.
# This tries to connect to the database using the MySQL client.
# Flags explained:
# -h"$WP_DB_HOST" → database host (e.g., mariadb)
# -u"$WP_DB_USER" → database username
# -p"$WP_DB_PASSWORD" → password for that user
# -e "SELECT 1;" → execute a simple SQL command (SELECT 1;) and exit immediately
# If the connection fails (DB not ready yet), the command returns a non-zero exit code, which keeps the loop running.
# >/dev/null 2>&1
# >/dev/null → discard standard output (don’t show it in logs)
# 2>&1 → redirect standard error to standard output (also discard errors)
# ✅ This makes the loop quiet, only printing the echo messages you add (like Waiting for database...).
# Wait 2 seconds before trying again.
echo "waiting for database to be ready..."
until mysql -h"$WP_DB_HOST" -u"$WP_DB_USER" -p"$WP_DB_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done
echo "database is ready!"

# Generate wp-config.php if Missing
if [! -f wp-config.php]; then
    echo "creating wp-config.php..."
    cp wp-config-sample.php wp-config.php
    sed -i "s/database_name_here/$WP_DB_NAME/" wp-config.php
    sed -i "s/username_here/$WP_DB_USER/" wp-config.php
    sed -i "s/password_here/$WP_DB_PASSWORD/" wp-config.php
    sed -i "s/localhost/$WP_DB_HOST/" wp-config.php
fi

# Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Run optional initialization scripts
for f in /docker-entrypoint-initwp.d/*; do
    case "$f" in
        *.sh)  echo "Running $f"; . "$f" ;;
        *.sql) echo "Running $f"; mysql -h"$WP_DB_HOST" -u"$WP_DB_USER" -p"$WP_DB_PASSWORD" "$WP_DB_NAME" < "$f" ;;
        *)     echo "Ignoring $f" ;;
    esac
done

# Start PHP-FPM
exec "$@"