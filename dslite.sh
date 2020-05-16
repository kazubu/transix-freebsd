#!/bin/sh

# Configuration
V6_IF="vmx1"
TUN_IF="gif0"
TUN_MTU="1460"
TUN_DST="2404:8e00::feed:100"

TUN_SRC=""
V6_READY_CHK="ifconfig $V6_IF | grep -v fe80 | grep inet"
TUN_SRC_CMD="ifconfig $V6_IF | grep inet6 | grep -v fe80 | cut -d ' ' -f 2"

if ifconfig $TUN_IF 2> /dev/null > /dev/null; then
  echo "DS-Lite Tunnel is already created."
  exit 1
fi

while :
do
  if sh -c "$V6_READY_CHK" 2> /dev/null > /dev/null ; then
    TUN_SRC=`sh -c "$TUN_SRC_CMD"`
    break
  fi
  echo "IPv6 address is not yet assigned..."
  sleep 1
done

echo "DS-Lite Tunnel Source: $TUN_SRC"
echo "DS-Lite Tunnel Destination: $TUN_DST"
echo "DS-Lite Tunnel Interface: $TUN_IF"

ifconfig $TUN_IF create
ifconfig $TUN_IF inet6 tunnel $TUN_SRC $TUN_DST prefixlen 128
ifconfig $TUN_IF up
ifconfig $TUN_IF inet mtu $TUN_MTU

sysctl net.inet.ip.forwarding=1
route add default -interface $TUN_IF
