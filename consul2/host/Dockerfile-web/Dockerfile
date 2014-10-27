FROM kikitux/corepure64-nginx:latest
MAINTAINER Alvaro Miranda kikitux@gmail.com
ADD check_web.json /usr/local/consul-checks
EXPOSE 80
CMD cp /etc/hostname /usr/local/nginx/html/index.html && \
    nginx && \
    consul agent -data-dir=/var/tmp/consul/ -join=$IP -dc=$DC -ui-dir=/usr/local/ui/ -config-dir=/usr/local/consul-checks
