---
uid: Debian111PostInstall021Debian-Networkconfiguration-Router
title: Debian11, PostInstallation, Network configuration Router
description: Configure a second network interface, which is useful if this tutorial is executed to create a router between two networks, to distribute internet in your home or company, to protect your home private network against the internet, or to create a transparent parental control for your lovely teens.
category: Computers
tags: [ Debian11 Postinstall, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Network configuration, Configuration, Router, Gateway, Parental control, Control, Internet sharing ]
---

I describe here how to configure a second network interface, which is useful if this tutorial is executed to create a router between two networks, to distribute internet in your home or company, to protect your home private network against the internet, or to create a transparent parental control for your lovely teens.

You can find links to the related video recordings and printable materials at the [end of this post](#materials-and-links).

* TOC
{:toc}

# Prerequisites

## Previous steps

The network configuration file should have been initialized with the [Debian11 PostInstall Debian Network configuration](/Debian111PostInstall020Debian-Networkconfiguration-en/) post.

## Create new variables

This step needs to have information about the second interface configuration. This second interface will be considered as secured and will expose internal services, if any, such as a proxy, a DNS or an NTP server.

```bash
cat << EOF >> /root/config.env
export LAN_IF="`ip addr | grep 'en[po][0-9]\(s[0-9]\)\{0,1\}:.*state' | cut -d: -f2 | sed 's/ //' | head -n 2 | tail -n 1`" # Internal private network interface
export LAN_IP="`ip addr | grep "inet.*${LAN_IF}" | sed 's/.*inet \([0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\)\/[0-9]\+.*/\1/' | head -n 1`" # Internal private network IP address
export LAN_NM="`ip addr | grep "inet.*${LAN_IF}" | sed 's/.*inet [0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\/\([0-9]\+\).*/\1/' | head -n 1`" # Internal private network netmask
export LAN_GW="${LAN_IP}" # Internal private network gateway/router
EOF
```

## Tune the default values

The variables are initialized with default values. You need to read them, check them, fix them, tune them, with your prefered text editor (`vi`, isn't it ?)
```bash
vi /root/config.env
```

# Load the variables in the environment

```bash
source /root/config.env
```

## Assign static IP address

```bash
cat >> /etc/network/interfaces << EOF
# LAN
auto ${LAN_IF}
iface ${LAN_IF} inet static
    address ${LAN_IP}
EOF
```

# Test network new configuration

```bash
reboot
```

