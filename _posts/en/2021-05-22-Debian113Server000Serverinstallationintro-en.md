---
uid: Debian113Server000Serverinstallationintro
title: Debian11, Server, Server installation intro
description: Despite Debian is the best distribution ever to run a server, It needs to be upgraded from time to time to switch to better technologies. I'm about to migrate my 8 years old server from Debian 7 technologies to Debian 11 technologies, to use better firewall protections, to use prometheus/grafana instead of munin,... Here is a list of the common base installation procedures which are executed on all my servers (security, monitoring, ....).
category: Computers
tags: [ Debian11 Server, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Introduction, Base, Generic ]
---

Despite Debian is the best distribution ever to run a server, It needs to be upgraded from time to time to switch to better technologies. I'm about to migrate my 8 years old server from Debian 7 technologies to Debian 11 technologies, to use better firewall protections, to use prometheus/grafana instead of munin,... Here is a list of the common base installation procedures which are executed on all my servers (security, monitoring, ....).

* TOC
{:toc}

## Prerequisites

Before starting this post serie to specialize a machine with a server role, I expect to have a clean Debian 11 Bullseye server with the [Debian 11 Preparation](/pages/en/tags/#debian11-preparation) steps executed. If not, read the blog archives.

## Old configuration

Here is a short summary of the server configuration on my old server :
- IPTables scripts
- portsentry
- Tripwire
- Logcheck
- Logwatch

It is very stable, as you can see in the below capture, more than 900 days of uptime.

![oldserver.gif]({{ "/assets/posts/en/Debian113Server000Serverinstallationintro/fe355b596f7f4a62a30fa41cbd680401.gif" | relative_url }})

It was never hacked since I installed it and rejected all attempts. The *only* successfull attempt was to guess a mailbox weak password and use my mail server to send spams. But, I was able to stop it within minutes, thanks to the monitoring and alerting systems.

## New configuration

This blog posts serie describes how to install and configure the following base server tools as I do on all my servers. These is my common server base, before the server is specialized on usefull business tasks. I'll describe the actual useful business services in the [Debian 11 Services]() post serie.

- Security
  - iptables
  - portsentry
  - tripwire
  - rkhunter
  - fail2ban
  - logcheck/logwatch/fwlogwatch
  - backupmanager
- Monitoring
  - Monit
  - Prometheus, Alertmanager
  - Grafana


