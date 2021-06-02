---
uid: Debian112Preparation010Sudoinstallationandconfiguration
title: Debian11, Préparation, Installation et configuration de Sudo
description: Comment éviter et interdire les connexions directes sur le compte root en bloquant le mot de passe et obliger les utilisateurs spécifiés à obtenir l'accès grâce à `sudo`. La première étape est d'installer sudo et d'en autoriser l'usage à l'utilisateur nommé. Étant donné que toutes les connexions se feront obligatoirement à travers le réseau par SSH, sans mot de passe, avec une authentification par clé privée, le compte utilisateur n'aura pas de mot de passe non plus et devra dont avoir un acces sans mot de passe au compte root.
category: Informatique
tags: [ Préparation Debian11, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Sudo, Sécurité, Mot de passe, Password ]
date: 2021-05-20 00:01:00
---

Comment éviter et interdire les connexions directes sur le compte root en bloquant le mot de passe et obliger les utilisateurs spécifiés à obtenir l'accès grâce à `sudo`. La première étape est d'installer sudo et d'en autoriser l'usage à l'utilisateur nommé. Étant donné que toutes les connexions se feront obligatoirement à travers le réseau par SSH, sans mot de passe, avec une authentification par clé privée, le compte utilisateur n'aura pas de mot de passe non plus et devra dont avoir un acces sans mot de passe au compte root.

* TOC
{:toc}

# Pré-requis

## Création des nouvelles variables

Nous avons besoin d'un nom d'utilisateur nommé qui sera autorisé à obtenir l'accès root. Nous avons besoin de son username (UN) et
de son mot de passe (UP). Ajoutons les dans le fichier de configuration :
```bash
cat << EOF >> /root/config.env
export UN="`grep 1000 /etc/passwd | cut -d: -f1`" # Named user name
export UP="`grep 1000 /etc/passwd | cut -d: -f1`" # Named user password
EOF
```

## Ajustement des valeurs par défaut

Les variables sont initialisées avec des valeurs par défaut. Il faut les lire, les vérifier, les corriger, les ajuster à l'aide de
votre éditeur de texte préféré, `vi` bien sûr.
```
vi /root/config.env
```

## Chargement des variables dans l'environnement

```bash
source /root/config.env
```

# Installation

Installons `sudo`.
```bash
apt-get install -y sudo
```

# Configuration de l'utilisateur nommé

Il faut permettre à l'utilisateur nommé d'exécuter n'importe quelle commande, à condition de se réauthentifier avec son mot de
passe personnel. À ce stade, l'utilisateur dispoe encore d'un compte protégé par mot de passe. La connexion avec authentification
par mot de passe sera désactivée après la configuration de SSH, dans un prochain article.

![sudo.gif]({{ "/assets/posts/en/Debian112Preparation010Sudoinstallationandconfiguration/0cbff73d73be46b1bfd356df50b216dc.gif" | relative_url }})

```bash
adduser ${UN} sudo
```

En préparation de la désactivation de l'authentification par mot de passe, nous permettons à l'utilisateur d'exécuter n'importe
quelle commande sans confirmation de son identité.
```bash
echo "${UN} ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UN}
```

