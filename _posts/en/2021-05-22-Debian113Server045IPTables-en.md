---
uid: Debian113Server045IPTables
title: Debian11, Server, IPTables
description: The Linux iptables firewall feature is already included in the kernel and the client application is already installed. I will install a wrapper to persist the firewall rules on the disk and to automatically reload them at reboot. I also prepare a default evolutive ruleset with one specificity, it forbids also OUTPUT connections by default. If someone gain access to my server an can execute a script, the script will probably be blocked to send the feedbacks to the attacker. I use CHAOS and TARPIT rules against obvious attacker and ratelimiting rules, as passive replies to attacks.
category: Computers
tags: [ Debian11 Server, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, IPTables, Security, Filtering, Network, Firewall, Rules, Chains, Cracker, SSH, TCP, IP, ICMP, Loopback, IPv6 ]
---

The Linux iptables firewall feature is already included in the kernel and the client application is already installed. I will install a wrapper to persist the firewall rules on the disk and to automatically reload them at reboot. I also prepare a default evolutive ruleset with one specificity : it forbids also OUTPUT connections by default. If someone gain access to my server an can execute a script, the script will probably be blocked to send the feedbacks to the attacker. I use CHAOS and TARPIT rules against obvious attacker and ratelimiting rules, as passive replies to attacks.

* TOC
{:toc}

# Prerequisites

## Existing variables
We need the WAN_IF variable which is already defined in the configuration file, in [Configuration variables](/Debian111PostInstall010Configurationvariables-en/).

## Reload the variables
Ensure that the WAN_IF variable is available, by loading the configuration script :
```bash
source /root/config.env
```

# Preconfigure installation
```bash
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
```

# Installation
I will use the CHAOS and TARPIT targets. They are available as a kernel module. I need to install the related package, it will install the Debian module build chain, which will recompile the modules everytime a new kernel is installed. The beauty of Debian !
```bash
apt-get install -y iptables-persistent xtables-addons-dkms
```

# Block all IPv6 traffic
My server will not use IPv6 at all, but I prefered not to disable it. Thus I install firewall rules to block all IPv6 traffic and to outgoing IPv6 connections, as an helper to configure my applications and a reminder to disable IPv6 in their configuration.

```bash
cat << EOF > /etc/iptables/rules.v6
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
# Temporary rules to detect unwanted traffic 
-A OUTPUT -m limit --limit 10/min -j LOG --log-prefix "[IP6] "
COMMIT
EOF
````

# Configure IPv4 rules
First of all, I set all the default policies to DROP, when something is not allowed, it is forbidden. If, for any reason, a malicious program is executed on the server, it will probably try to send information outside, a password file, an SSH key, or something else, but it will be blocked because it was not in the allowed connections.

```bash
cat <<EOF > /etc/iptables/rules.v4
*raw
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
COMMIT
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
EOF
```

I will install `portsentry` later, but I use a set of scan protection rules at the kernel level with the psd and lscan modules. A scan is never coming from a friend, thus I chose to send the connection to the CHAOS target. The idea is to reply with random information. If I drop the packet, it is obvious that I'm here and I try to protect myself. If I reply with random data, it could be legitimate data, I'm here, and the scan will fail to get a fingerprint of my network stack to guess my OS and my weaknesses.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-N xt_portscan
-A xt_portscan -m psd -m limit --limit 10/min -j LOG --log-prefix "[PSD] "
-A xt_portscan -m psd -j CHAOS
-A xt_portscan -m lscan -p tcp --synscan -m limit --limit 10/min -j LOG --log-prefix "[SYNSCAN] "
-A xt_portscan -m lscan -p tcp --synscan -j CHAOS
-A xt_portscan -m lscan -p tcp --stealth -m limit --limit 10/min -j LOG --log-prefix "[STEALTH] "
-A xt_portscan -m lscan -p tcp --stealth -j CHAOS
-A xt_portscan -m lscan -p tcp --cnscan -m limit --limit 10/min -j LOG --log-prefix "[CNSCAN] "
-A xt_portscan -m lscan -p tcp --cnscan -j CHAOS
-A xt_portscan -m lscan -p tcp --grscan -m limit --limit 10/min -j LOG --log-prefix "[GRSCAN] "
-A xt_portscan -m lscan -p tcp --grscan -j CHAOS
EOF
```

Given that every outgoing connection is blocked by default, I listed the official Debian repositorY IP addresses in a specific rule, to accept them and I added this rule to the OUTPUT chain.

```bash
cat <<EOF >> /etc/iptables/rules.v4
-N DebianRepositories
-A DebianRepositories -d 128.31.0.62 -j ACCEPT
-A DebianRepositories -d 130.89.148.77 -j ACCEPT
-A DebianRepositories -d 149.20.4.15 -j ACCEPT
-A DebianRepositories -d 151.101.130.132 -j ACCEPT
-A DebianRepositories -d 151.101.194.132 -j ACCEPT
-A DebianRepositories -d 151.101.2.132 -j ACCEPT
-A DebianRepositories -d 151.101.66.132 -j ACCEPT
-A DebianRepositories -d 192.168.1.254 -j ACCEPT
-A DebianRepositories -d 199.232.178.132 -j ACCEPT
-A DebianRepositories -d 212.27.32.66 -j ACCEPT
-A DebianRepositories -d 91.121.146.196 -j ACCEPT
EOF
```

I also need to resolve IP addresses, thus I define a DNS rule to accept DNS queries, including TCP queries, which should not be relevant here, and added this rule to the OUTPUT chain.

```bash
cat <<EOF >> /etc/iptables/rules.v4
-N DNS
-A DNS -p udp --dport 53 -j ACCEPT
-A DNS -p tcp --tcp-flags FIN,SYN,RST,ACK SYN --dport 53 -j ACCEPT
EOF
```

I need to connect to this server, using SSH. SSH authentication rejects password authentication, but I will use the `limit` module to implement a rate limiter. No more than 3 packets are allowed in a 60 seconds window. Given that related and established connection packet will be allowed by another rule, this one is only for incoming connections. Simple, but efficient. I also log the blocked connection attempts, with another limiter to avoid filling the log file, no more than 10 messages are logged per minute. And finally, if someone reaches 3 packets per minute, it is not only blocked, but send to TARPIT... Basically, this target never answer to the connecion packet, no reject, no accept, it simply forget the connection status to avoid filling the internal connection table and leave the connection half open, consuming entries in the outgoing connection table of the attacker, this will fill his table and potentially freeze his computer.
I also have a rule to simply accept incoming SSH connections. I will add these rules to the INPUT chain.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-N SSH_ratelimiter
-A SSH_ratelimiter -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH --rsource
-A SSH_ratelimiter -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --rttl --name SSH --rsource -m limit --limit 10/min -j LOG --log-prefix "[SSHRATE]"
-A SSH_ratelimiter -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --rttl --name SSH --rsource -j TARPIT

-N SSH
-A SSH -p tcp --dport 22 --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT
```

The server is not a time server, but it needs to be a time client to synchronize his own clock. Thus I created an NTP rule to add to the OUTPUT chain.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-N NTP
-A NTP -p udp --dport 123 -j ACCEPT
EOF
```

Ok, I add the SSH rate limiter to block attacker and the SSH incoming connection to accept connections when they are not blocked, in a WAN_INPUT chain.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-N WAN_input
-A WAN_input -j SSH_ratelimiter
-A WAN_input -j SSH
EOF
```

I add the Debian repository access on port 80 only, the DNS queries and the NTP queries to an external output chain.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-N WAN_output
-A WAN_output -p tcp --dport 80 --tcp-flags FIN,SYN,RST,ACK SYN -j DebianRepositories
-A WAN_output -j DNS
-A WAN_output -j NTP
EOF
```

Then, the default input chain accept everything related to an already accepted connection, everything on the loopback interface, everything in ICMP (could be hardened), it includes the chain with the externally incoming connections rules. Then everything not catched is probably bad, I added the scan detection chain, Netbios drop without log to avoid filling the log files and a LOG everything target before DROP.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i ${WAN_IF} -j WAN_input
-A INPUT -j xt_portscan
# NetBIOS Name, Datagram and Session services
-A INPUT -p udp -m multiport --dports 137,138 -j DROP
-A INPUT -p tcp --dport 139 -j DROP
-A INPUT -m limit --limit 10/min -j LOG --log-prefix "[INPUT] "
EOF
```

Everything related to an established connection is accepted, then everything related to the loopback interface is accepted, as well a ICMP. I finally accept everything listed in the external output chain populated earlier and I log everything else before DROP.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A OUTPUT -o lo -j ACCEPT
-A OUTPUT -p icmp -j ACCEPT
-A OUTPUT -o ${WAN_IF} -j WAN_output
-A OUTPUT -m limit --limit 10/min -j LOG --log-prefix "[OUTPUT] "
EOF
```

I also preconfigure the forwarding rules if the server has multiple interfaces and will act as a router to share internet in a private network.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -m limit --limit 10\/min -j LOG --log-prefix "[FORWARD] "
COMMIT
EOF
```

# Restart to apply
`systemctl restart netfilter-persistent` would freeze the current connection because it is not marked as *established* in iptables. Thus a reboot is a better solution to test the firewall.
```bash
reboot
```
