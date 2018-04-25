#!/bin/sh

##########################
# Setup the Firewall rules
##########################
fw_setup() {
  # First we added a new chain called 'DOH' to the 'nat' table.
  iptables -t nat -N DOH

  # We then told iptables to redirect all port 53 connections to the 
  # DNS-over-HTTPS server listening on 5053
  iptables -t nat -A DOH -p tcp --dport 53 -j REDIRECT --to-ports 5053
  iptables -t nat -A DOH -p udp --dport 53 -j REDIRECT --to-ports 5053

  iptables -t nat -A PREROUTING -i docker0 -p tcp --dport 53 -j DOH
  iptables -t nat -A PREROUTING -i docker0 -p udp --dport 53 -j DOH
}

##########################
# Clear the Firewall rules
##########################
fw_clear() {
  iptables-save | grep -v DOH | iptables-restore
  #iptables -L -t nat --line-numbers
  #iptables -t nat -D PREROUTING 2
}

if [ $# -ne 2 ]; then
    echo "Usage: $0 {device} {start|stop}"
    exit 1
fi

case "$2" in
    start)
        echo -n "Setting DOH firewall rules..."
        fw_clear
        fw_setup
        echo "done."
        ;;
    stop)
        echo -n "Cleaning DOH firewall rules..."
        fw_clear
        echo "done."
        ;;
    *)
        echo "Usage: $0 {device} {start|stop}"
        exit 1
        ;;
esac
exit 0
