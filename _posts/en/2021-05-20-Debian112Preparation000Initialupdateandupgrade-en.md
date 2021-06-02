---
uid: Debian112Preparation000Initialupdateandupgrade
title: Debian11, Preparation, Debian 10 Buster update and upgrade to Debian 11 Bullseye
description: How to configure the binary packages repositories on a Linux Debian 10 Buster to upgrade the whole system to a Debian 11 Bullseye (testing at the time of writing), install `aptitude` and make the boot process faster.
category: Computers
tags: [ Debian11 Preparation, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Upgrade ]
date: 2021-05-20 00:00:00
---

How to configure the binary packages repositories on a Linux Debian 10 Buster to upgrade the whole system to a Debian 11 Bullseye (testing at the time of writing), install `aptitude` and make the boot process faster.

* TOC
{:toc}

# Prerequisites

Before starting this post serie to prepare a generic Debian 11 machine, I expect to have a clean Debian 10 Buster machine with the [Debian 11 Postinstall](/pages/en/tags/#debian11-postinstall) steps executed. If not, read the blog archives.


# Login as root

All the commands will be executed as *root*. On a fresh *Debian* installation, `sudo` is not installed. We'll take care of that very soon. You can either connect directly as *root*, if allowed, or connect as a user and use the `su -` command to become root.

# Reset repositories

First, I don't want to have all repositories in one file. I empty the repositories global file. All repositories will be listed in separate files.
```bash
echo > /etc/apt/sources.list
```

# Add repositories

Now, I create one file per release, with all the default repositories. I don't need to have the source repositories. And I commented all the lines that I don't need now, to speed up the *update* process and limit the database size.


## Stretch (9)

"old" *Stretch* at the time of writing. If I need to install an old package, I need to uncomment a line.
```bash
cat > /etc/apt/sources.list.d/stretch.list << EOF
# Stretch

#deb http://ftp.fr.debian.org/debian/ stretch main non-free contrib
#deb http://security.debian.org/ stretch/updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ stretch-proposed-updates non-free contrib main
#deb http://ftp.fr.debian.org/debian/ stretch-updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ stretch-backports main contrib non-free
#deb http://www.deb-multimedia.org/ stretch main non-free
EOF
```

## Stable/Buster (10)

This one is the current stable release. But I don't want the *proposed-updates* as they sometimes break the package upgrade process.
```bash
cat > /etc/apt/sources.list.d/buster.list << EOF
# Buster

deb http://ftp.fr.debian.org/debian/ buster main non-free contrib
deb http://security.debian.org/ buster/updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ buster-proposed-updates non-free contrib main
deb http://ftp.fr.debian.org/debian/ buster-updates main contrib non-free
deb http://ftp.fr.debian.org/debian/ buster-backports main contrib non-free
deb http://www.deb-multimedia.org/ buster main non-free
EOF
```

## Testing/Bullseye (11)

This one is currently "testing"  and the security updates repository is not available until it switches to stable.
```bash
cat > /etc/apt/sources.list.d/bullseye.list << EOF
# Bullseye

deb http://ftp.fr.debian.org/debian/ bullseye main non-free contrib
#deb http://security.debian.org/ bullseye/updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ bullseye-proposed-updates non-free contrib main
deb http://ftp.fr.debian.org/debian/ bullseye-updates main contrib non-free
deb http://ftp.fr.debian.org/debian/ bullseye-backports main contrib non-free
deb http://www.deb-multimedia.org/ bullseye main non-free
EOF
```

## SID/Bookworm (12)

This is currently the unstable (Sid, Still In Development) version, which will soon become the next testing version. I include the repositories to take some packages there, when they are not available in the stable release, but only from the main repository.
```bash
cat > /etc/apt/sources.list.d/bookworm.list << EOF
# Bookworm

#deb http://ftp.fr.debian.org/debian/ bookworm main non-free contrib
#deb http://security.debian.org/ bookworm/updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ bookworm-proposed-updates non-free contrib main
#deb http://ftp.fr.debian.org/debian/ bookworm-updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ bookworm-backports main contrib non-free
#deb http://www.deb-multimedia.org/ bookworm main non-free
EOF
```

## Trixie

Well, just to be complete. But I never used any package from the "development" repo on my long term online servers.
```bash
cat > /etc/apt/sources.list.d/sid.list << EOF
# Sid

#deb http://ftp.fr.debian.org/debian/ sid main non-free contrib
#deb http://security.debian.org/ sid/updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ sid-proposed-updates non-free contrib main
#deb http://ftp.fr.debian.org/debian/ sid-updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ sid-backports main contrib non-free
#deb http://www.deb-multimedia.org/ sid main non-free
EOF
```

## Experimental

Not crazy enough ! ;)

# Apt configuration

Whatever the uncommented lines are, the `apt` suite has to give higher priority to the targeted release, "bullseye". This rule is true before Bullseye is released as stable, and after, too. I increased the cache size because it could be needed when too many repositories are enabled. 
```bash
cat >/etc/apt/apt.conf << EOF
APT::Default-Release "bullseye";
APT::Cache-Limit 150000000;
Acquire::Languages fr,en;
Acquire::ForceIPv4 "true";
EOF
```

# Apt preferences

By default, testing has the same priority as backports. When they are available, I want to pick packages from backports first, to avoid pulling too many dependencies from testing, and, then, from testing. I force testing to have a lower priority than backports.

At the time of writing, the targeted release, Bullseye, is still testing. I skip this step and will apply this as soon as Bullseye is released.

```bash
cat >> /etc/apt/preferences.d/00-backportsbeforetesting << EOF
Package: *
Pin: release a=testing
Pin-Priority: 50
EOF
```

# Aptitude installation

I like `aptitude` on my servers. I am used to it, mainly *search*, *show*, *why* commands. Then, I don't like the blinky and verbose `apt` output. I also install immediately the deb-multimedia repository key to avoid annoying warnings. The first line prefills an answer in the Debian configuration system, before the question is asked, thus, debconf will not ask the question.
```bash
echo libc6 libraries/restart-without-asking boolean true | debconf-set-selections
apt-get -y update -oAcquire::AllowInsecureRepositories=true
apt-get -y --allow-unauthenticated install aptitude deb-multimedia-keyring
```

# System update

Ok, fine, now, it is time to apply my repositories preferences and to upgrade the system accordingly.
```bash
echo base-passwd base-passwd/system/user/irc/home/_var_run_ircd/_run_ircd boolean true | debconf-set-selections
apt-get -y update &&
apt-get -y upgrade &&
apt-get -y dist-upgrade &&
apt-get -y autoremove &&
apt-get -y autoclean &&
apt-get clean &&
cat /etc/os-release
```
Congratulations !

# Speedup the boot process

Noone has console access on my servers. I very rarely need to use a KVM/IPMI (used once every 5 years) during normal operations. Thus, I can reduce the GRUB menu timeout to save few seconds. Anyway, the root account will be locked without a password.
```bash
sed -i 's/GRUB_TIMEOUT=./GRUB_TIMEOUT=1/' /etc/default/grub
update-grub
```

# Reboot

This massive upgrade have probably changed the linux kernel, in such a case, a `reboot` is needed to use this new kernel. Custom module compilation use DKMS, DKMS will use `uname` to guess which linux-header to compile the module with. Thus I prefer to reboot now and not to forget later.

```bash
reboot
```
