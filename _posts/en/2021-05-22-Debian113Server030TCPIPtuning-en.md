---
uid: Debian113Server030TCPIPtuning
title: Debian11, Server, TCPIP tuning
description: How to activate some basic attack protections in the linux kernel network stack, against spoofind, flooding, smurfing, Man in the middle (MITM) or ICMP attacks.
category: Computers
tags: [ Debian11 Server, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation ]
---

How to activate some basic attack protections in the linux kernel network stack, against spoofind, flooding, smurfing, Man in the middle (MITM) or ICMP attacks.

* TOC
{:toc}

# Spoofing, Flooding, Smurfing, MITM and ICMP protections

Spoofing is identity usurpation, Flooding is when someone tries to completely consume and exhaust a type of your server resources, number of connections, for exemple, Smurfing is to send packets to a lot of computers, with a spoofed sender address (the victim address, you). All the computers will reply to the packets to... you. This is some kind of a distributed spoofing-flooding. MITM is when the attacker is located between you and another server, all the traffic goes through him, we try to protect against this kind of hijack. Finally, the kernel can also protect himself against fake ICMP packets. 

All these protections have no real side effect on your server. Most of them are described in [montuy337513]'s [^1] page, in French.

```properties
cat > /etc/sysctl.d/00-FCSecurity << EOF
# Spoofing
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1
# Syn Flood
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_max_syn_backlog = 1024
# Smurfing
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
# Man In The Middle
# FC ICMP redirect rejection
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
# FC No ICMP redirect request
net.ipv4.conf.all.send_redirects = 0
net.ipv6.conf.all.send_redirects = 0
# FC No ICMP routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
EOF
```

# Apply
```bash
sysctl -n -e -q -p /etc/sysctl.conf
```

[montuy337513]: https://www1.zonewebmaster.eu/serveur-debian-securite:securiser-tcp-ip "Sécurisation de TCP/IP sur votre serveur dédié"
[^1]: https://www1.zonewebmaster.eu/serveur-debian-securite:securiser-tcp-ip 
