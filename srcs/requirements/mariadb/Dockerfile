# ----- Dockerfile mariadb -----
FROM debian:bookworm

ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD

ENV MYSQL_DATABASE=${MYSQL_DATABASE}
ENV MYSQL_USER=${MYSQL_USER}
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD}

RUN apt-get update && apt-get install -y mariadb-server mariadb-client gosu

RUN echo "[mysqld]\nbind-address=0.0.0.0" > /etc/mysql/my.cnf

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld
RUN chown -R mysql:mysql /var/lib/mysql

COPY tools/init_db.sh /init_db.sh
RUN chmod +x /init_db.sh

EXPOSE 3306

ENTRYPOINT ["/init_db.sh"]
CMD ["mysqld", "--user=mysql"]
