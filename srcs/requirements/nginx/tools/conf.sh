#!/bin/bash
set -e

# Define SSL paths
# SSL_DIR="/etc/ssl/private"
# CERT="/etc/ssl/certs/nginx-selfsigned.crt"
# CERT_KEY="/etc/ssl/private/nginx-selfsigned.key"

# Ensure SSL directory exists
mkdir -p "$SSL_DIR"
mkdir -p "$SSL_CERT_DIR"

# Generate self-signed SSL certificate if it doesn't exist
if [ ! -f "$CERT" ] || [ ! -f "$CERT_KEY" ]; then
    openssl req -x509 -newkey rsa:2048 -days 365 -nodes \
        -keyout "$CERT_KEY" -out "$CERT" \
        -subj "/CN=$DOMAIN_NAME"
else
    echo "Certificate and key already exist"
fi

echo $CERT
echo $CERT_KEY
ls -R $SSL_DIR/../
# ls /var/www/html
# Generate NGINX configuration
cat > /etc/nginx/conf.d/default.conf <<EOL
server {
    listen 443 ssl;
    server_name localhost;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_certificate $CERT;
    ssl_certificate_key $CERT_KEY;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;

        # PHP only variables
        fastcgi_param REDIRECT_STATUS 200;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        
        # Timeout settings
        fastcgi_read_timeout 300;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
    }
}
EOL

# Test NGINX configuration
# nginx -T
# nginx -t

# Start NGINX
exec nginx -g "daemon off;"