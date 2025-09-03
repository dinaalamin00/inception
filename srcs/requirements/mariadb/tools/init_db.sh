#!/bin/bash
set -e

# Initialize MariaDB data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    chown -R mysql:mysql /var/lib/mysql
fi

# Start MariaDB in background for setup
mysqld_safe &

# Wait until MariaDB is ready
until mysqladmin ping --silent 2>/dev/null; do
    echo "Waiting for MariaDB to start..."
    sleep 2
done
echo "MariaDB is ready!"

# Configure root user
if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    echo "Setting up root user..."
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
fi

# Create database if specified
if [ -n "$MYSQL_DATABASE" ]; then
    echo "Creating database $MYSQL_DATABASE..."
    mysql -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"
fi

# Create non-root user (e.g., diahmed_user)
if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
    echo "Creating user $MYSQL_USER..."
    mysql -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
    mysql -e "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';"
fi

# Flush privileges to apply changes
mysql -e "FLUSH PRIVILEGES;"

# Stop background MariaDB process
mysqladmin shutdown

# Run MariaDB in foreground
exec mysqld_safe