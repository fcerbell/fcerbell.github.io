---
uid: Debian113Server080Portsentrytoblockportscans
title: Debian11, Server, Portsentry to block port scans
description: Installing and configuring Portsentry as a second line of defense against port scanning, after IPTables lscan and psd rules. It will ban attacker's machines temporarily of definitely, but will whitelist my own network and IP addresses.
category: Computers
tags: [ Debian11 Server, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Portsentry, Fail2ban, Security, IPTables, TCPWrappers ]
date: 2021-05-31 00:00:00
---

Installing and configuring Portsentry as a second line of defense against port scanning, after IPTables lscan and psd rules. It will ban attacker's machines temporarily of definitely, but will whitelist my own network and IP addresses.

* TOC
{:toc}

# Portsentry presentation

Portsentry listen to most unused network ports. It receives all the incoming connections and can detect sequences of connections from a source to detect a network port scan. Then, it can react with arbitrary commands, to block the scans, to return garbage, to trigger countermeasures... Most scans will be detected and blocked by the IPTables chain, PortSentry is configured as a second line of defense. It will use TCPWrappers and IPTables to block the scans on UDP and TCP. It will also be configured to ignore my own IP addresses.


# Prerequisites
This article only depends on the [Generic machine preparation](/pages/en/tags/#debian11-preparation) post serie.

## Existing variables
We need the `LAN_*` variable which was already defined in the configuration file, the [Configuration variables](/Debian111PostInstall010Configurationvariables-en/) post.

## Reload the variables
Ensure that the variables are available, by loading the configuration script :
```bash
source /root/config.env
```

# Common installation
I first pre-configure the answer to a question that would otherwise be asked by the package and I install it.
```bash
echo portsentry portsentry/warn_no_block string "" | debconf-set-selections
apt-get install -y portsentry
```

## Automatic bind to unused ports
Configure `portsentry` to use the *advanced* mode, which listen to all the ports below a threashold, both for UDP and TCP. This could be an issue if a service try to bind himself, later to a dynamic port and if portsentry is already bound to this port. By default, the threshold is set to *1024*
```bash
sed -i 's/TCP_MODE="tcp"/TCP_MODE="atcp"/' /etc/default/portsentry
sed -i 's/UDP_MODE="udp"/UDP_MODE="audp"/' /etc/default/portsentry
```

## Block scans with IPTables, CHAOS and TCPWrappers
Then, let's activate the scan blocking using IPTables and TCPWrappers. Portsentry will execute the provided `iptables` command and add the attacking host in the `/etc/hosts.deny` file. Both are useful because IPTables is not persistent, whereas TCP wrappers is persistent. Furthermore, I provide my own `iptables` command to use the *CHAOS* target instead of *DROP*. The attacker knows that there is machine, ignoring the packets would inform him that we are protecting the machine and he will try something else. Using the *CHAOS* target returns random data, it will not look like we are protecting ourself but will not provide him useful information.
**It would be better** to insert the iptable blocking rules **after** the iptables whitelist rule, and **before** the *ACCEPT* rules. I would need to know the white list rule number to do that, so I'd need to create a whitelist `iptables` chain in the [IPTable configuration](/Debian113Server045IPTables-en/), but I did not. You can improve your scripts.
```bash
sed -i 's/BLOCK_UDP="0"/BLOCK_UDP="1"/' /etc/portsentry/portsentry.conf
sed -i 's/BLOCK_TCP="0"/BLOCK_TCP="1"/' /etc/portsentry/portsentry.conf
sed -i 's/RESOLVE_HOST = "0"/RESOLVE_HOST = "1"/' /etc/portsentry/portsentry.conf
sed -i 's/^KILL_ROUTE/#&/' /etc/portsentry/portsentry.conf
sed -i 's/^#\?KILL_ROUTE="\/sbin\/iptables -I INPUT -s $TARGET$ -j DROP"/KILL_ROUTE="\/sbin\/iptables -I INPUT -s $TARGET$ -j CHAOS"/' /etc/portsentry/portsentry.conf
```

## Whitelist safe IPs
I can make some mistake, I could want to scan my own server... But I dont want to be blocked. Thus, I add my own IP address in the list to ignore and, just in case, I also add it to the TCPWrapper's whitelist.
```bash
echo "ALL: ${LAN_IP}/${LAN_NM}" >> /etc/hosts.allow
echo "${LAN_IP}/${LAN_NM}" >> /etc/portsentry/portsentry.ignore.static
```

## Apply the configuration
```bash
systemctl restart portsentry
```

# Strengthen with Fail2ban
[Fail2ban](/Debian113Server070fail2bantobanobviousattacksources-en/) can use `portsentry` log to take further actions. When `portsentry` blocks a scan, it blocks it with `iptables` for TCP and UDP scans, but this is not persisted in case of server reboot or service restart. It uses also TCPWrappers, which are persisted. `fail2ban` will double block using `iptables`, but it also has a persisted database and will restore the blocking rules in case or restart.
```bash
> /var/lib/portsentry/portsentry.history
cat << EOF > /etc/fail2ban/jail.d/portsentry.conf
[portsentry]
enabled = true
EOF
systemctl restart fail2ban
```

# Supports and links

# Footnotes
