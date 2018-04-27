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

        -t)
        proxy=${args[$i+1]}
        ;;

        -t=*)
        arg=${args[$i]}
        proxy=${arg#*=}
        ;;

        -p)
        port=${args[$i+1]}
        ;;

        -p=*)
        arg=${args[$i]}
        port=${arg#*=}
        ;;

    esac
done

if [ -z "$proxy" ]; then
    if [ ! -z "$http_proxy" ]; then
        proxyArg="-t $http_proxy"
    fi
fi

if [ -z "$ip" ]; then
    echo "No listening address specified, defaulting to 127.0.0.1"
    ip="127.0.0.1"
fi

if [ -z "$port" ]; then
    echo "No listening port specified, defaulting to 5053"
    port="5053"
fi

device=$(ifconfig | grep -B1 $ip | grep -o "^\w*")

/fw.sh $device $port start

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
        /fw.sh $device $port stop
    fi
    exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
trap 'kill ${!}; usr_handler' SIGUSR1
trap 'kill ${!}; term_handler' INT QUIT TERM

echo "Starting http_dns_proxy: (http_dns_proxy $@ $proxyArg)"
/usr/local/bin/https_dns_proxy "$@" "@proxyArg" &
pid="$!"

# wait indefinetely
while true
do
    tail -f /dev/null & wait ${!}
done
