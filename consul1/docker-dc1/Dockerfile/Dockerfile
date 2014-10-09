FROM kikitux/oracle6:latest      
MAINTAINER Alvaro Miranda kikitux@gmail.com      
RUN sed -i -e 's/session\s*required\s*pam_loginuid.so$/session optional\tpam_loginuid.so/' /etc/pam.d/sshd  && \
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ori && \
    sed -i -e '/#UseDNS yes/a UseDNS no' /etc/ssh/sshd_config && \ 
    /etc/init.d/sshd start && \ 
    yum install -y sudo wget unzip bind-utils && \
    cp /etc/sudoers /etc/sudoers.orig && \
    sed -i -e 's/Defaults\\s*requiretty$/#Defaults\trequiretty/' /etc/sudoers && \
    sed -i -e '/# %wheel\tALL=(ALL)\tNOPASSWD: ALL/a %vagrant\tALL=(ALL)\tNOPASSWD: ALL' /etc/sudoers && \
    useradd vagrant && \
    mkdir ~vagrant/.ssh && \
    chmod 700 ~vagrant/.ssh && \
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' | tee -a ~vagrant/.ssh/authorized_keys && \
    chmod 600 ~vagrant/.ssh/authorized_keys && \
    chown -R vagrant: ~vagrant/.ssh
RUN cd /usr/local/bin && \
    wget -N https://dl.bintray.com/mitchellh/consul/0.4.0_linux_amd64.zip && \
    unzip 0.4.0_linux_amd64.zip
EXPOSE 22
CMD service sshd restart && consul agent -data-dir=/var/tmp/consul/ -join=$JOIN -dc=$DC
