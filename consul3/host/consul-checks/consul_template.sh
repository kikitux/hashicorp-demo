/usr/local/bin/consul-template -template "/vagrant/keepalived_$HOSTNAME.ctmpl:/etc/keepalived/keepalived.conf:service keepalived reload" -once $1
