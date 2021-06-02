---
uid: Debian113Server030TCPIPtuning
title: Debian11, Serveur, Optimisations TCP/IP
description: Comment activer des protections basiques contre certains attaques, directement dans le noyau Linux, comme les attaques par spoofing, flooding, smurfing, Man-in-the-Middle (MITM) ou ICMP.
category: Informatique
tags: [ Debian11 Serveur, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, TCP, IP, ICMP, Pile réseau, Réseau,  Optimisations, Paramètres du noyau, Noyau, Sécurité, Spoofing, Flooding, Smurfing, MITM, Man In The Middle, Crackeur, Paquets ]
date: 2021-05-22 00:02:00
---
Comment activer des protections basiques contre certains attaques, directement dans le noyau Linux, comme les attaques par spoofing, flooding, smurfing, Man-in-the-Middle (MITM) ou ICMP.

* TOC
{:toc}

# Spoofing, Flooding, Smurfing, MITM et ICMP

Le spoofing est une usurpation d'identité par forge de paquets. Le flooding consiste à consommer et épuiser certains types de
resources sur votre serveur, comme le nombre de connexion possible. Le Smurfing consiste à envoyer des paquets réseaux forgés à un
grand nombre d'ordinateurs, avec comme adresse de réponse celle de la cible. Tous les serveurs vont répondre à la victime qui n'a
rien demandé. C'est une sorte de flooding distribué grâce au spoofing. L'attaque MITM vise à s'intercaller dans une connexion
entre deux machines pour pouvoir analyser et éventuellement modifier le contenu des échanges. Enfin, il est aussi possible de
reçevoir des paquets ICMP forgés.

Toutes ces protections n'ont pas vraiment d'effet secondaire indésirable. La page de [montuy337513]'s [^1], en Français, en décrit
certaines.

```bash
cat > /etc/sysctl.d/00-FCSecurity << EOF
# Spoofing
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1
# Syn Flood
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_max_syn_backlog = 1024
# Smurfing
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
# Man In The Middle
# FC ICMP redirect rejection
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
# FC No ICMP redirect request
net.ipv4.conf.all.send_redirects = 0
net.ipv6.conf.all.send_redirects = 0
# FC No ICMP routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
EOF
```

# Chargement dans le noyau
```bash
sysctl -n -e -q -p /etc/sysctl.conf
```

[montuy337513]: https://www1.zonewebmaster.eu/serveur-debian-securite:securiser-tcp-ip "Sécurisation de TCP/IP sur votre serveur dédié"
[^1]: https://www1.zonewebmaster.eu/serveur-debian-securite:securiser-tcp-ip 
