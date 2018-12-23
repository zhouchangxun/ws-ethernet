#!/usr/bin/env bash

eth0=wlp3s0
tap0=tap0


start(){
echo Create and initialize TAP device... 
./tunctl -t $tap0
ifconfig $tap0 down
ifconfig $tap0 10.5.0.1
ifconfig $tap0 netmask 255.255.0.0
ifconfig $tap0 mtu 1500
ifconfig $tap0 up
######################

echo IP Forwarding config for TAP device ##
echo 1 > /proc/sys/net/ipv4/ip_forward

echo Enable snat on $eth0 for 10.5.0.0/16 network.
iptables -t nat -A POSTROUTING -o $eth0 -j MASQUERADE
iptables -A FORWARD -i $eth0 -o $tap0 -m state --state RELATED,ESTABLISHED -j ACCEPT

#Drop any packages destined for the host machine or any other docker containers
##NOTE: double check that this matches your docker bridge subnet
#/sbin/iptables -A FORWARD -i $tap0 -o $eth0 -d 172.17.0.0/16 -j DROP

iptables -A FORWARD -i $tap0 -o $eth0 -j ACCEPT
#/sbin/iptables-save
#########################################
echo start dhcp server...
dnsmasq -C `pwd`/dhcp.conf 

echo 'start switch device(support websocket nic and tap nic)'

nohup python -u switchedrelay.py 2>&1 > /tmp/ws-switchd.log &
echo $! > /run/ws-switchd.pid

echo start ok
}


start
