---
uid: Debian113Server050TempMTAmsmtp-mta
title: Debian11, Serveur, Relais de messagerie msmtp
description: 
category: Informatique
tags: [ Debian11 Serveur, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, MTA, Mail Transport Agent, mSMTP, Messagerie, Email, Courriels, Pare-feu, IPTables, Smarthost ]
---
Chaque serveur n'est pas un serveur de messagerie. Il n'y a pas besoin d'un agent de transport de messages complet partout. Un
simple relais comme `msmtp` est largement suffisant pour que le serveur puisse envoyer des courriels à un serveur de messagerie. Je
l'utilise en remplacement de `exim` pour fournir des fonctionnalités de messagerie simple, sans distribution locale, sur tous mes
serveurs et stations de travail.

* TOC
{:toc}

# Pré-requis
Ce court article ne dépend que de la série sur la [préparation générique Debian 11](/pages/fr/tags/#preparation-debian11).

## Variables
Il faut définir le nom du serveur de messagerie, appelé *smarthost*, auquel transmettre les messages. Les autres variables sont
déjà définies.

| Variable | Nom | Description | Définie dans |
|---|:---|:---|:---|
| Hostname | HN | Le nom de ce serveur | [Variables de configuration](/Debian111PostInstall010Configurationvariables-fr/) |
| Domainname | DN | Le nom de domaine de ce serveur | [Variables de configuration](/Debian111PostInstall010Configurationvariables-fr/) |
| Smarthost | SMTP_HOST | Le nom complet FQDN[^2] du serveur de messagerie | dessous |

### Creation
```bash
source /root/config.env
cat << EOF >> /root/config.env
export SMTP_HOST="smtp.${DN}" # SMTP server
EOF
vi /root/config.env
```

### Rechargement
Nous devons maintenant recharger les variables dans l'environnement.
```bash
source /root/config.env
```

# Installation
Ce paquetage est très léger, pas de questions, installons-le.
```bash
apt-get install -y msmtp-mta
```

# Configuration
Il a besoin de connaître le FQDN[^2] du *smarthost*, le serveur de messagerie complet officiel, qui sera capable de router les
messages à travers Internet jusqu'à leur destination. Il faut aussi le nom complet FQDN de ce serveur pour pouvoir ré-écrire les
noms des expéditeurs locaux.
```bash
cat << EOF >/etc/msmtprc 
account default
host ${SMTP_HOST}
auto_from on
maildomain ${HN}.${DN}
EOF
```

# Mise-à-jour du pare-feu IPTables
Le traffic réseau sortant est interdit par défaut, il faut donc créer une nouvelle chaine pour définir ce qu'est le traffic
correspondant à des messages sortants (SMTP: TCP/25). On inclue ensuite cette définition dans la chaine qui accepte le traffic
sortant par l'interface publique et on recharge la configuration du pare-feu.
configuration.
```bash
sed -i 's/^-N WAN_input$/-N SMTP\n-A SMTP -p tcp --dport 25 -j ACCEPT\n\n&/' /etc/iptables/rules.v4
sed -i 's/^-N WAN_output$/&\n-A WAN_output -j SMTP/' /etc/iptables/rules.v4
systemctl restart netfilter-persistent
```

# Supports et liens
Cette documentation est partiellement inspirée de [yakati][yakati] [^1].

# Notes de bas de page

[yakati]: https://www.yakati.com/art/envoyer-des-mails-depuis-un-serveur-avec-msmtp.html "Envoyer des mails depuis un server avec mSMTP"
[^1]: https://www.yakati.com/art/envoyer-des-mails-depuis-un-serveur-avec-msmtp.html
[^2]: Fully Qualified Domain Name, Nom de domaine pleinement qualifié
