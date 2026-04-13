FROM tomcat:latest

RUN cp -R /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps

COPY target/*.jar /usr/local/tomcat/webapps