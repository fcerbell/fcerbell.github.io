---
uid: Debian113Server100Tripwiretodetectpenetration
title: Debian11, Server, Tripwire to detect penetration
description: Tripwire is one of my favorite security tool, probably one of the most efficient. How to install and configure tripwire on a Linux Debian 11 Bullseye server to detect a penetration and react quickly. It takes securized footprints of files in the filesystem and periodically check that they did not change.
category: Computers
tags: [ Debian11 Server, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, HIDS, IDS, Integrity, Intrusion, Penetration, Security, Tripwire ]
---

Tripwire is one of my favorite security tool, probably one of the most efficient. How to install and configure tripwire on a Linux Debian 11 Bullseye server to detect a penetration and react quickly. It takes securized footprints of files in the filesystem and periodically check that they did not change.

* TOC
{:toc}

# Tripwire presentation
Tripwire is an amazing tool to check the system files against modifications. It takes a snapshot of the files, the permissions, ... and store this snapshot in a signed database. Then, it can scan the system, detect every single change occured to the monitored files and send an email report. It also protect his own configuration files, by signing them. It groups files by topic and apply check policies, depending on the file criticity. It is a real must on every server.

# Tripwire installation
First, provide answers to the package questions to avoid interactive prompts and start the actual installation.
```bash
echo 'tripwire tripwire/installed string ""' | debconf-set-selections
echo 'tripwire tripwire/rebuild-config boolean true' | debconf-set-selections
echo 'tripwire tripwire/rebuild-policy boolean true' | debconf-set-selections
echo 'tripwire tripwire/use-localkey boolean true' | debconf-set-selections
echo 'tripwire tripwire/use-sitekey boolean true' | debconf-set-selections
apt-get install -y tripwire
```

# Configuration

## Disable false positive checks
I disable monitoring on some folder structures, including the `/root/` folder, but I force the check of some exceptions such as `/root/bashrc` and `/root/bash_history`. I also change the policy for the log files, because they can have an inode change when LogRotate rotates them.
```bash
sed -i 's~/etc/rc.boot~#&~' /etc/tripwire/twpol.txt
sed -i 's~/root/~#&~' /etc/tripwire/twpol.txt
sed -i 's~/proc~#&~' /etc/tripwire/twpol.txt
# Ignore inode change because of logrotate
sed -i 's~/var/log[^;]*~&-i ~' /etc/tripwire/twpol.txt 
sed -i 's~#\(/root/.bashrc.*\)~\1~' /etc/tripwire/twpol.txt
sed -i 's~#\(/root/.bash_history.*\)~\1~' /etc/tripwire/twpol.txt
```

## Notifications
Use a mail command instead of a direct SMTP connection (there is currently no real MTA on the server)
```bash
sed -i 's~^MAILMETHOD.*=.*~MAILMETHOD =SENDMAIL~' /etc/tripwire/twcfg.txt
echo 'MAILPROGRAM=/usr/sbin/sendmail -oi -t' >> /etc/tripwire/twcfg.txt
echo 'GLOBALEMAIL = root' >> /etc/tripwire/twcfg.txt
```

## Compile and sign the configuration file
This step freezes the TripWire configuration file by compiling it and signing it with the *site-key*.
```bash
/usr/sbin/twadmin --create-cfgfile -S /etc/tripwire/site.key /etc/tripwire/twcfg.txt
```

## Compile and sign the policies file
This step protects the policy definition file by compiling it and signing it with the *site-key*.
```bash
/usr/sbin/twadmin --create-polfile -S /etc/tripwire/site.key /etc/tripwire/twpol.txt
``` 

## Initialize the database
Let's ask TripWire to take a snapshot of the current system files status, write it in a database and sign the snapshot with the *local-key*.
```bash
/usr/sbin/tripwire --init
```

# Test runs

## Check and notify

This asks TripWire to check that all the current system files were not changed against the defined policies. We should have very little (to no) change, as we just built the database. The results will be compiled in a report that will be written to the disk and sent by email. This is not only a check test, but also an email alert test.
```bash
/usr/sbin/tripwire --check --email-report
```

![tripwirecheck.gif]({{ "/assets/posts/en/Debian113Server100Tripwiretodetectpenetration/6441ef38a45147cc94b30adc8601a661.gif" | relative_url }})

## Update and sign the database according to the last check/report
Once I receive an email alert from Tripwire informing me that there were unauthorized changes, I can investigate and finally *validate* the report and update the database according to the detected changes. This is also an administration command. Tripwire will ask for the *local-key* to update the database.
```bash
/usr/sbin/tripwire --update -a -r /var/lib/tripwire/report/`ls -rt /var/lib/tripwire/report/ | tail -n 1`
```

## Interactive update and sign

When I make some system changes, such as an installation, a change in a configuration file, ... I already know that Tripwire will complain and I don't want to wait for the email report, thus I can acknowledge the changes immediately. This command triggers a check and opens the report in the text editor. In the report, every change is flagged as *normal* with `[x]`. I can reject some of them, and save/exit. Tripwire will ask for the *local-key* to update the database.
```bash
tripwire --check --interactive --visual vi
```

![TripwireInteractiveUpdate.gif]({{ "/assets/posts/en/Debian113Server100Tripwiretodetectpenetration/589e99b15a494425b99d423ec9ab9974.gif" | relative_url }})

# Materials and links

[zonewebmaster][zonewebmaster] [^1]

[howtoforge][howtoforge] [^2]

# Footnotes

[zonewebmaster]: https://www1.zonewebmaster.eu/serveur-debian-securite:utilisation-tripwire
[howtoforge]: https://www.howtoforge.com/tutorial/how-to-monitor-and-detect-modified-files-using-tripwire-on-ubuntu-1604/#step-configure-tripwire-policy-for-ubuntu-system

[^1]: https://www1.zonewebmaster.eu/serveur-debian-securite:utilisation-tripwire
[^2]: https://www.howtoforge.com/tutorial/how-to-monitor-and-detect-modified-files-using-tripwire-on-ubuntu-1604/#step-configure-tripwire-policy-for-ubuntu-system
