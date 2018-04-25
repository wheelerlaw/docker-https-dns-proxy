#!/bin/bash

args="$@"

#echo "Activating iptables rules..."
/fw.sh start

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
        /fw.sh stop
    fi
    exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
trap 'kill ${!}; usr_handler' SIGUSR1
trap 'kill ${!}; term_handler' INT QUIT TERM

echo "Starting redsocks: (http_dns_proxy $args)"
/usr/local/bin/https_dns_proxy $args &
pid="$!"

# wait indefinetely
while true
do
    tail -f /dev/null & wait ${!}
done
