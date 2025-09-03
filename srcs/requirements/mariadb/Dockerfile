FROM debian:bookworm

# Install MariaDB and dependencies
RUN apt-get update && apt-get install -y \
    mariadb-server mariadb-client procps && \
    rm -rf /var/lib/apt/lists/*

# Ensure MySQL user owns the data directory
RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

# Copy MariaDB configuration
COPY conf/my.cnf /etc/mysql/my.cnf

# Copy initialization script
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

# Expose MariaDB port
EXPOSE 3306

# Start MariaDB with initialization script
ENTRYPOINT ["/bin/bash", "/usr/local/bin/init_db.sh"]