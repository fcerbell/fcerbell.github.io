---
uid: Debian113Server060CronApt
title: Debian11, Server, CronApt to keep the system up-to-date
description: cron-apt installation and configuration for a Debian 11 Bullseye server. It automatically updates the list of available packages, downloads the available upgrades for the installed packages, sends a notification email to the admin, and can also automatically upgrade the system.
category: Computers
tags: [ Debian11 Server, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Cron-apt, Update, Upgrade, Download, Unattended upgrades, Notification ]
date: 2021-05-25 00:01:00
---

`cron-apt` installation and configuration for a Debian 11 Bullseye server. It automatically updates the list of available packages, downloads the available upgrades for the installed packages, sends a notification email to the admin, and can also automatically upgrade the system.

* TOC
{:toc}

# cron-apt vs unattended-upgrades
In Debian based systems, there are two candidates : `cron-apt` and `unattended-upgrades`. The first one is the older, the second one is younger, but already more than 10 years old. 

Both are reliable. Both can update the package lists, download the upgrades, notify and install the upgrades. The differences, if any, are more in the last step, `unattended-upgrades` tries to guess if a package upgrade will trigger a question, if yes it does not install it, if no, it does. 

To make it short, `cron-apt` might be server-oriented and `unattended-upgrades` workstation oriented. In my case, I'm only interested in the update-download-notify features, not in the automatic installations. I want to manually check the upgrades. Both are good choices, and I chose to use `cron-apt` everywhere.

# Prerequisites

This article only depends on the [Generic machine preparation](/pages/en/tags/#debian11-preparation).

# Installation
The installation does not ask any question.
```bash
apt-get install -y cron-apt
```

# Activate notifications
By default, `cron-apt` does the update and download steps, but nothing else. I activate the email notification plugin to send emails when package upgrades are available. It is possible to activate the unattended-upgrades, but this could break the system if there is a bug in the package. It is better to be notified, and then to read the changelogs and apply the upgrades manually.
```bash
cp /usr/share/doc/cron-apt/examples/9-notify /etc/cron-apt/action.d/
```

# Configure notifications

![dc6275a2e8dd52ae207751ae81b1b1a1.png]({{ "/assets/posts/en/Debian113Server060CronApt/d9b9274ec02e4c428abdc39edd4bc1c9.png" | relative_url }})

`cron-apt` can send email notifications by himself. It also write a lot in its standard output, which is captured by `cron`, logged in logfiles and sent to the administrator. Finally, I'll install loganalyzers that will analyze logs and send summaries. 

All these options can be leveraged to achieve different goals, such as notifying different people through different channels. In my case, the log analyzers will filter out the normal activity and this one is a normal activity, it will not be sent to the administrator. I keep `cron` notifications anyway and I configure `cron-apt` to send notification only if there are available upgrades.

Thus, in normal activity, I might receive a `cron` email only, if something happened, and I'll be notified by `cron` and `cron-apt` if there are available upgrades.

```bash
cat << EOF > /etc/cron-apt/config
# Configuration for cron-apt. For further information
# about the possible configuration settings see
# /usr/share/doc/cron-apt/README.gz.

OPTIONS="-o quiet=2"
MAILON="output"
SYSLOGON="output"
MAILTO="root"
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

I found an interesting page on [zonewebmaster][zonewebmaster] [^1], in French.

# Footnotes

[zonewebmaster]: https://www1.zonewebmaster.eu/serveur-debian-securite:install-cron-apt "Sécurité d'un serveur Debian : Cron-Apt"
[^1]: https://www1.zonewebmaster.eu/serveur-debian-securite:install-cron-apt
