---
uid: Debian111PostInstall020Debian-Networkconfiguration
title: Debian11, PostInstallation, Network configuration
description: Here is how to assign a static IP address and a different hostname to an existing Debian 10 Buster minimal installation, how to disable the swap, when the server has enough memory for its purpose, and how to configure a second network interface, if this tutorial is executed to create a router between two networks, to distribute internet in your home or company, to protect your home private network against the internet, or to create a transparent parental control for your lovely teens.
category: Computers
tags: [ Debian11 Postinstall, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Network configuration, Configuration, Swap, Router, Gateway, Parental control, Control, Internet sharing ]
---

Here is how to assign a static IP address and a different hostname to an existing Debian 10 Buster minimal installation, how to disable the swap, when the server has enough memory for its purpose, and how to configure a second network interface, if this tutorial is executed to create a router between two networks, to distribute internet in your home or company, to protect your home private network against the internet, or to create a transparent parental control for your lovely teens.

* TOC
{:toc}

# Prerequisites

As of today, Debian 11 Bullseye is still in testing. Despite it will soon enter in *Hard freeze* status, the last one before the release, it is not available everywhere. Thus, I'll assume that you'll start from a stable Debian 10 Buster minimal installation, available *everywhere* (AWS, Azure, GCP, Scaleway/Dedibox, ISO, ...) and upgrade it to a Debian 11 Bullseye minimal. 

Thus, I assume that you already have a Debian 10 Buster minimal installation deployed on your server.

## Create new variables

This post needs to have information about the safe IP addresses, the IP addresses that should never be blocked. It can be the IP addresse of your private LAN, if your have, or the personnal IP public addresses used from your home to connect to your public server. 
If you are configuring a gateway or a router with 2 network interfaces, you also need ton configure variables for the interface name (LAN_IF) and for the LAN gateway (LAN_GW). This second interface will be considered as secured and will expose internal services, if any, such as a proxy, a DNS or an NTP server.

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

## Load the variables in the environment

This post also requires the WAN_IF, WAN_IP, WAN_GW, HN and DN environment variables to be loaded in your environment. They were initialized in the [Debian11 PostInstall Configuration variables](/Debian111PostInstall010Configurationvariables-en/) post and you only need to ensure that they are loaded :
```bash
source /root/config.env
```

# Assign static WAN IP address
First, I configure the external public network interface with a static IP address and gateway.
```bash
cat > /etc/network/interfaces << EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# Local Loopback
auto lo
iface lo inet loopback

# WAN
auto ${WAN_IF}
iface ${WAN_IF} inet static
    address ${WAN_IP}
    gateway ${WAN_GW}

EOF
```

# Assign static LAN IP address
If the server is a router or a gateway, I also configure the second network interface with a static IP address and a gateway. This
is not needed for a public server with only one public external network interface.
```bash
cat >> /etc/network/interfaces << EOF
# LAN
auto ${LAN_IF}
iface ${LAN_IF} inet static
    address ${LAN_IP}
EOF
```

# Update hostname

``` bash
sed -i 's/root@[-0-9a-zA-Z_.]\+$/root@'${HN}'/g' \
/etc/ssh/ssh_host_ed25519_key.pub \
/etc/ssh/ssh_host_dsa_key.pub \
/etc/ssh/ssh_host_ecdsa_key.pub \
/etc/ssh/ssh_host_rsa_key.pub
sed -i "s/^127.0.1.1.*/127.0.1.1 ${HN}.${DN} ${HN}/" /etc/hosts 
echo "${HN}" > /etc/hostname
```

# Disable swap

``` bash
sed -i 's/UUID.*swap/#&/' /etc/fstab 
swapoff -a
```

# Test network new configuration

``` bash
reboot
```

