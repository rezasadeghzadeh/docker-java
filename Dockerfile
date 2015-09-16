FROM ubuntu

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common

RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:openjdk-r/ppa
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y openjdk-8-jdk

ENV MYSQL_USER=mysql \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql

RUN apt-get install -y mysql-server \
 && rm -rf ${MYSQL_DATA_DIR} \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh


EXPOSE 3306/tcp
VOLUME ["${MYSQL_DATA_DIR}", "${MYSQL_RUN_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/bin/mysqld_safe"]
