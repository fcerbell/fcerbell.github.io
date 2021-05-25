---
uid: Debian113Server010SSHandSudorootlock
title: Debian11, Server, SSH and Sudo root lock
description: I'll never have to connect to my servers from the console, and I'll never need a password authenticated sudo command, thus I don't need any password based authtication. I'll always connect through ssh with keys, thus I can lock the passwords for both the root account and the named account.
category: Computers
tags: [ Debian11 Server, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Configuration, Sudo, SSH, Lock, Root, Account, Security, Key-pair ]
---
I'll never have to connect to my servers from the console, and I'll never need a password authenticated sudo command, thus I don't need any password based authtication. I'll always connect through ssh with keys, thus I can lock the passwords for both the root account and the named account.

* TOC
{:toc}

# Prerequisites

## Previous steps
 
- [SSH installation and configuration](/Debian112Preparation020SSHinstallationandconfiguration-en/)
- [Sudo Installation and Configuration](/Debian112Preparation010Sudoinstallationandconfiguration-en/)

## Existing variables

We need only the username (UN) which is already defined.

## Reload the variables

We need to load the named username defined in the configuration file during the [Sudo Installation and Configuration](/Debian112Preparation010Sudoinstallationandconfiguration-en/) post. Ensure that the configuration variables are loaded in the environment.
```bash
source /root/config.env
```

# Lock root password

Lock direct root connections from the console but also with `su`. This will also prevent any `single` or `recovery` boot from the console or KVM... This is completely optional and potentially dangerous in case or severe system issue. The only option will be to use console or KVM and to add a boot parameter such as `init=/bin/sh`, and you'll need to perfectly master what you are doing.
```bash
passwd -l root
```
**Attention, this completely blocks any console login for root and with root password, including "single boot" or "boot failure recovery (fsck failures)".** 

# Lock user password

Now, I can open direct passwordless connections to the named user and to the root user, thus I can lock the named user password to defeat brute-force attacks, if there is one.
**For server only, never do that on workstations, you would not be able to connect from the console or from the graphical greeter !**
```bash
[ ! -z "${UN}" ] && passwd -l ${UN}
```
