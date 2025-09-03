#!/bin/bash

# set -e

# # Initialize MariaDB data directory if it doesn't exist
# if [ ! -d "/var/lib/mysql/mysql" ]; then
#     echo "Initializing MariaDB data directory..."
#     mariadb-install-db --user=mysql --datadir=/var/lib/mysql
# fi
# chown -R mysql:mysql /var/lib/mysql

# DB_INSTALL="/var/lib/"

# # Start MariaDB in background for setup
# mysqld_safe &

# # Wait until MariaDB is ready
# until mysqladmin ping --silent 2>/dev/null; do
#     echo "Waiting for MariaDB to start..."
#     sleep 2
# done
# echo "MariaDB is ready!"

# # Configure root user
# if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
#     echo "Setting up root user..."
#     mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
# fi

# # Create database if specified
# if [ -n "$MYSQL_DATABASE" ]; then
#     echo "Creating database $MYSQL_DATABASE..."
#     mysql mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"
# fi

# # Create non-root user (e.g., diahmed_user)
# if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
#     echo "Creating user $MYSQL_USER..."
#     mysql mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
#     mysql mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';"
# fi

# # Flush privileges to apply changes
# mysql mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

# # Stop background MariaDB process
# mysqladmin shutdown

# # Run MariaDB in foreground
# exec mysqld_safe

set -e

# create run directory and set owner
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Ensure config file has required values
# if ! grep -q "^\[mysqld\]" "$DB_CONF_ROUTE"; then
#     echo "[mysqld]" >> "$DB_CONF_ROUTE"
# fi
# if ! grep -q "^bind-address=0.0.0.0" "$DB_CONF_ROUTE"; then
#     echo "bind-address=0.0.0.0" >> "$DB_CONF_ROUTE"
# fi

# # Adjust port and bind address if needed
# if grep -q "^# port = 3306" "$DB_CONF_ROUTE"; then
#     sed -i 's/^# port = 3306/port = 3306/' "$DB_CONF_ROUTE"
# fi

# if grep -q "127.0.0.1" /etc/mysql/mariadb.conf.d/50-server.cnf; then
#     sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
# fi

DB_INSTALL="/var/lib/mysql"
if [ ! -d "$DB_INSTALL/mysql" ]; then
  mysql_install_db --user=mysql --datadir="$DB_INSTALL" --rpm --auth-root-authentication-method=normal
fi

  cat > /tmp/init.sql <<-EOSQL
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS \`$WORDPRESS_DB_NAME\`;
CREATE USER IF NOT EXISTS '$WORDPRESS_DB_USER'@'%' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';
GRANT ALL PRIVILEGES ON \`$WORDPRESS_DB_NAME\`.* TO '$WORDPRESS_DB_USER'@'%';
CREATE USER IF NOT EXISTS '$WP_ADMIN_USER'@'%' IDENTIFIED BY '$WP_ADMIN_PASS';
GRANT ALL PRIVILEGES ON \`$WORDPRESS_DB_NAME\`.* TO '$WP_ADMIN_USER'@'%';
FLUSH PRIVILEGES;
EOSQL

  # Run bootstrap SQL once
  mysqld --user=mysql --datadir="$DB_INSTALL" --bootstrap < /tmp/init.sql
  rm -f /tmp/init.sql

# Finally start MariaDB normally in the foreground (container main process)
mysqld_safe --datadir="$DB_INSTALL"