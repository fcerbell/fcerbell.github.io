---
uid: Debian111PostInstall010Configurationvariables
title: Debian11, PostInstallation, Configuration variables
description: All the installation and configurations steps will need some information again and again. The very first time these information are needed, I store them in a configuration file and I source it. Thus, I do not have to enter them again and I have no risk of inconsistency. 
category: Computers
tags: [ GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Configuration variables, Variables ]
---

All the installation and configurations steps will need some information again and again. The very first time these information are needed, I store them in a configuration file and I source it. Thus, I do not have to enter them again and I have no risk of inconsistency. You'll need this information several times. Instead to change the code, I want to cut-and-paste it, I parametrized the code blocks. I ask questions at the begining of the installation and save the answers in environment variables. Given that I need to reboot several times, I save these variables in a file. This file will be sourced by the other steps to avoid asking again and again the same information and avoid mistakes.

You can find links to the related video recordings and printable materials at the [end of this post](#materials-and-links).

* TOC
{:toc}

# Configuration variables

Whatever you choose to install, a VM or a bare-metal machine, you have to choose at least:
- the hostname
- the named username
- a static IP address (mandatory for servers, optional for workstations/laptops)

The named user is the same, if a step needs a system account or if one of the applications needs a user account. Basically, this user should be YOU.

## Create the variables

I first add the variables in the file with default values. I split this in two steps because the second part needs the first part to be executed, in order to fill the default values.
```bash
cat << EOF > /root/config.env
export HN="`hostname`" # Host name
export DN="`domainname -d`" # Domain name
export WAN_IF="`ip addr | grep 'en[po][0-9]\(s[0-9]\)\{0,1\}:.*state UP' | cut -d: -f2 | sed 's/ //' | head -n 1`" # External public network interface
EOF
source /root/config.env
cat << EOF > /root/config.env
export WAN_IP="`ip addr | grep "inet.*${WAN_IF}" | sed 's/.*inet \([0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\)\/[0-9]\+.*/\1/' | head -n 1`" # External public IP address
export WAN_NM="`ip addr | grep "inet.*${WAN_IF}" | sed 's/.*inet [0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\/\([0-9]\+\).*/\1/' | head -n 1`" # External public netmask
export WAN_GW="`ip route | grep default | sed 's/[^0-9]*\([0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\).*/\1/'`" # External public gateway/router
EOF
```

## Tune the default values

The variables are initialized with default values. You need to read them, check them, fix them, tune them, with your prefered text editor (`vi`, isn't it ?)
```bash
vi /root/config.env
```

![2021-05-19_10-53.png]({{ "/assets/posts/en/Debian111PostInstall010Configurationvariables/f94e4b1f592240cd9d9755da4286a778.png" | relative_url }})


## Load the variables in the environment

```bash
source /root/config.env
```


