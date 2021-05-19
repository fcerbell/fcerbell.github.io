---
uid: Debian111Bootstrap010Configurationvariables
title: Debian11 Bootstrap Variables de configuration
description: Toutes les étapes d'installation et de configuration auront besoin d'informations encore et encore. La première fois que des informations sont nécessaires, je les enregistre dans un fichier de configuration et je le charge dans l'environnement courant. Ainsi, je n'ai pas besoin de les saisir une fois de plus et je ne risque pas d'incohérence.
category: Informatique
tags: [ Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Variables de configuration, Configuration ]
---

Toutes les étapes d'installation et de configuration auront besoin des mêmes informations encore et encore. La toute première fois
qu'une information est nécessaire, je la stocke dans un fichier de configuration et je le charge dans l'environnement courant.
Ansi, je n'ai pas besoin de la resaisir et je n'ai pas de risque d'incohérence. Vous aurez besoin de ces informations plusieurs
fois. Au lieu de changer le code, je souhaite uniquement faire des copier-coller, je le variabilise. Je pose les questions au
début d'une étape et sauvegarde les réponses dans des variables d'environnement. Comme je suis ammené à redémarrer plusieurs fois,
je sauvegarde ces variables dans un fichier. Ce fichier sera chargé par les autres étapes par la suite, pour éviter de reposer les
mêmes questions et de risquer des erreurs.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports imprimables associés à la
[fin de cet article](#supports-et-liens).

* TOC
{:toc}

# Variables de configuration

Quelque soit la machine à installer, une VM ou un serveur physique, vous aurez besoin au minimum :
- du nom de machine, le hostname
- d'un compte utilisateur
- d'une adresse IP statique (obligatoire pour les serveurs, facultative pour les stations de travail)

L'utilisateur est le même, que l'étape concernée ait besoin d'un compte système ou d'un compte applicatif. En fait, pour faire
simple, ce compte utilisateur, c'est vous.

## Creer les variables

Je commence par ajouter les variables avec des valeurs par défaut. Je découpe cette phase en deux car la seconde phase a besoin
que les variables déclarées dans la première soient chargées dans l'environnement.
```bash
cat << EOF > /root/config.env
export HN="`hostname`" # Host name
export DN="`domainname -d`" # Domain name
export WAN_IF="`ip addr | grep 'en[po][0-9]\(s[0-9]\)\{0,1\}:.*state UP' | cut -d: -f2 | sed 's/ //' | head -n 1`" # External public network interface
EOF
source /root/config.env
cat << EOF > /root/config.env
export WAN_IP="`ip addr | grep "inet.*${WAN_IF}" | sed 's/.*inet \([0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\)\/[0-9]\+.*/\1/' | head -n 1`" # External public IP address
export WAN_NM="`ip addr | grep "inet.*${WAN_IF}" | sed 's/.*inet [0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\/\([0-9]\+\).*/\1/' | head -n 1`" # External public netmask
export WAN_GW="`ip route | grep default | sed 's/[^0-9]*\([0-9]\+.[0-9]\+.[0-9]\+.[0-9]\+\).*/\1/'`" # External public gateway/router
EOF
```

## Ajustement des valeurs

Les variables sont initialisées avec des valeurs par défaut. Vous devez les lire, les vérifier, les corriger, les ajuster avec
votre éditeur de texte préféré. `vi`, n'est-ce pas ?
```bash
vi /root/config.env
```

![2021-05-19_10-53.png]({{ "/assets/posts/en/Debian111Bootstrap010Configurationvariables/f94e4b1f592240cd9d9755da4286a778.png" | relative_url }})


## Chargement des variables dans l'environnement

```bash
source /root/config.env
```


