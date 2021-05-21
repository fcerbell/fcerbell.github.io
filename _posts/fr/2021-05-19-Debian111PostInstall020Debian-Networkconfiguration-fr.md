---
uid: Debian111PostInstall020Debian-Networkconfiguration
title: Debian11, PostInstallation, Configuration réseau
description: Voici comment j'affecte une adresse IP statique et un nom de machine différent à une installation Debian 10 Buster minimale. J'inclue aussi la suppression du swap, l'espace d'échange, lorsque le serveur dispose de suffisament de mémoire.
category: Informatique
tags: [ GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Configuration réseau, Réseau, Swap, Fichier d'échange, Échange ]
---

Voici comment affecter une adresse IP statique et changer le nom de machine (hostname) d'une installation Debian 10 Buster
minimale. Nous allons également voir comment désactiver le swap (espace d'échange), lorsque le serveur n'en a pas besoin et a
suffisament de mémoire pour ses tâches.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports imprimables associés à la
[fin de cet article](#supports-et-liens).

* TOC
{:toc}

#Pré-requis

## Charger les variables dans l'environnement

Cet article nécessite que les variables WAN_IF, WAN_IP, WAN_GW, HN et DN soient chargées dans l'environnement. Elles ont été
initialisées dans l'article [Debian11 PostInstall Variables de configuration](/Debian111PostInstall010Configurationvariables-fr/) et vous devez juste vous assurer qu'elles soient bien chargées :
```bash
source /root/config.env
```

# Preparation

À ce jour, Debian 11 Bullseye est toujours en « testing ». Bien qu'elle entre prochainement dans l'état *Hard freeze*, le dernier
avant la sortie officielle, elle n'est pas disponible partout. Je vais donc partir du principe que nous démarrons à partir d'une
Debian 10 Buster, disponible *partout* (AWS, Azure, GCP, Scaleway/Dedibox, ISO, ...) et que nous la mettons à jour en Debian 11
Bulseye minimale.

Ainsi, je suppose que l'on dispose déjà d'une installation Debian 10 Buster minimale déployée sur la machine.

## Affectation d'une IP statique

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

## Changement de nom de machine

``` bash
sed -i 's/root@[-0-9a-zA-Z_.]\+$/root@'${HN}'/g' \
/etc/ssh/ssh_host_ed25519_key.pub \
/etc/ssh/ssh_host_dsa_key.pub \
/etc/ssh/ssh_host_ecdsa_key.pub \
/etc/ssh/ssh_host_rsa_key.pub
sed -i "s/^127.0.1.1.*/127.0.1.1 ${HN}.${DN} ${HN}/" /etc/hosts 
echo "${HN}" > /etc/hostname
```

## Désactivation du swap

``` bash
sed -i 's/UUID.*swap/#&/' /etc/fstab 
swapoff -a
```

# Test de la nouvelle configuration réseau

``` bash
reboot
```

