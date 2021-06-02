---
uid: Debian111PostInstall000Introduction
title: Debian11, PostInstallation, Introduction
description: This post is the first of a long serie. I have my own domain, with a bunch of services, including a full email stack with anti-spams, anti-viruses, virtual mailboxes, server-side filters (sieve/managesieve), several web applications such as Redmine, mercurial, FileZ, Pydio, monitoring tools. I'll reinstall everything from scratch, and update my installation notes. You'll learn how I install, secure, configure, administrate my VMs, public internet servers, workstations and laptops.
category: Computers
tags: [ Debian11 Postinstall, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Upgrade, IPTables, CronApt, Fail2Ban, PortSentry, RKHunter, Tripwire, Logcheck, Logwatch, FWLogwatch, BackupManager, Monit, OpenNTPd, Prometheus, AlertManager, Grafana, Bind, Named, Mail Transport Agent, MTA, Mail Delivery Agent, MDA, mSMTPd, DHCP, isc-DHCPd, TFTPd, NFS, NetBoot, Router, Firewall, Apache2, mod_security2, mod_evasive, mod_rewrite, mod_proxy, mod_wstunnel, WebSockets, Authentication, Awffull, Webalyzer, Awstats, VHosts, SSL, HTTP, HTTPs, Taskwarrior, Taskd, Joplin, Mariadb, Mysql, PHPMyadmin, YOURLS, URL Shortener, Shortener, PrivateBin, ZeroBin, PasteBin, Mercurial, Hg, HgWeb, Redmine, Buildbot, CICD, Squid, Proxy, e2Guardian, DansGuardian, Parental Control, Control, Dovecot, ManageSieve,Sieve, Postfix, Virtual Users, Virtual Domains, Virtual Mailboxes, Virtual Email, Users, Domains, Mailboxes, Email, PostfixAdmin, Amavis, SpamAssassin, Razor, PyZor, Mailzu, RBLCheck, MailGraph, QueueGraph, PostGrey, Procmail, Roundcube, Squirrel, DSpam ]
date: 2021-05-19 00:00:00
---

This post is the first of a long serie. I have my own domain, with a bunch of services, including a full email stack with anti-spams, anti-viruses, virtual mailboxes, server-side filters (sieve/managesieve), several web applications such as Redmine, mercurial, FileZ, Pydio, monitoring tools. This was installed in 2013 on a Debian 7 Wheezy, never cracked, and very stable (currently 900 days uptime). Debian 11 Bullseye is about to be released, I'll reinstall everything from scratch, and update my installation notes. I decided to share my [Debian][debianorg] [^1] installation notes for VM, servers, and workstation full installation. You'll learn how I install, secure, configure, administrate my VMs, public internet servers, workstations and laptops. I don't pretend to have the perfect installation procedure, but I'm pretty sure that you'll learn someting today.

You can find links to the related video recordings and printable materials at the [end of this post](#materials-and-links).

* TOC
{:toc}

# Introduction

I use only Debian since 1999 everywhere, on my workstations, laptops, servers. I own my domains and manage the DNS, the mail servers, web servers, file sharing, project management... Despite Debian is said to never need a reinstallation thanks to apt, I prefered to reinstall my machines from time to time. Each time, I learnt something and kept myself uptodate.

I always wrote documentations to be able to reproduce my installations and configurations. I'm now taking and sharing my notes between all my devices with [Joplin][Joplin] [^2] in markdown and serving my blog with [Jekyll][Jekyll] [^3] in markdown... Guess what, you're lucky today, I'll convert my notes to my blog. 

# Covered topics

I summarized the list in the following keywords :
Debian, Buster, Bullseye, upgrade, iptables, cronapt, cron-apt, fail2ban, portsentry, rkhunter, tripwire, logcheck, logwatch, fwlogwatch, backupmanager, backup-manager, monit, openntpd, prometheus, alertmanager, grafana, bind, named, mail transport agent, MTA, mail delivery agent, MDA, msmtpd, dhcp, isc-dhcpd, tftpd, nfs, netboot, router, firewall, apache2, mod_security2, mod_evasive, mod_rewrite, mod_proxy, mod_wstunnel, websockets, authentication, awffull, webalyzer, awstats, vhosts, ssl, http, https, taskwarrior, taskd, joplin, mariadb, mysql, phpmyadmin, yourls, url shortener, privatebin, zerobin, pastebin, mercurial, hg, hgweb, redmine, buildbot, cicd, squid, proxy, e2guardian, dansguardian, parental control, Dovecot, Managesieve, manage-sieve, sieve, Postfix, virtual users, virtual domains, virtual mailboxes, Postfixadmin, amavis, spamassassin, razor, mailzu, rblcheck, mailgraph, queuegraph, postgrey, procmail, roundcube, squirrel, dspam

# Uncovered topics

When installing a VM, there are some specific steps to think about. Assigning a static IP address is one of them, but some are less obvious. Do you master the hypervisor ? Probably not in the cloud and your VM disks are nothing else than files that can be copied and analyzed by third party, think about the *patriot act* and *safe harbour* US laws, thus disk encryption is a must.

Despite it is possible to convert an already installed system from unencrypted to encrypted disk, without a console access, I will not cover these edge configuration. But you can see this very small post as food for thought.

# Structure of these posts

- The first part, bootstraping, describes the very first steps after a machine installation
- The second part, base, describes the common tooling that I install on every machines
- The third part, server, describes the common tools (security, monitoring, backups...) that I install on every server
- The fourth part, services, describes each of the potential services to deploy in a server
- The fifth and last part is about finalization before the last reboot and grand opening

I'm lazy and wrote my notes to be easily replicable, by cut-and-paste of the code. Thus, you'll be able to easily reproduce, but I **strongly** suggest that you perfectly understand not only each code-block before executing it, but also the reason why I chose to write it this way. Each configuration choice was designed to fit all the other choices, to make the whole system consistent.

You need to `ssh` into your machine and `su -` yourself to `root`. If you don't know what it means, you can still read, bookmark this page and come back later, but please do not try to apply on public servers

# Materials and Links

- [Debian][debianorg]
- [Joplin][joplin]
- [Jekyll][jekyll]

# Footnotes

[debianorg]: http://www.debian.org "Debian website"
[^1]: [http://www.debian.org][debianorg] "Debian website"

[joplin]: https://joplinapp.org/ "Joplin app website"
[^2]: [https://joplinapp.org/][joplin] "Joplin app website"

[jekyll]: https://jekyllrb.com/ "Jekyll website"
[^3]: [https://jekyllrb.com/][jekyll] "Jekyll website"
