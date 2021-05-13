---
uid: Debian11BullseyePreparation
title: Debian 11 Bullseye upgrade and full installation
description:
category: Debian
tags: [ Debian, Buster, Bullseye, upgrade, iptables, cronapt, cron-apt, fail2ban, portsentry, rkhunter, tripwire, logcheck, logwatch, fwlogwatch, backupmanager, backup-manager, monit, openntpd, prometheus, alertmanager, grafana, bind, named, mail transport agent, MTA, mail delivery agent, MDA, msmtpd, dhcp, isc-dhcpd, tftpd, nfs, netboot, router, firewall, apache2, mod_security2, mod_evasive, mod_rewrite, mod_proxy, mod_wstunnel, websockets, authentication, awffull, webalyzer, awstats, vhosts, ssl, http, https, taskwarrior, taskd, joplin, mariadb, mysql, phpmyadmin, yourls, url shortener, privatebin, zerobin, pastebin, mercurial, hg, hgweb, redmine, buildbot, cicd, squid, proxy, e2guardian, dansguardian, parental control, Dovecot, Managesieve, manage-sieve, sieve, Postfix, virtual users, virtual domains, virtual mailboxes, Postfixadmin, amavis, spamassassin, razor, mailzu, rblcheck, mailgraph, queuegraph, postgrey, procmail, roundcube, squirrel, dspam ]
published: false
---

This post is the first of a long serie. I have my own domain, with a bunch of services, including a full email stack with anti-spams, anti-viruses, virtual mailboxes, server-side filters (sieve/managesieve), several web applications such as Redmine, mercurial, FileZ, Pydio, monitoring tools. This was installed in 2013 on a Debian 7 Wheezy, never cracked, and very stable (currently 900 days uptime). Debian 11 Bullseye is about to be released, I'll reinstall everything from scratch, and update my installation notes. I decided to share my [Debian][debianorg] [^1] installation notes for VM, servers, and workstation full installation. You'll learn how I install, secure, configure, administrate my VMs, public internet servers, workstations and laptops. I don't pretend to have the perfect installation procedure, but I'm pretty sure that you'll learn someting today.

You can find links to the related video recordings and printable materials at the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/" frameborder="0" allowfullscreen></iframe></center>


# Introduction

I use only Debian since 1999 everywhere, on my workstations, laptops, servers. I own my domains and manage the DNS, the mail servers, web servers, file sharing, project management... Despite Debian is said to never need a reinstallation thanks to apt, I prefered to reinstall my machines from time to time. Each time, I learnt something and kept myself uptodate.

I always wrote documentations to be able to reproduce my installations and configurations. I'm now taking and sharing my notes between all my devices with [Joplin][Joplin] [^2] in markdown and serving my blog with [Jekyll][Jekyll] [^3] in markdown... Guess what, you're lucky today, I'll convert my notes to my blog. 

# Covered topics

I summarized the list in the following keywords :
Debian, Buster, Bullseye, upgrade, iptables, cronapt, cron-apt, fail2ban, portsentry, rkhunter, tripwire, logcheck, logwatch, fwlogwatch, backupmanager, backup-manager, monit, openntpd, prometheus, alertmanager, grafana, bind, named, mail transport agent, MTA, mail delivery agent, MDA, msmtpd, dhcp, isc-dhcpd, tftpd, nfs, netboot, router, firewall, apache2, mod_security2, mod_evasive, mod_rewrite, mod_proxy, mod_wstunnel, websockets, authentication, awffull, webalyzer, awstats, vhosts, ssl, http, https, taskwarrior, taskd, joplin, mariadb, mysql, phpmyadmin, yourls, url shortener, privatebin, zerobin, pastebin, mercurial, hg, hgweb, redmine, buildbot, cicd, squid, proxy, e2guardian, dansguardian, parental control, Dovecot, Managesieve, manage-sieve, sieve, Postfix, virtual users, virtual domains, virtual mailboxes, Postfixadmin, amavis, spamassassin, razor, mailzu, rblcheck, mailgraph, queuegraph, postgrey, procmail, roundcube, squirrel, dspam

# Structure of these posts

- The first part is about the OS installation options.
- The second part is about the common base after the OS installation
- The third part is about the customization, server or workstation
- The fourth and last part is about finalization before the last reboot

I'm lazy and wrote my notes to be easily replicable, by cut-and-paste of the code. Thus, you'll be able to easily reproduce, but I **strongly** suggest that you perfectly understand not only each code-block before executing it, but also the reason why I chose to write it this way. Each configuration choice was designed to fit all the other choices, to make the whole system consistent.

# Configuration questions

Whatever you choose to install, a VM or a bare-metal machine, you have to choose at least:
- the hostname
- the unprivileged username
- a static IP address (mandatory for servers, optional for workstations/laptops)

You'll need this information several times. Instead to change the code, I want to cut-and-paste it, I parametrized the code blocks. I ask questions at the begining of the installation and save the answers in environment variables. Given that I need to reboot several times, I save these variables in a file. This file will be sourced by the other steps to avoid asking again and again the same information and avoid mistakes.

You need to `ssh` into your machine and `su -` yourself to `root`. If you don't know what it means, you can still read, bookmark this page and come back later, but please do not try to apply on public servers

``` bash
cat << EOF > /root/config.env
export HN="`hostname`" # Host name
export DN="`domainname -d`" # Domain name
export WAN_IF="`ip addr | grep 'en[po][0-9]\(s[0-9]\)\{0,1\}:.*state UP' | cut -d: -f2 | sed 's/ //' | head -n 1`" # External public network interface
export WAN_IP="`ip addr | grep "inet.*${WAN_IF}" | sed 's/.*inet \([0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\)\/[0-9]\+.*/\1/' | head -n 1`" # External public IP address
export WAN_NM="`ip addr | grep "inet.*${WAN_IF}" | sed 's/.*inet [0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\/\([0-9]\+\).*/\1/' | head -n 1`" # External public netmask
export WAN_GW="`ip route | grep default | sed 's/[^0-9]*\([0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\).*/\1/'`" # External public gateway/router
EOF
vi /root/config.env
```
```sh
source /root/config.env
```

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

