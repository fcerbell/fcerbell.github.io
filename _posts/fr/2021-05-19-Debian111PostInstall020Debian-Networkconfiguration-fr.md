---
uid: Debian111PostInstall020Debian-Networkconfiguration
title: Debian11, PostInstallation, Configuration réseau
description: Comment affecter une adresse IP statique et un nom d'hôte différent à une installation minimale Debian 10 Buster, comment désactiver le swap (espace d'échange), et comment configurer une seconde interface réseau pour un routeur ou une passerelle entre deux réseaux, pour partager un accès internet à la maison ou au bureau, pour protéger un réseau interne privé ou pour mettre un contrôle parental transparent et protéger nos ados chéris.
category: Informatique
tags: [ Debian11 Postinstallation, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Configuration réseau, Réseau, Swap, Routeur, Passerelle, Contrôle parental, Parental, Partage d'Internet, Internet ]
---

Comment affecter une adresse IP statique et un nom d'hôte différent à une installation minimale Debian 10 Buster, comment désactiver le swap (espace d'échange), et comment configurer une seconde interface réseau pour un routeur ou une passerelle entre deux réseaux, pour partager un accès internet à la maison ou au bureau, pour protéger un réseau interne privé ou pour mettre un contrôle parental transparent et protéger nos ados chéris.

* TOC
{:toc}

# Pré-requis

À ce jour, Debian 11 Bullseye est toujours en phase de test. Bien qu'elle va prochainement entrer en *Hard freeze*, la dernière
étape avant la sortie, elle n'est pas disponible partout. Ainsi, je suppose que l'on part d'une installation minimale Debian 10
Buster, disponible *partout*, quant à elle (AWS, Azure, GCP, Dedibox/Scaleway, ISO, ...) et on va la mettre à jour vers une Debian
11 Bullseye minimale.

Je suppose donc que l'on dispose d'une installation minimale Debian 10 Buster déjà déployée sur le serveur.

## Création de nouvelles variables

Cet article a besoin d'informations sur les adresses IP fiables, celles qui ne doivent jamais être bloquées. Il peut s'agir des
adresses IP du LAN interne, s'il y en a un, ou de l'adresse IP publique personnelle utilisée depuis la maison pour administrer le
serveur public.
Si on configure une passerelle ou un routeur avec deux interfaces réseau, il faut aussi définir les variables pour le nom de
l'interface (LAN_IF) et pour la passerelle à utiliser (LAN_GW). Cette seconde interface sera considérée comme sécurisée et le
serveur pourra y exposer les services internes, s'il y en a, tels que le proxy-mandataire, un serveur DNS ou un serteur d'horloge
NTP.

```bash
cat << EOF >> /root/config.env
export LAN_IF="`ip addr | grep 'en[po][0-9]\(s[0-9]\)\{0,1\}:.*state' | cut -d: -f2 | sed 's/ //' | head -n 2 | tail -n 1`" # Internal private network interface
export LAN_IP="`ip addr | grep "inet.*${LAN_IF}" | sed 's/.*inet \([0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\)\/[0-9]\+.*/\1/' | head -n 1`" # Internal private network IP address
export LAN_NM="`ip addr | grep "inet.*${LAN_IF}" | sed 's/.*inet [0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\/\([0-9]\+\).*/\1/' | head -n 1`" # Internal private network netmask
export LAN_GW="${LAN_IP}" # Internal private network gateway/router
EOF
```

## Ajustement des valeurs par défaut

Les variables sont initialisées avec des valeurs par défaut. Il faut les lire, les vérifier, les corriger, les ajuster à l'aide du
meilleur éditeur du monde : vi !
```bash
vi /root/config.env
```

## Chargement des variables dans l'environnement

Cet article nécessite aussi les variables WAN_IF, WAN_IP, WAN_GW, HN et DN. Elles ont été initialisées dans l'[article sur les
variables d'environnement](/Debian111PostInstall010Configurationvariables-fr/) et il faut s'assurer qu'elles soient aussi chargées :
```bash
source /root/config.env
```

# Affectation de l'adresse IP statique du WAN
D'abord, je configure l'interface sur le réseau public externe avec une adresse IP statique.
```bash
cat > /etc/network/interfaces << EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# Local Loopback
auto lo
iface lo inet loopback

# WAN
auto ${WAN_IF}
iface ${WAN_IF} inet static
    address ${WAN_IP}
    gateway ${WAN_GW}

EOF
```

# Affectation d'une adresse IP statique pour le LAN
Si le serveur est un routeur ou une passerelle, je configure également la seconde interface réseau avec une adresse IP statique et
une passerelle. Ce n'est pas du tout nécessaire pour un serveur public ne disposant que d'une seule interface réseau.
```bash
cat >> /etc/network/interfaces << EOF
# LAN
auto ${LAN_IF}
iface ${LAN_IF} inet static
    address ${LAN_IP}
EOF
```

# Mise à jour du nom de machine
``` bash
sed -i 's/root@[-0-9a-zA-Z_.]\+$/root@'${HN}'/g' \
/etc/ssh/ssh_host_ed25519_key.pub \
/etc/ssh/ssh_host_dsa_key.pub \
/etc/ssh/ssh_host_ecdsa_key.pub \
/etc/ssh/ssh_host_rsa_key.pub
sed -i "s/^127.0.1.1.*/127.0.1.1 ${HN}.${DN} ${HN}/" /etc/hosts 
echo "${HN}" > /etc/hostname
```

# Désactivation du swap
``` bash
sed -i 's/UUID.*swap/#&/' /etc/fstab 
swapoff -a
```

# Test de la nouvelle configuration
Vu les modifications, je préfère redémarrer le serveur pour tester la prise en compte de la configuration.
``` bash
reboot
```

