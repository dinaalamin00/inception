FROM debian:bookworm

RUN apt -y update && apt install -y nginx openssl && apt clean

# Copy SSL certificates and configuration script
COPY tools/conf.sh /usr/local/bin/conf.sh
RUN chmod +x /usr/local/bin/conf.sh

# Ensure the default site is cleared
RUN rm -f /etc/nginx/sites-enabled/default

# Expose port 443
EXPOSE 443

ENTRYPOINT ["/usr/local/bin/conf.sh"]
CMD ["nginx", "-g", "daemon off;"]
