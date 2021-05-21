---
uid: Debian111PostInstall020Debian-Networkconfiguration
title: Debian11, PostInstallation, Network configuration
description: Here is how to assign a static IP address and a different hostname to an existing Debian 10 Buster minimal installation. I also include how to disable the swap, when the server has enough memory for its purpose.
category: Computers
tags: [ GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Network configuration, Configuration, Swap ]
---

Here is how to assign a static IP address and a different hostname to an existing Debian 10 Buster minimal installation. I also include how to disable the swap, when the server has enough memory for its purpose.

You can find links to the related video recordings and printable materials at the [end of this post](#materials-and-links).

* TOC
{:toc}

# Prerequisites

## Load the variables in the environment

This post requires the WAN_IF, WAN_IP, WAN_GW, HN and DN environment variables to be loaded in your environment. They were initialized in the [Debian11 PostInstall Configuration variables](/Debian111PostInstall010Configurationvariables-en/) post and you only need to ensure that they are loaded :
```bash
source /root/config.env
```

# Preparation

As of today, Debian 11 Bullseye is still in testing. Despite it will soon enter in *Hard freeze* status, the last one before the release, it is not available everywhere. Thus, I'll assume that you'll start from a stable Debian 10 Buster minimal installation, available *everywhere* (AWS, Azure, GCP, Scaleway/Dedibox, ISO, ...) and upgrade it to a Debian 11 Bullseye minimal. 

Thus, I assume that you already have a Debian 10 Buster minimal installation deployed on your server.

## Assign static IP address

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

## Update hostname

``` bash
sed -i 's/root@[-0-9a-zA-Z_.]\+$/root@'${HN}'/g' \
/etc/ssh/ssh_host_ed25519_key.pub \
/etc/ssh/ssh_host_dsa_key.pub \
/etc/ssh/ssh_host_ecdsa_key.pub \
/etc/ssh/ssh_host_rsa_key.pub
sed -i "s/^127.0.1.1.*/127.0.1.1 ${HN}.${DN} ${HN}/" /etc/hosts 
echo "${HN}" > /etc/hostname
```

## Disable swap

``` bash
sed -i 's/UUID.*swap/#&/' /etc/fstab 
swapoff -a
```

# Test network new configuration

``` bash
reboot
```

