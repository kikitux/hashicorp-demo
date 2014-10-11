FROM kikitux/oracle6-consul:latest      
MAINTAINER Alvaro Miranda kikitux@gmail.com      
EXPOSE 22
CMD service sshd restart && consul agent -data-dir=/var/tmp/consul/ -join=$JOIN -dc=$DC
