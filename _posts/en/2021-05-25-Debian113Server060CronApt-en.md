---
uid: Debian113Server060CronApt
title: Debian11, Server, CronApt to send upgrade notifications
description: cron-apt installation and configuration for a Debian 11 Bullseye server. It automatically updates the list of available packages, downloads the available upgrades for the installed packages and sends a notification email to the admin. It can also automatically upgrade the system, but I don't use this feature.
category: Computers
tags: [ Debian11 Server, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Cron-apt, Update, Upgrade, Download, Unattended upgrades, Notification ]
published: false
---

`cron-apt` installation and configuration for a Debian 11 Bullseye server. It automatically updates the list of available packages, downloads the available upgrades for the installed packages and sends a notification email to the admin. It can also automatically upgrade the system, but I don't use this feature.

* TOC
{:toc}

# Prerequisites

This article only depends on the [Generic machine preparation](/pages/en/tags/#debian11-preparation).

# Installation
The installation does not ask any question.
```bash
apt-get install -y cron-apt
```

# Activate notifications
By default, `cron-aot` does the update and download steps, but nothing else. I activate the email notification plugin to send emails when package upgrades are available. It is possible to activate the unattended-upgrades, but this could break the system if there is a bug in the package. It is better to be notified, and then to read the changelogs and apply the upgrades manually.
```bash
cp /usr/share/doc/cron-apt/examples/9-notify /etc/cron-apt/action.d/
```

# Configure notifications
Despite I activated the notification plugin. I will install `logcheck` very soon, `cron-apt` sends all the useful information in its standard output, it is captured by cron and sent to the administrator's email. Furthermore, it is copied to `cron`'s logs and `logcheck` will also send it to the administrator. That's why I do not configure it to send emails. It could be configured here, to send emails to someone else than root, thus root would have the cron email and `cron-apt` would send the report to someone else, such as an administrator mailling-list.

```bash
cat << EOF > /etc/cron-apt/config
# Configuration for cron-apt. For further information
# about the possible configuration settings see
# /usr/share/doc/cron-apt/README.gz.

OPTIONS="-o quiet=2"
#MAILON="output"
SYSLOGON="output"
#MAILTO="root"
MINTMPDIRSIZE=10
NOLOCKWARN=""
EOF
```

# Test
Let's run a test. It should be empty, we just installed our server, it is supposed to be up-to-date.
```bash
/usr/sbin/cron-apt
```

# Materials and links

I found an interesting page on [zonewebmaster] [^1], in French.

# Footnotes

[zonewebmaster]: https://www1.zonewebmaster.eu/serveur-debian-securite:install-cron-apt "Sécurité d'un serveur Debian : Cron-Apt"
[^1]: https://www1.zonewebmaster.eu/serveur-debian-securite:install-cron-apt
