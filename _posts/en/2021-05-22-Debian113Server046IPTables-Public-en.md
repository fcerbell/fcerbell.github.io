---
uid: Debian113Server046IPTables-Public
title: Debian11, Server, IPTables - Public
description: After a generic IPTables configuration, I apply some public server specific rules, to whitelist my IP addresses. In normal situations, I should never be blocked, but I can also do mistakes, forget something, ... and become blacklisted.
category: Computers
tags: [ Debian11 Server, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation ]
---

After a generic IPTables configuration, I apply some public server specific rules, to whitelist my IP addresses. In normal situations, I should never be blocked, but I can also do mistakes, forget something, ... and become blacklisted.

* TOC
{:toc}

# Prerequisites

## Previous steps
The generic [IPTables](/Debian113Server045IPTables-en/) configuration, should be applied.

## Create new variables
We need the MY_IP and MY_GW variable which can whitelist a single IP address with a /32 netmask or a whole class.
```bash
cat << EOF >> /root/config.env
export MY_IP="aaa.bbb.ccc.ddd" # Whitelisted IP
export MY_NM="32" # Whitelisted Netmask
EOF
```

## Tune new variables
```bash
vi /root/config.env
```

## Reload the variables
Ensure that the variable are available, by loading the configuration script. This is mandatory because we rebooted in the previous step.
```bash
source /root/config.env
```

# Whitelist me
I only add a rule in the WAN_input rule (the externally incoming packets to accept) to accept my personal IP address.
```bash
sed -i 's/^-N WAN_input/&\n# Home IP\n-A WAN_input -s '${MY_IP}'\/'${MY_NM}' -j ACCEPT/' /etc/iptables/rules.v4
```

# Apply
The current SSH connection was established after the generic firewall rules were applied with a reboot. Thus, it is registered in the connection table and I can simply reload the rules.
```bash
systemctl restart netfilter-persistent
```

