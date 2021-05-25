---
uid: Debian113Server046IPTables-Public
title: Debian11, Serveur, Configuration d'IPTables - Public
description: Après une installation et configuration générique d'IPTables, j'applique quelques règles spécifiques à un serveur public, pour inscrire mes adresses IP en liste blanche. En temps normal, je ne devrais jamais me retrouver bloqué, mais je peux commetre des erreurs, oublis, inattentions, ... et me bannir moi-même !
category: Informatique
tags: [ Debian11 Serveur, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, IPTables, Sécurité, Filtrage, Réseau, Pare-feu, Règles, Chaînes, Pirate, SSH, TCP, IP, ICMP, Loopback, IPv6, Serveur public, Internet ]
---
Après une installation et configuration générique d'IPTables, j'applique quelques règles spécifiques à un serveur public, pour inscrire mes adresses IP en liste blanche. En temps normal, je ne devrais jamais me retrouver bloqué, mais je peux commetre des erreurs, oublis, inattentions, ... et me bannir moi-même !

* TOC
{:toc}

# Pré-requis

## Étapes précédentes

La configuration générique d'[IPTables](/Debian113Server045IPTables-fr/) doit être appliquée.

## Création de nouvelles variables

Nous avons besoin de définir les variables pour lister l'adresse et le masque de sous-réseau à accepter inconditionnellement. Il
peut s'agir d'une IP unique, avec un masque /32, d'un sous-réseau ou d'une classe.
```bash
cat << EOF >> /root/config.env
export MY_IP="aaa.bbb.ccc.ddd" # Whitelisted IP
export MY_NM="32" # Whitelisted Netmask
EOF
```

## Ajustement des nouvelles variables

```bash
vi /root/config.env
```

## Rechargement des variables

Il faut recharger les variables modifiées dans l'environnement d'autant plus que nous venons de redémarrer dans l'article
précédent.
```bash
source /root/config.env
```

# Ajout en liste blanche

J'ajoute directement dans la chaine de filtrage du traffic externe entrant une règle pour accepter mon adresse personnelle.
```bash
sed -i 's/^-N WAN_input/&\n# Home IP\n-A WAN_input -s '${MY_IP}'\/'${MY_NM}' -j ACCEPT/' /etc/iptables/rules.v4
```

# Application

La connexion SSH en cours a été acceptée et ouverte depuis que j'ai appliqué la configuration générique d'IPTables en redémarrant, elle est
connue du système et je peux désormais simplement recharger les nouvelles règles.
```bash
systemctl restart netfilter-persistent
```

