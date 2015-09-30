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
	daemontools \
	libffi-dev \
	libcairo2-dev \
	python-cairo \
	libmysqlclient-dev \
	python-ldap \
	libxslt1-dev \
	libxml2-dev \
	python-dev \
	python-mysqldb \
	nginx \
	python-pip \
	build-essential \
	uwsgi \
	uwsgi-plugin-python \
	supervisor \
	python-setuptools 
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

######### python app config ###################
#RUN touch /tmp/argus2.sock
#RUN chmod 666 /tmp/argus2.sock
#RUN chown www-data /tmp/argus2.sock
RUN mkdir  /opt/argus/www/r2tg -p
COPY r2tg /opt/argus/www/r2tg
RUN pip install -r /opt/argus/www/r2tg/requirements.txt
COPY r2tg/docs/argus.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/argus.conf /etc/nginx/sites-enabled/argus.conf
RUN mkdir  /var/lib/nginx -p
RUN chown www-data:www-data  /var/lib/nginx/ -R
RUN chown www-data:www-data  /etc/nginx/ -R
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-available/default
RUN rm /etc/nginx/sites-enabled/default
COPY r2tg/docs/argus.ini /etc/uwsgi/apps-available/
RUN chown argus:argus /opt/argus/www/ -R
RUN ln -s /etc/uwsgi/apps-available/argus.ini /etc/uwsgi/apps-enabled/argus.ini
RUN mkdir /var/log/argus/
RUN touch /var/log/argus/debug.log
RUN touch /var/log/argus/error.log
RUN chown argus:argus -R /var/log/argus/
CMD uwsgi --ini /etc/uwsgi/apps-enabled/argus.ini
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod  777 /tmp/ -R
#RUN service uwsgi restart
#RUN service nginx restart
#ENTRYPOINT ["/sbin/entrypoint.sh"]
#ENTRYPOINT /usr/bin/svscan ${DAEMON_SERVICES_PATH}/
expose 80
CMD ["/usr/bin/supervisord"]

