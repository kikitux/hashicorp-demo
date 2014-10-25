/usr/local/bin/consul-template -template '/vagrant/haproxy.ctmpl:/etc/haproxy/haproxy.cfg:service haproxy reload' -once
