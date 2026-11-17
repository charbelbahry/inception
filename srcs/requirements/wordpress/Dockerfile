FROM alpine:3.23

RUN apk update && \
	apk add \
        php84 php84-fpm php84-phar php84-mysqli php84-mbstring \
        php84-curl php84-openssl php84-iconv php84-tokenizer php84-ctype \
        php84-xml php84-dom php84-simplexml php84-xmlreader php84-gd \
        php84-zip php84-exif php84-fileinfo php84-intl php84-session \
        curl bash


RUN curl -o /usr/local/bin/wp \
	 https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x /usr/local/bin/wp

RUN sed -i 's/^memory_limit = .*/memory_limit = 512M/' /etc/php84/php.ini

COPY conf/www.conf /etc/php84/php-fpm.d/www.conf
COPY tools/wp_init.sh /usr/local/bin/wp_init.sh
RUN chmod +x /usr/local/bin/wp_init.sh

WORKDIR /var/www/html
EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp_init.sh"]
