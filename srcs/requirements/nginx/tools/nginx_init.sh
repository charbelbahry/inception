#!/bin/bash
set -e

mkdir -p /etc/nginx/ssl /var/log/nginx

if [ ! -f /etc/nginx/ssl/nginx.crt ] || [ ! -f /etc/nginx/ssl/nginx.key ];
then
	echo "[+] Generating self-signed TLS certificate for ${DOMAIN_NAME:-cbahry.42.fr}..."
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/nginx.key \
		-out /etc/nginx/ssl/nginx.crt \
		-subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42Paris/CN=${DOMAIN_NAME:-cbahry.42.fr}"
	chmod 644 /etc/nginx/ssl/nginx.key
	chmod 644 /etc/nginx/ssl/nginx.crt
	echo "[+] TLS Certificate generated successfully"
fi

chown -R nginx:nginx /var/log/nginx /etc/nginx/ssl

echo "[+] Launching NGINX in foreground..."
exec nginx -g "daemon off;"
