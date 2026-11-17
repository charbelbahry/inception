FROM alpine:3.23

RUN apk update && \
    apk add \
        mariadb \
        mariadb-client \
        bash

COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

COPY tools/mariadb_init.sh /usr/local/bin/mariadb_init.sh

RUN chmod +x /usr/local/bin/mariadb_init.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb_init.sh"]
