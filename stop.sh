#!/usr/bin/env bash

eth0=wlp3s0
tap0=tap0

stop(){
echo kill process...
kill -9 `cat /run/ws-switchd.pid `
kill -9 `cat /run/ws-dhcpd.pid `
rm -rf /run/ws-*.pid 2>&1 > /dev/null

echo clear iptable...
iptables -t nat -D POSTROUTING -o $eth0 -j MASQUERADE
iptables -D FORWARD -i $eth0 -o $tap0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -D FORWARD -i $tap0 -o $eth0 -j ACCEPT

echo remove tap device...
sleep 1
ip link set $tap0 down
./tunctl -d $tap0

echo stop ok
}


stop
