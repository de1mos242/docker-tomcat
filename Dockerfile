FROM ubuntu:14.04

MAINTAINER de1mos

ENV DEBIAN_FRONTEND noninteractive

ENV LANG ru_RU.UTF-8

# Install java
RUN apt-get install -y software-properties-common debconf-utils
RUN apt-add-repository ppa:webupd8team/java
RUN apt-get update
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN apt-get install -y oracle-java8-installer

# install locales
RUN apt-get install -y language-pack-ru
RUN locale-gen ru_RU 
RUN locale-gen ru_RU.UTF-8
RUN apt-get install --reinstall language-pack-ru -y
RUN dpkg-reconfigure locales
RUN locale

# add ssh user
RUN useradd -ms /bin/bash docker-user
RUN sudo usermod -aG sudo docker-user
RUN echo 'docker-user:12345678' | chpasswd

#SETUP SSH SERVER
RUN mkdir /var/run/sshd
RUN apt-get install -y openssh-server
COPY sshd /etc/pam.d/sshd
COPY sshd_config /etc/ssh/sshd_config
EXPOSE 22

#SETUP POSTGRESQL
RUN apt-get install -y postgresql postgresql-contrib
USER postgres
RUN /etc/init.d/postgresql start \
    && psql --command "CREATE USER tomcat_user WITH SUPERUSER PASSWORD 'tomcat_password';" \
    && createdb -O tomcat_user --template=template0 -E unicode tomcat_db 
USER root
RUN mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private
COPY russian.dict /usr/share/postgresql/9.3/tsearch_data/russian.dict
COPY russian.affix /usr/share/postgresql/9.3/tsearch_data/russian.affix
RUN mkdir /var/lib/postgresql/9.3MAIN && cp -rp /var/lib/postgresql/9.3/main/* /var/lib/postgresql/9.3MAIN

# SETUP TOMCAT
RUN groupadd tomcat && useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
COPY tomcat-8.0.30.tar.gz /root/tomcat-8.0.30.tar.gz
RUN mkdir /opt/tomcat
RUN tar xvf /root/tomcat-8.0.30.tar.gz -C /opt/tomcat --strip-components=1
RUN chgrp -R tomcat /opt/tomcat/conf && \
	chmod g+rwx /opt/tomcat/conf && \
	chmod g+r /opt/tomcat/conf/* && \
	chown -R tomcat /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/
COPY tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
COPY context.xml /opt/tomcat/conf/context.xml
COPY postgresql-jdbc4.jar /opt/tomcat/lib/postgresql-jdbc4.jar
COPY setenv.sh /opt/tomcat/bin/setenv.sh
RUN mkdir /opt/tomcat/webappsMAIN && cp -rp /opt/tomcat/webapps/* opt/tomcat/webappsMAIN

COPY init.sh /root/init.sh
RUN chmod +x /root/init.sh

CMD sh /root/init.sh && tail -f /opt/tomcat/logs/catalina.out

