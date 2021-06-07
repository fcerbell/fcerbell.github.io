---
uid: Debian113Server100Tripwiretodetectpenetration
title: Debian11, Serveur, Tripwire pour détecter les compromissions
description: Tripwire est un de mes outils de sécurité favoris, probablement un des plus efficaces. Comment l'installer et le configurer sur un serveur Linux Debian 11 Bullseye pour détecter une compromission et réagir rapidement. Il prend des empreintes sécurisées des fichiers dans le système et vérifie régulièrement qu'ils n'ont pas été modifiés.
category: Informatique
tags: [ Debian11 Serveur, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, HIDS, IDS, Intégrité, Intrusion, Pénétration, Sécurité, Tripwire ]
---

Tripwire est un de mes outils de sécurité favoris, probablement un des plus efficaces. Comment l'installer et le configurer sur un serveur Linux Debian 11 Bullseye pour détecter une compromission et réagir rapidement. Il prend des empreintes sécurisées des fichiers dans le système et vérifie régulièrement qu'ils n'ont pas été modifiés.

* TOC
{:toc}

# Présentation de Tripwire
Tripwire est un outil extraordinaire pour rechercher les modifications de fichiers dans un système. Il prend
une empreinte des fichiers, des permissions, ... et enregistre cet instantané dans une base de données signée.
Ensuite, il peut scanner le système, détecter chaque modification intervenue sur les fichiers suivis et envoyer
un rapport par courriel. Il protège également sa propre configuration en la signant. Il groupe les fichiers par
sujet et applique des politiques de vérification différentes en fonction de la criticité des fichiers. C'est
véritables un outil à installer sur chaque serveur.

# Installation
Commençon par fournir les réponses aux questions du paquetage afin d'éviter des demandes interactives et
demandons l'installtion de Tripwire.
```bash
echo 'tripwire tripwire/installed string ""' | debconf-set-selections
echo 'tripwire tripwire/rebuild-config boolean true' | debconf-set-selections
echo 'tripwire tripwire/rebuild-policy boolean true' | debconf-set-selections
echo 'tripwire tripwire/use-localkey boolean true' | debconf-set-selections
echo 'tripwire tripwire/use-sitekey boolean true' | debconf-set-selections
apt-get install -y tripwire
```

# Configuration

## Désactivation des faux positifs
Je désactive la supervision de certaines structures de répertoires, incluant le répertoire `/root`, mais je
force quand même quelques exceptions, telles que `/root/bashrc` ou `/root/bash_history`. Je modifie aussi la
politique concernant les fichiers journaux car ils changent d'inode à chaque rotation faite par *logrotate*.
```bash
sed -i 's~/etc/rc.boot~#&~' /etc/tripwire/twpol.txt
sed -i 's~/root/~#&~' /etc/tripwire/twpol.txt
sed -i 's~/proc~#&~' /etc/tripwire/twpol.txt
# Ignore inode change because of logrotate
sed -i 's~/var/log[^;]*~&-i ~' /etc/tripwire/twpol.txt 
sed -i 's~#\(/root/.bashrc.*\)~\1~' /etc/tripwire/twpol.txt
sed -i 's~#\(/root/.bash_history.*\)~\1~' /etc/tripwire/twpol.txt
```

## Notifications
Configuration de la commande d'envoi de courriel à la place d'une connexion SMTP directe, car nous ne disposons
pas d'un serveur de messagerie sur un serveur qui n'est pas supposé recevoir des courriels et les distribuer
localement.
```bash
sed -i 's~^MAILMETHOD.*=.*~MAILMETHOD =SENDMAIL~' /etc/tripwire/twcfg.txt
echo 'MAILPROGRAM=/usr/sbin/sendmail -oi -t' >> /etc/tripwire/twcfg.txt
echo 'GLOBALEMAIL = root' >> /etc/tripwire/twcfg.txt
```

## Compilation et signature de la configuration
Cette étape verrouille la configuration de TripWire en la compilant et en la signant avec la clé de *site*.
Ainsi, seul le propriétaire de cette clé peut modifier et faire appliquer une nouvelle configuration à
TripWire.
```bash
/usr/sbin/twadmin --create-cfgfile -S /etc/tripwire/site.key /etc/tripwire/twcfg.txt
```

## Compilation et signature des politiques
Comme pour la configuration, cette étape fige les politiques en les compilant et en les signant avec la clé de
*site*. Il n'est donc pas possible de changer les politiques appliquées sans connaître cette clé.
```bash
/usr/sbin/twadmin --create-polfile -S /etc/tripwire/site.key /etc/tripwire/twpol.txt
``` 

## Initialisation de la base
Demandons à TripWire de prendre un instantané des empreintes des fichiers à superviser, puis de l'enregistrer
dans sa base de données et de la signer avec la clé *locale*. Cette empreinte note l'état supposé normal des
fichiers et ne peut pas être valablement modifiée sans disposer de la clé *locale*.
```bash
/usr/sbin/tripwire --init
```

# Essais

## Vérification et notification

Demandons à TripWire de vérifier que tous les fichiers supervisés du système n'ont pas été modifiés selon leur
politiques. Nous devrions avoir très peu de changements, voire aucun, car nous venons juste de prendre
l'empreinte. Les résultats seront compilés dans un rapport qui sera écrit sur le disque et envoyé par courriel.
Il s'agit à la fois d'un test de vérification et d'un test de notification.
```bash
/usr/sbin/tripwire --check --email-report
```

![tripwirecheck.gif]({{ "/assets/posts/en/Debian113Server100Tripwiretodetectpenetration/6441ef38a45147cc94b30adc8601a661.gif" | relative_url }})

## Mise à jour de la base avec le dernier rapport
Lorsque je reçois un message d'alerte de TripWire m'informant de changements non autorisés, je peux enquêter et
finallement *valider* le rapport en incorporant les modifications recensées dans la base de donnée. Cette
commande est une de mes commandes d'administration. TripWire demandera la clé *locale* pour mettre a jour la
base de données.
```bash
/usr/sbin/tripwire --update -a -r /var/lib/tripwire/report/`ls -rt /var/lib/tripwire/report/ | tail -n 1`
```

## Mise à jour interactive de la base
Suite à des changements volontaires dans le système, comme une installation ou une modification de
configuration, je sais que TripWire va se plaindre et je n'ai pas envie d'attendre le rapport (ou de le
forcer). Je peux donc immédiatement acquiter les modifications. Cette commande déclenche une vérification et
ouvre le rapport dans un éditeur de texte. Chaque modification trouvée y est listée et elle est marquée d'une
croix pour indiquer qu'il faut la valider. Je peux en rejeter certaines si je le souhaite, avant d'enregistrer
le fichier. TripWire demandera la clé *locale* pour signer la base de données modifiée.
```bash
tripwire --check --interactive --visual vi
```

![TripwireInteractiveUpdate.gif]({{ "/assets/posts/en/Debian113Server100Tripwiretodetectpenetration/589e99b15a494425b99d423ec9ab9974.gif" | relative_url }})

# Supports et liens

[zonewebmaster][zonewebmaster] [^1]

[howtoforge][howtoforge] [^2]

# Notes de base de page

[zonewebmaster]: https://www1.zonewebmaster.eu/serveur-debian-securite:utilisation-tripwire
[howtoforge]: https://www.howtoforge.com/tutorial/how-to-monitor-and-detect-modified-files-using-tripwire-on-ubuntu-1604/#step-configure-tripwire-policy-for-ubuntu-system

[^1]: https://www1.zonewebmaster.eu/serveur-debian-securite:utilisation-tripwire
[^2]: https://www.howtoforge.com/tutorial/how-to-monitor-and-detect-modified-files-using-tripwire-on-ubuntu-1604/#step-configure-tripwire-policy-for-ubuntu-system
