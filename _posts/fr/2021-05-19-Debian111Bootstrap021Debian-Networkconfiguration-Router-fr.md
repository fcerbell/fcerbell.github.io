---
uid: Debian111Bootstrap021Debian-Networkconfiguration-Router
title: Debian11, Bootstrap, Configuration réseau routeur
description: Configuration d'une seconde interface réseau, ce qui est utile si cette série d'articles est déroulée dans le but de construire un router entre deux réseaus, de distribuer un accès internet à la maison ou au travail, de protéger votre réseau privé contre internet ou de créer un proxy transparent avec contrôle parental pour vos ados adorés.
category: Informatique
tags: [ GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Configuration réseau, Réseau, Routeur, Passerelle, Contrôle parental, Parental, Partage d'internet, Internet ]
---

Je décris comment configurer une seconde interface réseau, ce qui est bien pratique si ce tutorial sert à construire un routeur
entre deux réseaux, à distribuer un accès internet à la maison ou au travail, à protéger un réseau privé contre internet ou à
créer un proxy transparent avec contrôle parental pour vos ados adorés.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports imprimables associés à la
[fin de cet article](#supports-et-liens).

* TOC
{:toc}

# Pré-requis

## Étapes précedentes

Le fichier de configuration du réseau a déjà dû être initialisé lors de l'article [Debian11 Bootstrap Configuration réseau](/Debian111Bootstrap020Debian-Networkconfiguration-fr/).

## Création de nouvelles variables

Cet article nécessite de disposer d'informations à propos de la configuration de la seconde interface. Cette dernière sera
considérée comme sécurisée et exposera les services internes, s'il y en a, tels que proxy, DNS, ou serveur de temps NTP.

```bash
cat << EOF >> /root/config.env
export LAN_IF="`ip addr | grep 'en[po][0-9]\(s[0-9]\)\{0,1\}:.*state' | cut -d: -f2 | sed 's/ //' | head -n 2 | tail -n 1`" # Internal private network interface
export LAN_IP="`ip addr | grep "inet.*${LAN_IF}" | sed 's/.*inet \([0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\)\/[0-9]\+.*/\1/' | head -n 1`" # Internal private network IP address
export LAN_NM="`ip addr | grep "inet.*${LAN_IF}" | sed 's/.*inet [0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\/\([0-9]\+\).*/\1/' | head -n 1`" # Internal private network netmask
export LAN_GW="${LAN_IP}" # Internal private network gateway/router
EOF
```

## Ajustement des valeurs par défaut

Les variables sont initialisées avec des valeurs par défaut. Vous devez les lire, les vérifier, les corriger, les ajuster avec
votre éditeur de texte préféré. C'est bien `vi`, non ?
```bash
vi /root/config.env
```

# Chargement des variables dans l'environnement

```bash
source /root/config.env
```

## Affectation de l'adresse IP statique

```bash
cat >> /etc/network/interfaces << EOF
# LAN
auto ${LAN_IF}
iface ${LAN_IF} inet static
    address ${LAN_IP}
EOF
```

# Test de la nouvelle configuration réseau

```bash
reboot
```

