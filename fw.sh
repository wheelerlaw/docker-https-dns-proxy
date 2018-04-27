#!/bin/sh

##########################
# Setup the Firewall rules
##########################
fw_setup() {
  # First we added a new chain called 'DOH' to the 'nat' table.
  iptables -t nat -N DOH

  # We then told iptables to redirect all port 53 connections to the 
  # DNS-over-HTTPS server listening on 5053
  iptables -t nat -A DOH -p tcp -j REDIRECT --to-ports $port
  iptables -t nat -A DOH -p udp -j REDIRECT --to-ports $port

  iptables -t nat -A PREROUTING -i $device -p tcp --dport 53 -j DOH
  iptables -t nat -A PREROUTING -i $device -p udp --dport 53 -j DOH
}

##########################
# Clear the Firewall rules
##########################
fw_clear() {
  iptables-save | grep -v DOH | iptables-restore
  #iptables -L -t nat --line-numbers
  #iptables -t nat -D PREROUTING 2
}

usage() {
  echo "Usage: $0 {device} {port} {start|stop}"
}

if [ $# -ne 3 ]; then
    usage
    exit 1
fi

device="$1"
port="$2"

case "$3" in
    start)
        echo -n "Setting DOH firewall rules for interface $device..."
        fw_clear
        fw_setup
        echo "done."
        ;;
    stop)
        echo -n "Cleaning DOH firewall rules for interface $device..."
        fw_clear
        echo "done."
        ;;
    *)
        usage
        exit 1
        ;;
esac
exit 0
