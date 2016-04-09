#initialization script
service ssh start

[ ! "$(ls -A /var/lib/postgresql/9.3/main)" ] && echo "Database not exists" && mkdir /var/lib/postgresql/9.3/main && chown postgres:postgres /var/lib/postgresql/9.3/main && chmod 700 /var/lib/postgresql/9.3/main && cp -rp /var/lib/postgresql/9.3MAIN/* /var/lib/postgresql/9.3/main

service postgresql start

[ ! "$(ls -A /opt/tomcat/webapps/ROOT)" ] && echo "Tomcat webapps not exist" && chown tomcat:tomcat /opt/tomcat/webapps && chmod 700 /opt/tomcat/webapps && cp -rp /opt/tomcat/webappsMAIN/* /opt/tomcat/webapps
chown tomcat:tomcat /opt/tomcat/logs && chmod 700 /opt/tomcat/logs
chown tomcat:tomcat /var/external-files && chmod 700 /var/external-files

/opt/tomcat/bin/startup.sh
