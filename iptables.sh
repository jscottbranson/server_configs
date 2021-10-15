#!/bin/bash

#--------------------------------- VARIABLES ---------------------------------# 
## Device name & IP address for the server's WAN connection
INTERNET_INTERFACE="eno1"
SERVER_IP="xxx.xxx.xxx.xxx"
SERVER_IP6="xxx:xxxx::"

## Device name & IP address for the server's LAN connection
INTRANET_INTERFACE="eth1"
INTRANET_IP="10.xx.xx.xx/32"

## Loopback
LOOPBACK_IP="127.0.0.0/8"
LOOPBACK_IP6="::1/128"
LOOPBACK_INTERFACE="lo"

## DNS Servers - these must be the same as you have set in /etc/resolv.conf
### On RHEL based distros, this can be set in ifcfg
### The 208.67.x.x IPs are for OpenDNS & 1.1.1.1 is Cloudflare 
DNS_IPS="208.67.222.222,208.67.220.220,1.1.1.1"
DNS_IPS6="2620:119:53::53,2620:119:35::53"

## Mail Servers
### Servers typically only send mail to specific mail servers. Thus, outgoing connections to
### port 25 can generally be restricted to mail servers you control. If your server doesn't send
### mail on port 25, then comment the below rules
#MAIL_SERVER="x.x.x.x"
#MAIL_SERVER6="xx:xx"

#--------------------------------- POLICIES ---------------------------------# 

####-------------------------------------------------------
#Universally applicable policies

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
# Incoming Connections
## SSH
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT

## DHCP
#iptables -A INPUT -p udp --dport 67 -m state --state NEW -j ACCEPT
#iptables -A INPUT -p udp --dport 68 -m state --state NEW -j ACCEPT
#ip6tables -A INPUT -p udp --dport 546 -m state --state NEW -j ACCEPT

## Rippled Peer Protocol
#iptables -A INPUT -i $INTERNET_INTERFACE -d $SERVER_IP -p tcp --dport 51235 -m state --state NEW -j ACCEPT
#ip6tables -A INPUT -i $INTRANET_INTERFACE -d $INTRANET_IP6 -p tcp --dport 51235 -m state --state NEW -j ACCEPT

####-------------------------------------------------------
# Outgoing Connections

#####---------------Intranet

#####---------------Internet
## Rippled Peer Protocol
#iptables -I OUTPUT -p tcp --dport 51235 -m state --state NEW -j ACCEPT

## Email
#iptables -I OUTPUT -o $INTERNET_INTERFACE -d $MAIL_SERVER -p tcp --dport 25 -m state --state NEW -j ACCEPT
#ip6tables -I OUTPUT -o $INTERNET_INTERFACE -d $MAIL_SERVER6 -p tcp --dport 25 -m state --state NEW -j ACCEPT

## HTTP
iptables -I OUTPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
ip6tables -I OUTPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT

## Encrypted HTTP (HTTPS)
iptables -I OUTPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT
ip6tables -I OUTPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT

## DNS Servers
iptables -I OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
ip6tables -I OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
#iptables -I OUTPUT -d $DNS_IPS -p udp --dport 53 -m state --state NEW -j ACCEPT
#ip6tables -I OUTPUT -d $DNS_IPS6 -p udp --dport 53 -m state --state NEW -j ACCEPT

## System Ports
iptables -A OUTPUT -p udp --dport 123 -m state --state NEW  -j ACCEPT
iptables -A OUTPUT -p udp --dport 67 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 68 -m state --state NEW -j ACCEPT

ip6tables -A OUTPUT -p udp --dport 123 -m state --state NEW  -j ACCEPT
ip6tables -A OUTPUT -p udp --dport 67 -m state --state NEW -j ACCEPT
ip6tables -A OUTPUT -p udp --dport 68 -m state --state NEW -j ACCEPT
ip6tables -A OUTPUT -p udp --dport 547 -m state --state NEW -j ACCEPT

####-------------------------------------------------------
# Logging
iptables -N LOGGING
iptables -A INPUT -j LOGGING
iptables -A OUTPUT -j LOGGING
iptables -A LOGGING -m limit --limit 20/min -j LOG --log-prefix "iptables: " --log-level 4
iptables -A LOGGING -j DROP

ip6tables -N LOGGING
ip6tables -A INPUT -j LOGGING
ip6tables -A OUTPUT -j LOGGING
ip6tables -A LOGGING -m limit --limit 20/min -j LOG --log-prefix "iptables: " --log-level 4
ip6tables -A LOGGING -j DROP

#(CentOS) Change the iptables logfile location from '/var/log/messages':
#
# 1. create or edit the file: '/etc/rsyslog.d/iptables.conf'
# 2. Add the following into iptables.conf (omit the # and tabs/spaces):
#		:msg, startswith, "iptables: " -/var/log/iptables.log
#		& stop
#		:msg, regex, "^\[ *[0-9]*\.[0-9]*\] iptables: " -/var/log/iptables.log
#		& stop

