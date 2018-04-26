#!/bin/bash

# Infer the device name from the IP address
args=("$@")
for i in $(seq 0 $#); do
    case ${args[$i]} in
        -a)
        ip=${args[$i+1]}
        ;;

        -a=*)
        arg=${args[$i]}
        ip=${arg#*=}
        ;;
    esac
done


device=$(ifconfig | grep -B1 $ip | grep -o "^\w*")

echo "Activating iptables rules..."
/fw.sh $device start

pid=0

# SIGUSR1 handler
usr_handler() {
  echo "usr_handler"
}

# SIGTERM-handler
term_handler() {
    if [ $pid -ne 0 ]; then
        echo "Term signal caught. Shutdown https_dns_proxy and disable iptables rules..."
        kill -SIGTERM "$pid"
        wait "$pid"
        /fw.sh $device stop
    fi
    exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
trap 'kill ${!}; usr_handler' SIGUSR1
trap 'kill ${!}; term_handler' INT QUIT TERM

echo "Starting http_dns_proxy: (http_dns_proxy $@)"
/usr/local/bin/https_dns_proxy "$@" &
pid="$!"

# wait indefinetely
while true
do
    tail -f /dev/null & wait ${!}
done
