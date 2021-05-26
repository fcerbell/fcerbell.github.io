---
uid: Debian113Server060CronApt
title: Debian11, Serveur, CronApt pour garder le système à jour
description: Installation et configuration de cron-apt pour un serveur Debian 11 bullseye. Il met automatiquement la liste des paquetages disponibles à jour, télécharge les mises à jour disponibles pour les paquetages installés, envoie une notification à l'admin et peut aussi automatiquement effectuer les mises à jour du système.
category: Informatique
tags: [ Debian11 Serveur, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Cron-apt, Update, Upgrade, Mises à jour, Téléchargements, Unattended upgrades, Notification ]
---

Installation et configuration de `cron-apt` pour un serveur Debian 11 bullseye. Il met automatiquement la liste des paquetages disponibles à jour, télécharge les mises à jour disponibles pour les paquetages installés, envoie une notification à l'admin et peut aussi automatiquement effectuer les mises à jour du système.

* TOC
{:toc}

# cron-apt ou unattended-upgrades
Dans les systèmes basés sur Debian, il existe deux candidats : `cron-apt` et `unattended-upgrades`. Le premier est le plus ancien,
le second est le plus récent mais a déjà plus de 10 ans.

Les deux sont fiables. Les deux peuvent mettre la liste des paquetages à jour, télécharger les paquetages, envoyer des
notifications et installer les mises à jour. Les différences, s'il y en a encore, se trouvent plus dans la dernière étape.
`unattended-upgrades` essaye de deviner si une mise à jour de paquetage déclenchera une question interractive, si oui, il ne
l'installera pas, si non, il le fera.

Pour faire court, `cron-apt` pourrait être plus orienté *serveur* et `unattended-upgrades` *stations de travail*. Dans tous les
cas, je ne suis intéressé que par les fonctionnalités de mise à jour des listes, de téléchargement, et de notification, pas par
l'installation automatique. Je souhaite vérifier manuellement les mises à jour. Les deux sont de bon choix et j'ai choisi
d'utiliser `cron-apt` partout.

# Pré-requis

Cet article ne dépend que de la [préparation d'une machine générique](/pages/fr/tags/#préparation-debian11).

# Installation
L'installation ne pose aucune question ni aucune difficulté.
```bash
apt-get install -y cron-apt
```

# Activation des notifications
Par défaut, `cron-apt` n'effectue que les étapes de mise à jour des listes et de téléchargement des paquetages, rien d'autre.
J'active le plugin de notification pour envoyer des courriels lorsque des mises à jour de paquetages installés sont disponibles.
Il est possible d'activer les mises à jour automatiques des paquetages, mais cela pourrait éventuellement casser le système s'il y
avait un bug dans le paquetage. C'est mieux d'être notifié, de lire les notes de révision et, enfin, d'appliquer les mises à jour
manuellement.
```bash
cp /usr/share/doc/cron-apt/examples/9-notify /etc/cron-apt/action.d/
```

# Configuration des notifications

![dc6275a2e8dd52ae207751ae81b1b1a1.png]({{ "/assets/posts/en/Debian113Server060CronApt/d9b9274ec02e4c428abdc39edd4bc1c9.png" | relative_url }})

`cron-apt` peut envoyer des notifications par courriels, par lui-même. Il écrit qussi beaucoup d'informations sur sa sortie
standard, qui sont capturées par `cron`, enregistrées dans des fichiers journaux et envoyées à l'administrateur. Enfin, je vais
installer des analyseurs de journaux qui pourront capturer ces informations aussi et envoyer un résumé.

Toutes ces options peuvent être optimisées pour atteindre différents objectfs, comme prévenir différentes personnes, ou groupes, à
travers différents canaux de communication. Dans mon cas, les analyseurs vont éliminer les information « normales », et celles de
`cron-apt` le sont. Je conserve les notification de `cron` et je configure `cron-apt` pour en envoyer uniquement s'il y a des
mises à jour à appliquer.

Ainsi, en temps normaux, je peux recevoir un message de `cron` uniquement, si quelquechose s'est produit et je serais notifié par
`cron` et `cron-apt` si une mise à jour est disponible.

```bash
cat << EOF > /etc/cron-apt/config
# Configuration for cron-apt. For further information
# about the possible configuration settings see
# /usr/share/doc/cron-apt/README.gz.

OPTIONS="-o quiet=2"
MAILON="output"
SYSLOGON="output"
MAILTO="root"
MINTMPDIRSIZE=10
NOLOCKWARN=""
EOF
```

# Test
Faisons un petit test. Il devrait être complètement vide et n'envoyer aucune notification, nous venons juste d'installer la
machine et elle est supposée être à jour.
```bash
/usr/sbin/cron-apt
```

# Supports et liens

J'ai trouvé ce lien intéressant, en Français, sur [zonewebmaster][zonewebmaster] [^1].

# Notes de bas de page

[zonewebmaster]: https://www1.zonewebmaster.eu/serveur-debian-securite:install-cron-apt "Sécurité d'un serveur Debian : Cron-Apt"
[^1]: https://www1.zonewebmaster.eu/serveur-debian-securite:install-cron-apt
