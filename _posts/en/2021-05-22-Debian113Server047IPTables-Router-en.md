---
uid: Debian113Server047IPTables-Router
title: Debian11, Server, IPTables - Router
description: IPTable configuration for a two legs server, on on internet, one in a private network. This will grant access to the private network to basic services such as email, time and SSH, without filtering or blocking. The other protocols will be managed later with a proxy and a parental control system.
category: Computers
tags: [ Debian11 Server, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, IPTables, Security, Filtering, Private Network, Network, Firewall, Rules, Chains, Cracker, SSH, TCP, IP, ICMP, Loopback, IPv6, Router server, Gateway, Email, NTP, Time, SSH, Proxy, Parental control, Control, SNAT, MASQUERADE ]
---
IPTable configuration for a two legs server, one on internet, one in a private network. This will grant access to the private network to basic services such as email, time and SSH, without filtering or blocking. The other protocols will be managed later with a proxy and a parental control system.

* TOC
{:toc}

# Prerequisites

## Previous steps

The [Network configuration Router](/Debian111PostInstall021Debian-Networkconfiguration-Router-en/) configuration, should be applied. As well as the generic [IPTables](/Debian113Server045IPTables-en/).

## Existing variables

We need the LAN variables which where already defined.

## Reload the variables

Ensure that the variable are available, by loading the configuration script. This is mandatory because we rebooted in the previous step.
```bash
source /root/config.env
```

# Add LAN chains

For an easier management, I create an input and an output chain for the LAN interface. I'll list in these chains the allowed packets. I add them in the global INPUT and OUTPUT chains.
```bash
sed -i 's/^-A INPUT -i '${WAN_IF}'.*$/&\n-A INPUT -i '${LAN_IF}' -j LAN_input/' /etc/iptables/rules.v4
sed -i 's/^-A OUTPUT -o '${WAN_IF}'.*$/&\n-A OUTPUT -o '${LAN_IF}' -j LAN_output/' /etc/iptables/rules.v4
sed -i 's/^-N WAN_input$/-N LAN_input\n\n-N LAN_output\n\n&/' /etc/iptables/rules.v4
```

# Whitelist from LAN to local

First, I add the SSH connection rule to the accept input from the LAN, without any rate limiter chain. I assume that this network is secure enough, this could be hardened, but I dont need it at home ! If my children try to brute force the server, instead of blocking them, it will be time to teach them computer security. ;)
```bash
sed -i 's/^-N LAN_input$/&\n-A LAN_input -j SSH/' /etc/iptables/rules.v4
```

# Forward (routes) from LAN to WAN

Then, I enable the kernel forwarding and add few forwarding rules to accept outgoing connection to internet from the private network : send emails, get emails (POP and IMAP), time and SSH.
```bash
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/00-IPv4Forwarding.conf
sysctl --system
sed -i 's/^-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT$/&\n-A FORWARD -i '${LAN_IF}' -p tcp -m multiport --dports 25,465,587 -j ACCEPT/' /etc/iptables/rules.v4
sed -i 's/^-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT$/&\n-A FORWARD -i '${LAN_IF}' -p tcp -m multiport --dports 143,993 -j ACCEPT/' /etc/iptables/rules.v4
sed -i 's/^-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT$/&\n-A FORWARD -i '${LAN_IF}' -p tcp -m multiport --dports 110,995 -j ACCEPT/' /etc/iptables/rules.v4
sed -i 's/^-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT$/&\n-A FORWARD -i '${LAN_IF}' -p tcp --dport 123 -j ACCEPT/' /etc/iptables/rules.v4
sed -i 's/^-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT$/&\n-A FORWARD -i '${LAN_IF}' -p udp --dport 123 -j ACCEPT/' /etc/iptables/rules.v4
sed -i 's/^-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT$/&\n-A FORWARD -i '${LAN_IF}' -p tcp --dport 22 -j ACCEPT/' /etc/iptables/rules.v4
```

# Masquerade (SNAT) non routable IPs forwarded to WAN

The internal network can send packet to the outside, with an internal return address, they will never receive the replies... Let's activate the Source Network Address Translation, with the masquerade target, for everything sent to a non private address through the WAN interface.
```bash
sed -i 's/^:POSTROUTING.*$/&\n-A POSTROUTING -s '${LAN_IP}'\/'${LAN_NM}' ! -d '${LAN_IP}'\/'${LAN_NM}' -o '${WAN_IF}' -j MASQUERADE/' /etc/iptables/rules.v4
systemctl restart netfilter-persistent
```
