---
uid: Debian113Server070fail2bantobanobviousattacksources
title: Debian11, Server, fail2ban to ban obvious attack sources
description: Fail2ban parses log files, looking for attack attempts and take countermeasures to ban the attacker temporarily or permanently using IPTables and TCPWrapper rules. Configuration with TARPIT IPtables targets to "punish" attackers. This post describe the basic and common installation setup, I specialize it depending on the server type (public or gateway/router) in the next posts.
category: Computers
tags: [ Debian 11 Server, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Fail2ban, TARPIT, Ban, Security, IPTables, TCPWrappers ]
---

Fail2ban parses log files, looking for attack attempts and take countermeasures to ban the attacker temporarily or permanently using IPTables and TCPWrapper rules. Configuration with TARPIT IPtables targets to "punish" attackers. This post describe the basic and common installation setup, I specialize it depending on the server type (public or gateway/router) in the next posts.

# Fail2ban presentation

Fail2Ban parses the log files and searches for typical attack patterns, when the same source IP has several authentication failure, or tries to scan the server, ... The attack was successfully blocked by the first line of defense, IPTables rules or TCPWrappers, but continues. It is probably not a mistake, but a real attack and it is time to implement more than just blocking each attempt. 

Fail2ban can execute arbitrary commands to block the source IP for a given amount of time, it can also send email with details to the admin, add the source IP to public blacklists or trigger active countermeasures. 

Automatic countermeasures is not a good idea, email notification can rapidly fil your mailbox without any great value, and adding bad ips to public blacklists would need to open outgoing network connections and I personnally do not find automatic blacklist addition as a reliable action.

* TOC
{:toc}

# Prerequisites
This article only depends on the [Generic machine preparation](/pages/en/tags/#debian11-preparation).

# Installation
The package is small, easy and fast to install, it asks no questions by default.
```bash
apt-get install -y fail2ban
```

# Second level ban of already banned connections
When a pattern is repeated, Fail2Ban triggers a temporary action to block further attempts for a specified time. This rule acts as a second level to take more restrictive actions when the attempts are continuing while blocked.
```bash
cat << EOF > /etc/fail2ban/jail.d/recidive.conf
[recidive]
enabled = true
EOF
```

# TARPIT malicious connections
Instead of simply ignoring the incoming network paquets to block them, I chose to send them to the TARPIT target. I described this target in the [IPTable post](), we already know that this trafic is malicious, it does not hurt or consume local resources and it should stop the attack attempts directly at the source.
```bash
cat << EOF > /etc/fail2ban/action.d/iptables-common.local
[Init]
blocktype = TARPIT
EOF
```

# Restart to apply
```bash
systemctl restart fail2ban
```

# Administration
Keep in mind that this tool will dynamically block connections. You can use `fail2ban-client` to manage the currently banned hosts with the `banned`, `ban` and `unban` commands. These commands are available with the version included in Debian 11 Bullseye, but not in the version included in Debian 10 Buster. When a host is banned, it will be added to an `iptable` chain, visible in `iptable -L -n -v` output and in the TCPWrapper's `/etc/hosts.deny` blacklist file.

# Materials and links

I found some extra information on these pages, in English and in French.
- [booleanworld][booleanworld][^1] (en)
- [whyscream][whyscream][^2] (en)
- [nicolargo][nicolargo1][^3] (fr)
- [nicolargo][nicolargo2][^4] (fr)

# Footnotes

[booleanworld]: https://www.booleanworld.com/protecting-ssh-fail2ban/ "Protecting SSH with Fail2Ban"
[whyscream]: http://whyscream.net/wiki/Fail2ban_monitoring_Fail2ban.md "Monitoring with Fail2ban"
[nicolargo1]: https://blog.nicolargo.com/2012/02/proteger-son-serveur-en-utilisant-fail2ban.html "Protéger son serveur avec Fail2ban"
[nicolargo2]: https://blog.nicolargo.com/2012/03/bannir-les-bannis-avec-fail2ban.html "Bannir les bannis avec Fail2ban"

[^1]: https://www.booleanworld.com/protecting-ssh-fail2ban/
[^2]: http://whyscream.net/wiki/Fail2ban_monitoring_Fail2ban.md
[^3]: https://blog.nicolargo.com/2012/02/proteger-son-serveur-en-utilisant-fail2ban.html
[^4]: https://blog.nicolargo.com/2012/03/bannir-les-bannis-avec-fail2ban.html
