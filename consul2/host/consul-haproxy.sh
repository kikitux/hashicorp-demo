/usr/local/bin/consul-haproxy  -in /vagrant/haproxy_in.conf -out=/etc/haproxy/haproxy.cfg -backend 'c=webserver@dc1' -backend 'c=webserver@dc2' -reload='service haproxy reload' -quiet 1s
