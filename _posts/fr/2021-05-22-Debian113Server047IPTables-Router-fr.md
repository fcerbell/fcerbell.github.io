---
uid: Debian113Server047IPTables-Router
title: Debian11, Serveur, Configuration d'IPTables - Routeur
description: Configurer IPTables pour un serveur à plusieurs interfaces externes, une sur un réseau public, une sur un réseau privé. Cela peut permettre de donner accès a certains services basiques, tels que la messagerie, l'heure et SSH, depuis le réseau privé, sans filtrage ni blocage. Les autres protocoles pourront être gérés plus tard avec un proxy mandataire ou un système de contrôle parental.
category: Informatique
tags: [ Debian11 Serveur, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, IPTables, Sécurité, Filtrage, Réseau privé, Réseau, Pare-feu, Règles, Chaînes, Pirate, SSH, TCP, IP, ICMP, Loopback, IPv6, Routeur, Passerelle, Messagerie, Email, NTP, Temps, Heure, SSH, Proxy, Mandataire, Contrôle parental, Parental, SNAT, MASQUERADE ]
---
Configurer IPTables pour un serveur à plusieurs interfaces externes, une sur un réseau public, une sur un réseau privé. Cela peut permettre de donner accès a certains services basiques, tels que la messagerie, l'heure et SSH, depuis le réseau privé, sans filtrage ni blocage. Les autres protocoles pourront être gérés plus tard avec un proxy mandataire ou un système de contrôle parental.

* TOC
{:toc}

# Pré-requis

## Étapes précédentes

La [configuration réseau Routeur](/Debian111PostInstall021Debian-Networkconfiguration-Router-fr/) doit avoir été appliquée, ainsi que la [configuration générique de IPTables](/Debian113Server045IPTables-fr/).

## Variables existantes

Nous avons besoin des variables de définition du réseau privé, elles ont déjà été définies.

## Rechargement des variables

Il faut recharger les variables modifiées dans l'environnement d'autant plus que nous venons de redémarrer dans l'article
```bash
source /root/config.env
```

# Ajout de chaines pour le LAN

Pour plus de facilité d'administration, je crée une chaine d'entrée et une chaine de sortie spécifique pour l'interface du réseau
privé. On peut y lister les types de paquets a accepter et elles seront appelées depuis les chaînes d'entrée et de sortie
globales.
```bash
sed -i 's/^-A INPUT -i '${WAN_IF}'.*$/&\n-A INPUT -i '${LAN_IF}' -j LAN_input/' /etc/iptables/rules.v4
sed -i 's/^-A OUTPUT -o '${WAN_IF}'.*$/&\n-A OUTPUT -o '${LAN_IF}' -j LAN_output/' /etc/iptables/rules.v4
sed -i 's/^-N WAN_input$/-N LAN_input\n\n-N LAN_output\n\n&/' /etc/iptables/rules.v4
```

# Acceptation du traffic venant du LAN

Tout d'abord, j'ajoute la chaîne des connexions SSH pour accepter les connexions SSH entrantes sur le serveur depuis le LAN, mais
je n'appelle pas le limiteur. Je pars du principe que le LAN est sûr, on pourrait durcir ces règles, mais je n'en éprouve pas le
besoin. Le jour où mes enfants tenteront de brute-forcer le proxy, plutôt que de les bloquer, il sera grand temps de leur
enseigner la sécurité informatique. ;)
```bash
sed -i 's/^-N LAN_input$/&\n-A LAN_input -j SSH/' /etc/iptables/rules.v4
```

# Transmission depuis le LAN vers le WAN

Ensuite, j'active la transmission entre les interfaces du serveur, dans le noyau et j'ajoute quelques règles de transmission pour
accepter certaines connexions traversantes : envoi et réception de courriels (SMTP, POP, IMAP), synchronisation d'horloges, SSH.
```bash
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/00-IPv4Forwarding.conf
sysctl --system
sed -i 's/^-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT$/&\n-A FORWARD -i '${LAN_IF}' -p tcp -m multiport --dports 25,465,587 -j ACCEPT/' /etc/iptables/rules.v4
sed -i 's/^-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT$/&\n-A FORWARD -i '${LAN_IF}' -p tcp -m multiport --dports 143,993 -j ACCEPT/' /etc/iptables/rules.v4
sed -i 's/^-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT$/&\n-A FORWARD -i '${LAN_IF}' -p tcp -m multiport --dports 110,995 -j ACCEPT/' /etc/iptables/rules.v4
sed -i 's/^-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT$/&\n-A FORWARD -i '${LAN_IF}' -p tcp --dport 123 -j ACCEPT/' /etc/iptables/rules.v4
sed -i 's/^-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT$/&\n-A FORWARD -i '${LAN_IF}' -p udp --dport 123 -j ACCEPT/' /etc/iptables/rules.v4
sed -i 's/^-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT$/&\n-A FORWARD -i '${LAN_IF}' -p tcp --dport 22 -j ACCEPT/' /etc/iptables/rules.v4
```

# Traduction d'adresse pour les adresses non routables

Le réseau interne privé peut envoyer des paquets à l'extérieur, avec une adresse d'expéditeur interne, aucune chance de reçevoir
une éventuelle réponse. Activons la traduction d'adresse, Source Network Address Translation, SNAT, avec la cible MASQUERADE, pour
tous les paquets envoyés depuis une adresse privée vers une adresse publique à travers l'interface publique.
```bash
sed -i 's/^:POSTROUTING.*$/&\n-A POSTROUTING -s '${LAN_IP}'\/'${LAN_NM}' ! -d '${LAN_IP}'\/'${LAN_NM}' -o '${WAN_IF}' -j MASQUERADE/' /etc/iptables/rules.v4
systemctl restart netfilter-persistent
```
