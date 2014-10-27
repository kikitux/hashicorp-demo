curl http://192.168.10.2${HOSTNAME#host}:8000
if [ $? -eq 0 ]; then
  RET=$?
  curl -X PUT -d '150' http://localhost:8500/v1/kv/loadbalancer/role
else
  curl -X PUT -d '50' http://localhost:8500/v1/kv/loadbalancer/role
fi
exit $RET
