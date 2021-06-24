---
uid: Debian113Server120LogWatchforadailyaggregatedloganalysis
title: Debian11, Serveur, LogWatch pour une analyse quotidienne des logs
description: Alors que *LogCheck* est un outil bas-niveau d'extraction de lignes des journaux, *LogWatch* est un outil d'analyse quotidien de plus haut-niveau avec une agrégation renvoyant des statistiques comportementales et détectant des tendances, scans lents ou attaques lentes. Le courriel est plus court et consolidé. Je décris une configuration tres courte et basique dans cet article. C'est un des outils installés par défaut sur mes serveurs.
category: Informatique
tags: [ Debian11 Serveur, Debian GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveiur, Installation, Logwatch, Analyse agregée de logs, Résumé des Logs, Sécurité ]
---
Alors que *LogCheck* est un outil bas-niveau d'extraction de lignes des journaux, *LogWatch* est un outil d'analyse quotidien de plus haut-niveau avec une agrégation renvoyant des statistiques comportementales et détectant des tendances, scans lents ou attaques lentes. Le courriel est plus court et consolidé. Je décris une configuration tres courte et basique dans cet article. C'est un des outils installés par défaut sur mes serveurs.

* TOC
{:toc}

# Présentation de LogWatch

![ba17b78e47a8747e7559fd2ba367c6f3.png]({{ "/assets/posts/en/Debian113Server120LogWatchforadailyaggregatedloganalysis/f0495b89c2574697b62d4935f9fa6931.png" | relative_url }})

[LogWatch][homepage] [^1] n'envoie qu'un seul courriel de résumé par jour. C'est probablement le premier courriel à ouvrir le matin. Il est court, rapide à lire et donne une
indication si quelquechose d'inhabituel s'est produit dans les 24 dernières heures. En cas de doutes ou s'il y a d'autres courriels d'alerte, il est possible d'enquêter un
peu plus avec les courriels de *TripWire*, *FWLogCheck*, *RKHunter* ou *LogCheck*.

*LogWatch* est très facile à configurer et je ne change aucune configuration par défaut, je n'ai donc pas besoin d'installer de fichier de configuration.

# Pré-requis
Cet article ne dépend que de la série d'articles sur la [préparation d'une machine générique](/pages/fr/tags/#préparation-debian11).

# Installation
Installon le depuis les dépôts officiels Debian Linux Debian 11 Bullseye :
```bash
apt-get install -y logwatch
```

# Configuration par défaut
Comme indiqué précédemment, je n'ai pas besoin de modifier les valeurs par défaut de la configuration, je n'installe donc pas de fichier de configuration. Dans tous les cas
si je souhaite changer quelquechose, j'installerai le fichier à partir du modèle pour le modifier.
```bash
#cp /usr/share/logwatch/default.conf/logwatch.conf /etc/logwatch/conf/
```

# Test
Test de l'analyse des journaux et de l'envoi d'une notification par courriel. Il peut être exécuté plusieurs fois, il est idempotent, il ne conserve pas l'état de sa dernière
exécution et ré-analyse les dernière vingt-quatre heures.
```bash
/usr/sbin/logwatch --output mail
```

# Supports et liens

- [Homepage][homepage] [^1]

# Notes de bas de page

[homepage]: https://sourceforge.net/projects/logwatch/
[^1]: https://sourceforge.net/projects/logwatch/
