#!/bin/bash

# Ensure SSL directory exists
mkdir -p "$SSL_DIR"

# Generate self-signed SSL certificate if it doesn't exist
if [ ! -f "$CERT" ] || [ ! -f "$CERT_KEY" ]; then
    openssl req -x509 -newkey rsa:2048 -days 365 -nodes \
    -keyout "$CERT_KEY" -out "$CERT" \
    -subj "/CN=${DOMAIN_NAME}"
fi

# Generate nginx.conf dynamically
cat > /etc/nginx/conf.d/default.conf <<EOL
server {
    listen 443 ssl;
    server_name ${DOMAIN_NAME};

    ssl_certificate ${CERT};
    ssl_certificate_key ${CERT_KEY};

    location / {
        proxy_pass http://wordpress:9000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location ~ \.php\$ {
        include fastcgi_params;
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOL

exec "$@"
