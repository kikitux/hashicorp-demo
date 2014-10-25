FROM kikitux/oracle6-consul:latest
MAINTAINER Alvaro Miranda kikitux@gmail.com
EXPOSE 22
EXPOSE 8500
CMD service sshd restart && consul agent -server -data-dir=/var/tmp/consul/ -ui-dir=/usr/local/ui/dist/ -join=$JOIN -dc=$DC -bootstrap-expect=3
