---
uid: Debian112Preparation030Dynamicmotdwithsystemhealth
title: Debian11, Preparation, Dynamic motd with system health
description: Now, it is time to have some blinking lights and fun settings, but useful nevertheless ! A dynamic status message of the day with server health information. I like to have a summary of what is the health of the server, what needs to be done, pending upgrades... immediately when I connect. Furthermore, it is very useful if you need to share a screenshot with someone else.
category: Computers
tags: [ Debian11 Preparation, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Commandline tools, Tools, Banner, Figlet, Toilet, Cowsay, Hostname, System health, Health, CPU, RAM, Stats, Swap, Uptime, Pending upgrades, Upgrades, Motd ]
date: 2021-05-20 00:03:00
---

Now, it is time to have some blinking lights and fun settings, but useful nevertheless ! A dynamic status message of the day with server health information. I like to have a summary of what is the health of the server, what needs to be done, pending upgrades... immediately when I connect. Furthermore, it is very useful if you need to share a screenshot with someone else.

* TOC
{:toc}

# Tooling

I like these useless banners, there are a lot of choices : `figlet`, `toilet`, `cowsay` ... and the old `banner`. I will also need `lsb`-tools to fetch the linux distribution details.
```bash
apt-get install -y figlet toilet lsb-release
```

# Header with hostname and release

First part is to generate a banner with the hostname to avoid any mistake on the server, and to display the current Linux distribution details.

![e107a95e5127814353389c579d0c0e39.png]({{ "/assets/posts/en/Debian112Preparation030Dynamicmotdwithsystemhealth/a49adf07aac643a08ca0805bd3e46afe.png" | relative_url }})

```bash
cat << EOF > /etc/update-motd.d/00-header
#!/bin/sh
[ -r /etc/lsb-release ] && . /etc/lsb-release
if [ -z "\$DISTRIB_DESCRIPTION" ] && [ -x /usr/bin/lsb_release ]; then
    # Fall back to using the very slow lsb_release utility
    DISTRIB_DESCRIPTION=\$(lsb_release -s -d)
fi
figlet -f pagga -w 100 \$(hostname)
printf "\n"
printf "Welcome to %s.\n" "\$DISTRIB_DESCRIPTION"
uname -snrvm
printf "\n"
EOF
chmod +x /etc/update-motd.d/00-header
rm /etc/update-motd.d/10-uname
```

# System health informations

Then, I like to have the date and time, the load average, the memory and swap usage and a summary of the running processes.

![8d4bd5941bd8028a64a69d5c3f01710f.png]({{ "/assets/posts/en/Debian112Preparation030Dynamicmotdwithsystemhealth/2d741400c5f3490a87e8f3c988e3ba33.png" | relative_url }})

```bash
cat << EOF > /etc/update-motd.d/10-sysinfo
#!/bin/sh
date=\`date\`
load=\`cat /proc/loadavg | awk '{print \$1}'\`
root_usage=\`df -h / | awk '/\\// {print \$(NF-1)}'\`
memory_usage=\`free -m | awk '/Mem:/ { total=\$2 } /buffers\\/cache/ { used=\$3 } END { printf("%3.1f%%", used/total*100)}'\`
swap_usage=\`free -m | awk '/Swap/ { printf("%3.1f%%", "exit !\$2;\$3/\$2*100") }'\`
users=\`users | wc -w\`
time=\`uptime | grep -ohe 'up .*' | sed 's/,/\\ hours/g' | awk '{ printf \$2" "\$3 }'\`
processes=\`ps aux | wc -l\`
ip=\`ip addr | grep inet.*enp | sed 's/.*inet //;s/\\/.*//' | head -n1\`
echo "System information as of: \$date"
echo
printf "System load:\t%s\tIP Address #1:\t%s\n" \$load \$ip
printf "Memory usage:\t%s\tSystem uptime:\t%s\n" \$memory_usage "\$time"
printf "Usage on /:\t%s\tSwap usage:\t%s\n" \$root_usage \$swap_usage
printf "Local Users:\t%s\tProcesses:\t%s\n" \$users \$processes
echo
EOF
chmod +x /etc/update-motd.d/10-sysinfo
```

# Available system upgrades

Finally, I generate a list of the packages that need to be upgraded and I empty the default `/etc/motd` static file. Side effect : this part introduce a few seconds latency at each connection. This is mostly due to the apt invocation. 

![628ab45e850f21d64f6aa2b798508d0a.png]({{ "/assets/posts/en/Debian112Preparation030Dynamicmotdwithsystemhealth/e215f2c54fba4655bfd0a35b3971c2dd.png" | relative_url }})

```bash
cat << EOF > /etc/update-motd.d/20-upgrades
#!/bin/sh
number=\`apt list --upgradable 2> /dev/null | grep 'upgradable' | wc -l\`
printf "Available updates : %s\\n" \$number
if [ \$number -gt 0 ]; then
    printf "\\033[1;31mSystem needs %s updates\\033[0m\\n" \$number
    apt list --upgradable 2> /dev/null | grep 'upgradable'
else
    printf "\\033[1;32mSystem is uptodate\\033[0m\\n"
fi
echo
EOF
chmod +x /etc/update-motd.d/20-upgrades
echo > /etc/motd
```

# Materials and Links

[How to setup dynamic motd for Debian Jessie by thesysad][thesysad] [^1]

# Footnotes

[thesysad]: http://www.thesysad.com/blog/how-to-setup-dynamic-motd-for-debian-jessie/ "How to setup dynamic motd for Debian Jessie by thesysad"
[^1]: http://www.thesysad.com/blog/how-to-setup-dynamic-motd-for-debian-jessie/

