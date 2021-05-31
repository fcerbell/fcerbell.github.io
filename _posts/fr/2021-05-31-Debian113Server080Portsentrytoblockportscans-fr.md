---
uid: Debian113Server080Portsentrytoblockportscans
title: Debian11, Serveur, Portsentry pour bloquer les scans de port
description: Installation et configuration de Portsentry comme seconde ligne de défense contre les scans de port, après les règles lscan et psd d'IPTables. Il bloquera temporairement ou définitivement les machines des attaquants mais ignorera mon propre réseau ou mes adresses IP.
category: Informatique
tags: [ Debian11 Serveur, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Portsentry, Fail2ban, Sécurité, IPTables, TCPWrappers ]
---

Installation et configuration de Portsentry comme seconde ligne de défense contre les scans de port, après les règles lscan et psd d'IPTables. Il bloquera temporairement ou définitivement les machines des attaquants mais ignorera mon propre réseau ou mes adresses IP.

* TOC
{:toc}

# Présentation de Portsentry

Portsentry écoute sur la plupart des ports réseaux inutilisés. Il reçoit toutes les connexions entrantes et peut donc détecter les
séquences de connexion depuis une source pour en déduire les tentatives de scan. Ensuite, il peut réagir à l'aide de commandes
arbitraires, pour bloquer les scans, pour renvoyer des données aléatoires, pour déclencher des contre-mesures. La plupart des
scans seront détectés et bloqués par la chaine IPTables, Portsentry est configuré en seconde ligne de défense. Il utilise
TCPWrappers et IPTables pour bloquer les scans UDP et TCP. Je vais également lui faire ignorer mes propres adresses IP, supposées
sûres.


# Pré-requis
Cet article ne dépend que de la série d'articles sur la [Préparation d'une machine générique](/pages/fr/tags/#préparation-debian11).

## Variables existantes
Nous avons besoin des variables `LAN_*` qui ont déjà été configurées dans le fichier de configuration par l'article [Variables de
configuration](/Debian111PostInstall010Configurationvariables-fr/).

## Chargement des variables
Assurons-nous que les variables soient disponibles dans l'environnement :
```bash
source /root/config.env
```

# Installation commune
Je commence par préconfigurer la réponse à une question qui me serait posée par le paquetage, autrement, et je l'installe :
```bash
echo portsentry portsentry/warn_no_block string "" | debconf-set-selections
apt-get install -y portsentry
```

## Configuration de l'écoute avancée
Écoute automatique sur tous les ports inutilisés. Configuration de `portsentry` pour utiliser le mode *avancé*, qui écoute sur
tous les ports en-dessous d'un seuil, à la fois en UDP et en TCP. Cela pourait être un problème si un service tentait de se mettre
lui-aussi à l'écoute sur un port déjà utilisé par portsentry. Par défaut, la valeur du seuil est *1024*.
```bash
sed -i 's/TCP_MODE="tcp"/TCP_MODE="atcp"/' /etc/default/portsentry
sed -i 's/UDP_MODE="udp"/UDP_MODE="audp"/' /etc/default/portsentry
```

## Blocage avec IPTables, CHAOS et TCPWrappers

Activons le blocage grâce à IPTables et TCPWrappers. Portsentry exécutera la commande `iptables` fournie et ajoutera la machine de
l'attaquant dans le fichier `/etc/hosts.deny`. Les deux sont utiles car IPTables n'est pas persistent alors que TCPWrappers l'est.
De plus, je personnalise la commande `iptables` afin d'utiliser la cible *CHAOS* à la place de *DROP*. L'attaquant sait qu'il y a
une machine, ignorer ses paquets l'informe que nous protégeons la machine et il tentera autrechose. L'utilisation de *CHAOS*
renvoie des données aléatoires, nous ne semblerons pas protéger la machine, et nous ne fournirons pas d'informations utiles.

**Il serait probablement mieux** d'insérer la règle de blocage **après** la règle de liste blanche et **avant** les règles
*ACCEPT*. Je devrais connaître le numéro de la règle de liste blanche pour cela, j'aurais donc besoin de créer une chaine
`iptables` de liste blanche dans la [Configuration d'IPTables](/Debian113Server045IPTables-fr/), mais je ne l'ai pas fait. Libre à vous de le faire.
```bash
sed -i 's/BLOCK_UDP="0"/BLOCK_UDP="1"/' /etc/portsentry/portsentry.conf
sed -i 's/BLOCK_TCP="0"/BLOCK_TCP="1"/' /etc/portsentry/portsentry.conf
sed -i 's/RESOLVE_HOST = "0"/RESOLVE_HOST = "1"/' /etc/portsentry/portsentry.conf
sed -i 's/^KILL_ROUTE/#&/' /etc/portsentry/portsentry.conf
sed -i 's/^#\?KILL_ROUTE="\/sbin\/iptables -I INPUT -s $TARGET$ -j DROP"/KILL_ROUTE="\/sbin\/iptables -I INPUT -s $TARGET$ -j CHAOS"/' /etc/portsentry/portsentry.conf
```

## Ignorer les adresses IP sûres
Je peux faire des erreurs, je pourrais vouloir scanner mon propre serveur... Mais je ne veux pas me bloquer moi-même. J'ajoute
donc mon adresse IP dans la liste à ignorer et, au cas où, je l'ajoute aussi dans la liste blanche de TCPWrappers.
```bash
echo "ALL: ${LAN_IP}/${LAN_NM}" >> /etc/hosts.allow
echo "${LAN_IP}/${LAN_NM}" >> /etc/portsentry/portsentry.ignore.static
```

## Application de la configuration
```bash
systemctl restart portsentry
```

# Durcissement avec fail2ban
[Fail2ban](/Debian113Server070fail2bantobanobviousattacksources-fr/) peut utiliser les journaux de `portsentry` pour effectuer des actions. Lorsque `portsentry` bloque une tentative de scan,
il le bloque avec `iptables` pour TCP et UDP, mais ce n'est pas persisté dans le cas d'un redémarrage de service. Il utilise
*TCPWrappers* qui est persisté. `fail2ban` peut doubler le blocage avec `iptables`, mais surtout, il dispose d'une base de données
persistée et restaurera les règles de blocage and cas de redémarrage.
```bash
> /var/lib/portsentry/portsentry.history
cat << EOF > /etc/fail2ban/jail.d/portsentry.conf
[portsentry]
enabled = true
EOF
systemctl restart fail2ban
```

# Supports and links

# Footnotes
