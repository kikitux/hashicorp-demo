/usr/local/bin/consul-template -template "/vagrant/keepalived_$HOSTNAME.ctmpl:/etc/keepalived/keepalived.conf.generated" -dry -once > /etc/keepalived/keepalived.conf.generated

diff /etc/keepalived/keepalived.conf.generated /etc/keepalived/keepalived.conf
if [ $? -eq 0 ] ; then
  exit 0
else
  cp /etc/keepalived/keepalived.conf.generated /etc/keepalived/keepalived.conf
  service keepalived reload
fi
