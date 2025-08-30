#!/usr/bin/env bash

# Allow connections from any IP, not just localhost
# This is so WP can connect from a separate container
# Configure MariaDB to listen on all interfaces
if [ -n "$DB_CONF_ROUTE" ]; then
  echo >> "$DB_CONF_ROUTE"
  echo "[mysqld]" >> "$DB_CONF_ROUTE"
  echo "bind-address=0.0.0.0" >> "$DB_CONF_ROUTE"
fi
# Create database
mysql_install_db --datadir=$DB_INSTALL

# Start in bg (&)
mysqld_safe &
# Store pid for wait cmd
mysql_pid=$!

# Loop to check if MariaDB has started
# This prevents WP from connecting before MariaDB is ready
# Everything still works without this so it
# might not be necessary. Just a precaution
# but probably can be removed safely
until mysqladmin ping >/dev/null 2>&1; do
  echo -n "."; sleep 0.2
done

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Keeps container running until MariaDB process ends
wait $mysql_pid

