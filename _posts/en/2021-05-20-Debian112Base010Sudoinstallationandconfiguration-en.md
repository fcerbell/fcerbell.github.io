---
uid: Debian112Base010Sudoinstallationandconfiguration
title: Debian11, Base, Sudo installation and configuration
description: How to avoid and forbid direct root connections by locking the root password and to force specified users to gain root access with `sudo`. The first step is to install sudo and to allow its usage with the named user. Given that all connections will only be allowed by SSH, and only using a key-pair authentication (no password), the user will have no defined password and will need a passwordless access to the root account.
category: Computers
tags: [ GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Sudo, Security, Passwordless, Password ]
---

How to avoid and forbid direct root connections by locking the root password and to force specified users to gain root access with `sudo`. The first step is to install sudo and to allow its usage with the named user. Given that all connections will only be allowed by SSH, and only using a key-pair authentication (no password), the user will have no defined password and will need a passwordless access to the root account.

* TOC
{:toc}

# Prerequisites

## Create new variables

We need to define the named user who will be allowed to gain root access. We need the username `UN` and the user password `UP`. Lets add them to the configuration file :
```bash
cat << EOF >> /root/config.env
export UN="`grep 1000 /etc/passwd | cut -d: -f1`" # Named user name
export UP="`grep 1000 /etc/passwd | cut -d: -f1`" # Named user password
EOF
```

## Tune the default values

The variables are initialized with default values. You need to read them, check them, fix them, tune them, with your prefered text editor (`vi`, isn't it ?)
```
vi /root/config.env
```

## Load the variables in the environment

```bash
source /root/config.env
```

# Installation

Let's install `sudo`.
```bash
apt-get install -y sudo
```

# Named user configuration

Allow the named user to run any command, with password. At this stage, the user still has a password-protected account. Password login will be disabled after the SSH configuration.

![sudo.gif]({{ "/assets/posts/en/Debian112Base010Sudoinstallationandconfiguration/0cbff73d73be46b1bfd356df50b216dc.gif" | relative_url }})

```bash
adduser ${UN} sudo
```

Allow user to run any command without password (he will have password disabled later)
```bash
echo "${UN} ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UN}
```

