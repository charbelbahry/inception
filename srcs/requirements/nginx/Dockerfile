FROM alpine:3.23

RUN apk update && \
	apk add --no-cache \
	nginx \
	openssl \
	bash

RUN rm -rf /etc/nginx/http.d/default.conf

COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY tools/nginx_init.sh /usr/local/bin/nginx_init.sh
RUN chmod +x /usr/local/bin/nginx_init.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/nginx_init.sh"]
