---
uid: Debian113Server050TempMTAmsmtp-mta
title: Debian11, Server, mSMTP-MTA to send emails alerts
description: Every server is not a mail server. There is no need for a full Mail Transport Agent (MTA) on each. A simple one, such as `msmtp` is higly sufficient for the server to send email to a smart host. I use it as an `exim` replacement to provide simple email feature without local delivery on my workstations and servers.
category: Computers
tags: [ Debian11 Server, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, MTA, Mail Transport Agent, mSMTP, Firewall, IPTables, Smarthost ]
date: 2021-05-25 00:00:00
---
Every server is not a mail server. There is no need for a full Mail Transport Agent (MTA) on each. A simple relay, such as `msmtp` is higly sufficient for the server to send email to a smart host. I use it as an `exim` replacement to provide simple email feature without local delivery on my workstations and servers. This documentation is partially inspired by [yakati][yakati] [^1], in French.

* TOC
{:toc}

# Prerequisites

This article only depends on the [Generic machine preparation](/pages/en/tags/#debian11-preparation).

## Variables
We need to define the SMTP smart host, the mail hub or mail server, we already defined the other variables.

| Variable | Name | Description | Defined in |
|---|:---|:---|:---|
| Hostname | HN | The name of this machine | [Configuration variables](/Debian111PostInstall010Configurationvariables-en/) |
| Domainname | DN | The domain name of this machine | [Configuration variables](/Debian111PostInstall010Configurationvariables-en/) |
| Smarthost | SMTP_HOST | The SMTP hub server FQDN[^2] | below |

### Create
```bash
source /root/config.env
cat << EOF >> /root/config.env
export SMTP_HOST="smtp.${DN}" # SMTP server
EOF
vi /root/config.env
```

### Reload
We need to reload the variables in the environment.
```bash
source /root/config.env
```

# Installation
This package is very lightweight, let's install it.
```bash
apt-get install -y msmtp-mta
```

# Configuration
It needs to know the FQDN[^2] of the smart host, ie the official fully featured mail server, which is able to route emails
through the internet to the destination. It also needs to know your server FQDN to rewrite local sender names.

```bash
cat << EOF >/etc/msmtprc 
account default
host ${SMTP_HOST}
auto_from on
maildomain ${HN}.${DN}
EOF
```

# IPTables firewall update
Outgoing network is blocked by default, we need to create a new chain to define what is the default outgoing mail traffic, using
SMTP (TCP/25). We include this accept exception to the outgoing traffic on the WAN interface and we reload the firewall
configuration.
```bash
sed -i 's/^-N WAN_input$/-N SMTP\n-A SMTP -p tcp --dport 25 -j ACCEPT\n\n&/' /etc/iptables/rules.v4
sed -i 's/^-N WAN_output$/&\n-A WAN_output -j SMTP/' /etc/iptables/rules.v4
systemctl restart netfilter-persistent
```

# Materials and links
This documentation is partially inspired by [yakati][yakati] [^1], in French.

# Footnotes

[yakati]: https://www.yakati.com/art/envoyer-des-mails-depuis-un-serveur-avec-msmtp.html "Envoyer des mails depuis un server avec mSMTP"
[^1]: https://www.yakati.com/art/envoyer-des-mails-depuis-un-serveur-avec-msmtp.html
[^2]: Fully Qualified Domain Name
