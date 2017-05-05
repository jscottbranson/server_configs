#!/bin/bash
#Variables
SERVER_IP="45.76.22.18"
SERVER_IP6="2001:19f0:5c01:348:2f84:c1ea:7888:8498"
INTRANET_IP="10.99.0.0/26"
LOOPBACK_IP="127.0.0.0/8"
LOOPBACK_IP6="::1/128"
VPN_IP="10.8.0.0/8"
VPN_IP6="fdb9:eb8d:aaa6:a555::/64"
VPN_IP_PUB="45.76.29.48"

LOOPBACK_INTERFACE="lo"
INTERNET_INTERFACE="eth0"
INTRANET_INTERFACE="eth1"
PERSONAL_TUNNEL="tun0"

#Flush existing rules
iptables --flush
ip6tables --flush

#Set default policy to drop
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP

#Allow loopback traffic while rejecting traffic to 127.0.0.0/8 that isn't on lo
iptables -I INPUT -i $LOOPBACK_INTERFACE -j ACCEPT
iptables -I OUTPUT -o $LOOPBACK_INTERFACE -j ACCEPT
iptables -I INPUT ! -i $LOOPBACK_INTERFACE -d $LOOPBACK_IP -j DROP

ip6tables -I INPUT -i $LOOPBACK_INTERFACE -j ACCEPT
ip6tables -I OUTPUT -o $LOOPBACK_INTERFACE -j ACCEPT
ip6tables -I INPUT ! -i $LOOPBACK_INTERFACE -d $LOOPBACK_IP6 -j DROP

#Allow existing connections
iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -I FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -I OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

ip6tables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -I FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -I OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#Allow icmp
iptables -I INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -I OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -I OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -I INPUT -p icmp --icmp-type echo-reply -j ACCEPT

ip6tables -I INPUT -p icmpv6 -j ACCEPT
ip6tables -I OUTPUT -p icmpv6 -j ACCEPT
ip6tables -I FORWARD -p icmpv6 -j ACCEPT

#Drop fragmented packets
iptables -I INPUT -f -j DROP
#Drop XMAS packets
iptables -I INPUT -p tcp --tcp-flags ALL ALL -j DROP
#Drop null packets
iptables -I INPUT -p tcp --tcp-flags ALL NONE -j DROP
#Block invalid packets
iptables -I INPUT -m state --state INVALID -j DROP
iptables -I FORWARD -m state --state INVALID -j DROP
iptables -I OUTPUT -m state --state INVALID -j DROP
#Block RH0 pacets
ip6tables -I INPUT -m rt --rt-type 0 -j DROP
ip6tables -I FORWARD -m rt --rt-type 0 -j DROP
ip6tables -I OUTPUT -m rt --rt-type 0 -j DROP

####-------------------------------------------------------
#Allow specific incoming connections

###SSH
iptables -A INPUT -i $INTERNET_INTERFACE -s $VPN_IP_PUB -p tcp  --dport 22 -m state --state NEW -j ACCEPT
iptables -A INPUT -i $INTERNET_INTERFACE -s $VPN_IP -p tcp  --dport 22 -m state --state NEW -j ACCEPT

###HTML
#iptables -A INPUT -i $INTERNET_INTERFACE -s -p tcp  --dport 80 -m state --state NEW -j ACCEPT
#iptables -A INPUT -i $INTERNET_INTERFACE -s -p tcp  --dport 443 -m state --state NEW -j ACCEPT

#ip6tables -A INPUT -i $INTERNET_INTERFACE -s -p tcp  --dport 80 -m state --state NEW -j ACCEPT
#ip6tables -A INPUT -i $INTERNET_INTERFACE -s -p tcp  --dport 443 -m state --state NEW -j ACCEPT

###Email
#iptables -A INPUT -i $INTERNET_INTERFACE -s -p tcp  --dport 25 -m state --state NEW -j ACCEPT
#iptables -A INPUT -i $INTERNET_INTERFACE -s -p tcp  --dport 587 -m state --state NEW -j ACCEPT
#iptables -A INPUT -i $INTERNET_INTERFACE -s -p tcp  --dport 993 -m state --state NEW -j ACCEPT

#ip6tables -A INPUT -i $INTERNET_INTERFACE -s -p tcp  --dport 25 -m state --state NEW -j ACCEPT
#ip6tables -A INPUT -i $INTERNET_INTERFACE -s -p tcp  --dport 587 -m state --state NEW -j ACCEPT
#ip6tables -A INPUT -i $INTERNET_INTERFACE -s -p tcp  --dport 993 -m state --state NEW -j ACCEPT

####-------------------------------------------------------
#Allow specific outgoing connections
##HTML
iptables -I OUTPUT -o $INTERNET_INTERFACE -p tcp --dport 80 -m state --state NEW -j ACCEPT
ip6tables -I OUTPUT -o $INTERNET_INTERFACE -p tcp --dport 80 -m state --state NEW -j ACCEPT

##Encrypted HTML
iptables -I OUTPUT -o $INTERNET_INTERFACE -p tcp --dport 443 -m state --state NEW -j ACCEPT
ip6tables -I OUTPUT -o $INTERNET_INTERFACE -p tcp --dport 443 -m state --state NEW -j ACCEPT

#Email
iptables -I OUTPUT -o $INTERNET_INTERFACE -p tcp --dport 993 -m state --state NEW -j ACCEPT
ip6tables -I OUTPUT -o $INTERNET_INTERFACE -p tcp --dport 993 -m state --state NEW -j ACCEPT

iptables -I OUTPUT -o $INTERNET_INTERFACE -p tcp --dport 587 -m state --state NEW -j ACCEPT
ip6tables -I OUTPUT -o $INTERNET_INTERFACE -p tcp --dport 587 -m state --state NEW -j ACCEPT

##DNS Servers
iptables -I OUTPUT -o $INTERNET_INTERFACE -p udp --dport 53 -m state --state NEW -j ACCEPT
ip6tables -I OUTPUT -o $INTERNET_INTERFACE -p udp --dport 53 -m state --state NEW -j ACCEPT

#Systems ports
iptables -I OUTPUT -o $INTERNET_INTERFACE -p tcp --dport 43 -m state --state NEW -j ACCEPT
iptables -I OUTPUT -o $INTERNET_INTERFACE -p udp --dport 123 -m state --state NEW  -j ACCEPT
iptables -I OUTPUT -o $INTERNET_INTERFACE -p udp --dport 67 -m state --state NEW -j ACCEPT
iptables -I OUTPUT -o $INTERNET_INTERFACE -p udp --dport 68 -m state --state NEW -j ACCEPT

ip6tables -I OUTPUT -o $INTERNET_INTERFACE -p tcp --dport 43 -m state --state NEW -j ACCEPT
ip6tables -I OUTPUT -o $INTERNET_INTERFACE -p udp --dport 123 -m state --state NEW  -j ACCEPT
ip6tables -I OUTPUT -o $INTERNET_INTERFACE -p udp --dport 67 -m state --state NEW -j ACCEPT
ip6tables -I OUTPUT -o $INTERNET_INTERFACE -p udp --dport 68 -m state --state NEW -j ACCEPT
