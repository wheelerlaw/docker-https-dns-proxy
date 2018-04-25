#!/bin/bash

device="$1"
shift
args="$@"

#echo "Activating iptables rules..."
/fw.sh $device start

pid=0

# SIGUSR1 handler
usr_handler() {
  echo "usr_handler"
}

# SIGTERM-handler
term_handler() {
    if [ $pid -ne 0 ]; then
        echo "Term signal catched. Shutdown https_dns_proxy and disable iptables rules..."
        kill -SIGTERM "$pid"
        wait "$pid"
        /fw.sh $device stop
    fi
    exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
trap 'kill ${!}; usr_handler' SIGUSR1
trap 'kill ${!}; term_handler' INT QUIT TERM

bind_arg="-a $(ip addr show $device | sed -n 's/.*inet \([0-9.]\+\)\/.*/\1/p')"

echo "Starting redsocks: (http_dns_proxy $args $bind_arg)"
/usr/local/bin/https_dns_proxy $args $bind_arg &
pid="$!"

# wait indefinetely
while true
do
    tail -f /dev/null & wait ${!}
done
