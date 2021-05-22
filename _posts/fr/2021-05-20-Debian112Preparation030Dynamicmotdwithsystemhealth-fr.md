---
uid: Debian112Preparation030Dynamicmotdwithsystemhealth
title: Debian11, Préparation, Message d'accueil dynamique avec la santé du système
description: Il est maintenant temps d'ajouter des paillettes, mais utiles ! Un message de bienvenue dynamique avec l'état de santé du serveur.  J'aime avoir un résumé de la santé du server lorsque je m'y connecte, ce qui doit être fait, les mise à jour disponibles... De plus, c'est très pratique si on doit faire une capture d'écran pour se vanter de son uptime. Tout se fait dans le fichier `motd` qui peut être généré dynamiquement.
category: Informatique
tags: [ Préparation Debian11, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Outil, Ligne de commande, Commande, Bannière, Figlet, Toilet, Cowsay, Hostname, Santé système, Système, CPU, RAM, Stats, Swap, Uptime, Mises à jour, Pending upgrades, Upgrades, Motd ]
---

Il est maintenant temps d'ajouter des paillettes, mais utiles ! Un message de bienvenue dynamique avec l'état de santé du serveur.  J'aime avoir un résumé de la santé du server lorsque je m'y connecte, ce qui doit être fait, les mise à jour disponibles... De plus, c'est très pratique si on doit faire une capture d'écran pour se vanter de son uptime. Tout se fait dans le fichier `motd` qui peut être généré dynamiquement.

* TOC
{:toc}

# Outillage

J'aime ces bannières inutiles, il y a beaucoup de choix : `figlet`, `toilet`, `cowsay`, ... et le bon vieux `banner`. Je vais aussi
avoir besoin des outils `lsb-*` pour récupérer les informations sur la distribution. Bien que je puisse m'en passer à l'aide du
fichier `/etc/os-release`.
```bash
apt-get install -y figlet toilet lsb-release
```

# Un en-tête avec le nom d'hôte et la version

La première partie génère une bannière avec le nom d'hôte pour éviter toute erreur de serveur et affiche également les détails de
la distribution.

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

# État de santé du système

Ensuite, j'aime connaître la date, l'heure, la charge du système (uptime), l'utilisation de la mémoire et du swap (fichier
d'échange) et un résumé des processus en coure.

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

# Mises à jour disponibles

Enfin, je génère une liste des paquetages pour lesquels une mise à jour est disponible et je vide le fichier statique
`/etc/motd`. Il y a un effet secondaire : cette partie introduit quelques secondes de latence à la connexion, à cause de
l'invocation de `apt`.

![628ab45e850f21d64f6aa2b798508d0a.png]({{ "/assets/posts/en/Debian112Preparation030Dynamicmotdwithsystemhealth/e215f2c54fba4655bfd0a35b3971c2dd.png" | relative_url }})

```bash
cat << EOF > /etc/update-motd.d/20-upgrades
#!/bin/sh
list=\`apt list --upgradable 2> /dev/null | grep 'upgradable'\`
number=`echo -n $list | wc -l`
printf "Available updates : %s\\n" \$number
if [ \$number -gt 0 ]; then
    printf "\\033[1;31mSystem needs %s updates\\033[0m\\n" \$number
	echo $list
else
    printf "\\033[1;32mSystem is uptodate\\033[0m\\n"
fi
echo
EOF
chmod +x /etc/update-motd.d/20-upgrades
echo > /etc/motd
```

# Supports et liens

[How to setup dynamic motd for Debian Jessie by thesysad][thesysad] [^1]

# Notes de bas de page

[thesysad]: http://www.thesysad.com/blog/how-to-setup-dynamic-motd-for-debian-jessie/ "How to setup dynamic motd for Debian Jessie by thesysad"
[^1]: http://www.thesysad.com/blog/how-to-setup-dynamic-motd-for-debian-jessie/

