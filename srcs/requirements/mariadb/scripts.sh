# cmd - 1
    # ensure the scirpt runs in bash
    # the first 2 characters is called shebang,
    # shebang is the first line in a script filethat tells the operating system which interpreter to use to run the script
# cmd - 2
    # add safety options to stop the script immediately if anycommand fails, preventing silent errors
# cmd - 3
    # initialize the database if empty
    # 1 checks if the database directory is empty ( -d<paht> returns true if the directory exists)
    # 3 tells mariadb to initialize the data directory without setting a root password
    # why "insecure"? the root has not password after initialization,
        # the root password is set later in the script 
    # --initialize (wihtou insecure) generates a random root password
    # --user=mysql insures the mariadb runs the initialization process as the mysql system user, not root
        #important for correct file permissions in /var/lib/mysql so the server can read/write data properly
# cmd - 4
    # create root user and optional database/user
    # -n tests id the dtring is not empty
    # mysql runs the MySQL command-line client
    # -e allows executing a single SQL command directly without opening an interactive shell
    # "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" change the password of the root to the one in the env
    # 'root'@'localhost' refers to the root user connecting from the localhost

#!/bin/bash
set -e
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql --initialize-insecure --user=mysql
fi
if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    echo "Setting uo root user..."
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
fi
# Optional database
if [ -n "$MYSQL_DATABASE" ]; then
    echo "Creating database $MYSQL_DATABASE..."
    mysql -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
fi

# Optional non-root user
if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
    echo "Creating user $MYSQL_USER..."
    mysql -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
    mysql -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
fi

for f in /docker-entrypoint-initdb.d/*; do
    case "$f" in
        *.sh)  echo "Running $f"; . "$f" ;;
        *.sql) echo "Running $f"; mysql < "$f" ;;
        *)     echo "Ignoring $f" ;;
    esac
done

exec mysqld