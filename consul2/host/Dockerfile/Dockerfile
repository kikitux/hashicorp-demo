FROM kikitux/oracle6-consul:latest
MAINTAINER Alvaro Miranda kikitux@gmail.com
EXPOSE 22
EXPOSE 80
ADD nginx.conf /
RUN yum localinstall -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
    yum install -y nginx && \
    chkconfig nginx on && \
    cp nginx.conf /etc/
CMD service sshd restart && consul agent -data-dir=/var/tmp/consul/ -join=$JOIN -dc=$DC
