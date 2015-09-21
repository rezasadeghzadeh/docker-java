FROM ubuntu

ENV DAEMON_SERVICES_PATH=/etc/init-services
###install  ssh server  ###
RUN mkdir -p ${DAEMON_SERVICES_PATH}/sshd /var/run/sshd
RUN echo "#!/bin/bash\nexec /usr/sbin/sshd" > ${DAEMON_SERVICES_PATH}/sshd/run
RUN chmod +x ${DAEMON_SERVICES_PATH}/sshd/run
EXPOSE 22/tcp


RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common

RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:openjdk-r/ppa
RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update \
	&& apt-get install -y \
	openjdk-8-jdk \
	openssh-server \
	mysql-server \
	daemontools

### install  mysql-server ###
ENV MYSQL_USER=mysql \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql 

RUN rm -rf ${MYSQL_DATA_DIR} \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir ${DAEMON_SERVICES_PATH}/mysql -p
COPY mysql/run ${DAEMON_SERVICES_PATH}/mysql/
RUN chmod 755 ${DAEMON_SERVICES_PATH}/mysql/run


EXPOSE 3306/tcp
VOLUME ["${MYSQL_DATA_DIR}", "${MYSQL_RUN_DIR}"]
COPY db/argus_accedian.sql /tmp/
CMD /usr/bin/mysqld_safe

#### config  java  application  ###
ENV APP_NAME=argus \
	APP_USERNAME=argus \
	PASSWORD=argus \
	GROUP_NAME=argus 
				


RUN mkdir /opt/${APP_NAME}  -p
RUN mkdir  /opt/${APP_NAME}/log -p
RUN mkdir  /home/${APP_NAME}/upload -p
RUN mkdir  /opt/${APP_NAME}/conf.d -p
COPY conf.d/* /opt/${APP_NAME}/conf.d/
RUN groupadd ${GROUP_NAME}
RUN adduser  ${APP_USERNAME} --ingroup ${GROUP_NAME} 
RUN echo "${APP_USERNAME}:${PASSWORD}" | chpasswd   
RUN chown ${APP_USERNAME}:${GROUP_NAME} /opt/${APP_NAME} -R

COPY argus-1.0-SNAPSHOT-jar-with-dependencies.jar /opt/${APP_NAME}/
RUN mkdir ${DAEMON_SERVICES_PATH}/argus/ -p
COPY argus/run  ${DAEMON_SERVICES_PATH}/argus/

#ENTRYPOINT ["/sbin/entrypoint.sh"]
ENTRYPOINT /usr/bin/svscan ${DAEMON_SERVICES_PATH}/
