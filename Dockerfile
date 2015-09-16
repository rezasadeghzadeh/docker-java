FROM ubuntu

###install  ssh server  ###
RUN mkdir -p /etc/init-services/sshd /var/run/sshd
RUN echo "#!/bin/bash\nexec /usr/sbin/sshd" > /etc/init-services/sshd/run
RUN chmod +x /etc/init-services/sshd/run
EXPOSE 22/tcp


RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common

RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:openjdk-r/ppa
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y openjdk-8-jdk openssh-server mysql-server daemontools

### install  mysql-server ###
ENV MYSQL_USER=mysql \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql

RUN rm -rf ${MYSQL_DATA_DIR} \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh


EXPOSE 3306/tcp
VOLUME ["${MYSQL_DATA_DIR}", "${MYSQL_RUN_DIR}"]

CMD ["/usr/bin/mysqld_safe"]

#### config  java  application  ###
ENV APP_NAME=argus \
	APP_USERNAME=argus \
	PASSWORD=argus \
	GROUP_NAME=argus


RUN mkdir /opt/${APP_NAME}  -p
RUN mkdir  /opt/${APP_NAME}/logs -p

RUN groupadd ${GROUP_NAME}
RUN adduser  ${APP_USERNAME} --ingroup ${GROUP_NAME} 
RUN echo "${APP_USERNAME}:${PASSWORD}" | chpasswd   
RUN chown ${APP_USERNAME}:${GROUP_NAME} /opt/${APP_NAME} -R

COPY testForDocker-1.0-SNAPSHOT-jar-with-dependencies.jar /opt/${APP_NAME}/


#ENTRYPOINT ["/sbin/entrypoint.sh"]
ENTRYPOINT /usr/bin/svscan /etc/init-services/
