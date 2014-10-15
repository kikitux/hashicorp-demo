FROM kikitux/oracle6-consul:latest
MAINTAINER Alvaro Miranda kikitux@gmail.com
EXPOSE 22
EXPOSE 80
ADD nginx.conf /
RUN yum localinstall -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
    yum install -y nginx && \
    chkconfig nginx on && \
    mv nginx.conf /etc/nginx/ 
ADD check_web.json /usr/local/consul-checks
CMD cp /etc/hostname /usr/share/nginx/html/index.html && \
    service sshd restart && service nginx restart && \
    consul agent -data-dir=/var/tmp/consul/ -join=$JOIN -dc=$DC -ui-dir=/usr/local/ui/disk/ -config-dir=/usr/local/consul-checks
