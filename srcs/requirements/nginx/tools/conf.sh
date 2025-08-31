#!/bin/bash

# Generate nginx.conf dynamically using environment variables
cat > /etc/nginx/sites-available/default <<EOL
server {
    listen 443 ssl;
    server_name ${DOMAIN_NAME};

    ssl_certificate /etc/nginx/ssl/${DOMAIN_NAME}.crt;
    ssl_certificate_key /etc/nginx/ssl/${DOMAIN_NAME}.key;

    location / {
        proxy_pass http://wordpress:9000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOL

exec "$@"
