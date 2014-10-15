FROM kikitux/oracle6-nginx-consul:latest
MAINTAINER Alvaro Miranda kikitux@gmail.com
EXPOSE 22
EXPOSE 80
ADD nginx.conf /
RUN mv nginx.conf /etc/nginx/ 
ADD check_web.json /usr/local/consul-checks
CMD cp /etc/hostname /usr/share/nginx/html/index.html && \
    service sshd restart && service nginx restart && \
    consul agent -data-dir=/var/tmp/consul/ -join=consul.service.$DC.consul -dc=$DC -ui-dir=/usr/local/ui/disk/ -config-dir=/usr/local/consul-checks
