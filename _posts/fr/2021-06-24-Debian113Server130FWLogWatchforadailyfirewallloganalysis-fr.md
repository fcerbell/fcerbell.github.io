---
uid: Debian113Server130FWLogWatchforadailyfirewallloganalysis
title: Debian11, Serveur, FWLogWatch analyse quotidienne des logs du pare-feu
description: Installation et configuration de *FWLogWatch* pour analyser les journaux du pare-feu *IPTables* et les rapporter par courriel, groupés dans un résumé agrégé de quelques lignes. Cela aide grandement pour identifier très rapidement les attaques potentielles et maintenir les règles de filtrage.
category: Informatique
tags: [ Debian11 Serveur, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, FWLogWatch, Analyse de logs, Logs, Journaux, Sécurité, Firewall, Pare-feu ]
date: 2021-06-24 11:59:39 +02:00
---

Installation et configuration de *FWLogWatch* pour analyser les journaux du pare-feu *IPTables* et les rapporter par courriel, groupés dans un résumé agrégé de quelques lignes. Cela aide grandement pour identifier très rapidement les attaques potentielles et maintenir les règles de filtrage.

* TOC
{:toc}

# Présentation de FWLogWatch

![64ac9bbbf41a4f6cfa07cf4ae9c027e0.png]({{ "/assets/posts/en/Debian113Server130FWLogWatchforadailyfirewallloganalysis/259766c721e146a3915b27508df948df.png" | relative_url }})

*[FWLogWatch][homepage]* [^1] est un analyseur de journaux, très similaire à *LogWatch*, spécialisé sur les lignes d'*IPTables*. Il ne conserve que les entrées relatives à
*IPTables*, les groupe par origine, destination, port, règle, ..., compte les occurences, et les trie. À la fin, il envoie un courriel de résumé avec le palmarès des lignes
les plus fréquentes de la liste.

C'est très utile pour immédiatement lister les adresses IP ou domaines douteux afin de les bloquer ou pour détecter des tendances d'attaques distribuées. Ensuite, il est
simple de décider de bloquer ces attaques spécifiquement.

# Pré-requis
Cet article ne dépend que de la série sur la [préparation d'une machine générique](/pages/fr/tags/#préparation-debian11).

# Installation
Cet outil prend la plupart de sa configuration en paramètres de l'invocation en ligne de commande. Le script de démarrage utilise les options définies dans
`/etc/default/fwlogwatch` et ce fichier est automagiquement généré par *DebConf* et *dpkg* lors de l'installation, à partir de question interactives. La première étape est
donc de pré-répondre à ces questions pour éviter qu'elles ne soient posées lors de l'installation.

## Pré-configuration
En deux mots, je force la configuration suivante :
- Résolution des noms de service (-N), pour avoir le nom humain du port, c'est plus facile à lire
- Au moins 20 occurence similaires (-m) pour qu'une ligne soit inclue dans le rapport, éviter les notifications de simple paquets et pour conserver le rapport concentré sur
  les choses importantes
- Afficher le temps écoulé entre la première et la dernière occurence de l'attaque et avoir une idée de sa stratégie
- Envoi du courriel à *root*
```bash
echo fwlogwatch fwlogwatch/realtime boolean true | debconf-set-selections
echo fwlogwatch fwlogwatch/cron_email string "root" | debconf-set-selections
echo fwlogwatch fwlogwatch/cron_parameters string "-N -m 20 -z" | debconf-set-selections
```

## Installation
Ensuite, l'installation est simple, toutes les questions de pré-configuration ont été répondues et *DebConf* va appliquer les réponses automatiquement.
```bash
apt-get install -y fwlogwatch
```

## Correctif de bogue
J'ai trouvé un bogue [#987315][BTS] [^1] et l'ai soumis dans le BTS (Bug Tracking System) de *Debian*. En attendant le correctif officiel, j'ai préparé le mien rapidement,
ci-dessous. Ce bogue est supposé avoir été corrigé dans la version 1.4-3 du paquetage. En cas de problème lors de l'utilisation de la commande `systemctl`, voici mon
correctif :
```bash
sed -i 's/htpdate/fwlogwatch/' /lib/systemd/system/fwlogwatch.service
```

# Test avec notification
Bien qu'il ne devrait pas y avoir beaucoup d'avertissements, l'installation peut être testée rapidement, à la fois pour l'analyse et pour les notifications, avec la commande
suivante :
```bash
/etc/cron.daily/fwlogwatch
```

# Supports et liens

- [Bug #987315][BTS] [^1]

# Notes de bas de page

[BTS]: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=987315
[homepage]: http://fwlogwatch.inside-security.de/

[^1]: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=987315
[^2]: http://fwlogwatch.inside-security.de/
