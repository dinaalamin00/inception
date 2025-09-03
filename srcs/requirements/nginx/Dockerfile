FROM debian:bookworm

# Install NGINX and OpenSSL
RUN apt-get update && apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Copy configuration script
COPY tools/conf.sh /usr/local/bin/conf.sh
RUN chmod +x /usr/local/bin/conf.sh

# Remove default NGINX site
RUN rm -f /etc/nginx/sites-enabled/default

# Expose port 443
EXPOSE 443

# Start NGINX with configuration script
ENTRYPOINT ["/usr/local/bin/conf.sh"]
CMD ["nginx", "-g", "daemon off;"]