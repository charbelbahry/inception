FROM alpine:3.23

ARG DOMAIN_NAME 

RUN apk update && \
	apk add \
	nginx \
	openssl \
	bash

RUN mkdir -p /etc/nginx/ssl \
	&& openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=FR/L=Paris/O=42/CN=${DOMAIN_NAME}"

COPY conf/default.conf /etc/nginx/http.d/default.conf
RUN sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/" /etc/nginx/http.d/default.conf

EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]
