FROM alpine:3.23

RUN apk update && \
    apk add --no-cache \
        mariadb \
        mariadb-client \
        bash

COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

COPY tools/mariadb_init.sh /usr/local/bin/mariadb_init.sh

RUN chmod +x /usr/local/bin/mariadb_init.sh

RUN mkdir -p /run/mysqld /var/lib/mysql /var/log/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb_init.sh"]
