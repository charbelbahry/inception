#!/bin/bash
set -e

mkdir -p /etc/ssl/certs /etc/ssl/private

if [ ! -f /etc/ssl/certs/nginx-selfsigned.crt ] || [ ! -f /etc/ssl/private/nginx-selfsigned.key ];
then
	echo "[+] Generating self-signed TLS certificate for ${DOMAIN_NAME:-cbahry.42.fr}..."
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/ssl/private/nginx-selfsigned.key \
		-out /etc/ssl/certs/nginx-selfsigned.crt \
		-subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42Paris/CN=${DOMAIN_NAME:-cbahry.42.fr}"
	chmod 644 /etc/ssl/private/nginx-selfsigned.key
	chmod 644 /etc/ssl/private/nginx-selfsigned.crt
	echo "[+] TLS Certificate generated successfully"
fi

mkdir -p /var/www/wordpress /var/log/nginx
chown -R nginx:nginx /var/log/nginx

echo "[+] Launching NGINX in foreground..."
exec nginx -g "daemon off;"
