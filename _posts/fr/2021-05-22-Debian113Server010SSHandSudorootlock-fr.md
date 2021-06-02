---
uid: Debian113Server010SSHandSudorootlock
title: Debian11, Serveur, Verrouilage de SSH et Sudo
description: Je n'ai jamais besoin de me connecter à mes serveurs depuis la console et je n'ai pas besoin de reconfirmer l'identité de l'utilisateur avec un mot de passe pour utiliser la commande sudo. Du coup, je n'ai besoin d'aucune authentification par mot de passe. Il n'est possible de se connecter au serveur qu'à l'aide de ssh avec des clés, je peux donc complètement bloquer les mots de passe pour root et les utilisateurs nommés.  
category: Informatique
tags: [ Debian11 Serveur, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Configuration, Sudo, SSH, Verrouillage, Root, Compte, Sécurité, Clé secrete SSH ]
date: 2021-05-22 00:01:00
---
Je n'ai jamais besoin de me connecter à mes serveurs depuis la console et je n'ai pas besoin de reconfirmer l'identité de l'utilisateur avec un mot de passe pour utiliser la commande sudo. Du coup, je n'ai besoin d'aucune authentification par mot de passe. Il n'est possible de se connecter au serveur qu'à l'aide de ssh avec des clés, je peux donc complètement bloquer les mots de passe pour root et les utilisateurs nommés.  
* TOC
{:toc}

# Pré-requis

## Étapes précédentes

- [Installation et configuration SSH](/Debian112Preparation020SSHinstallationandconfiguration-fr/)
- [Installation et configuration de Sudo](/Debian112Preparation010Sudoinstallationandconfiguration-fr/)

## Variables existantes

Nous aurons besoin uniquement du nom de l'utilisateur nommé (UN), qui a déjà été définie.

## Rechargement des variables dans l'environnement

Il faut charger la variable `UN` définie dans le fichier de configuration décrit dans l'article [Installation et configuration de Sudo](/Debian112Preparation010Sudoinstallationandconfiguration-fr/). Assurons-nous que les variables soient bien chargées dans l'environnement courant :
```bash
source /root/config.env
```

# Verrouillage du compte root

Verrouillons les connexions directes au compte root depuis la console et depuis la commande `su`. Cela empêchera également
l'utilisation des paramètres de démarrage `single` et `recovery` depuis la console ou un KVM. C'est optionel et potentiellement
dangereux en cas de problème grave. La seule possibilité sera d'utiliser la console ou un KVM et d'ajouter un paramètre tel que
`init=/bin/sh`, il faudra alors une bonne maîtrise du système.
```bash
passwd -l root
```
**Attention, cela bloque les connexions depuis la console pour root, incluant les démarrages spéciaux tels que "single boot" ou
"boot failure recovery (problèmes sur les systèmes de fichiers)".**

# Verrouillage du mot de passe utilisateur

Désormais, on peut ouvrir des connexions SSH sans mot de passe au compte utilisateur nommé et au compte root, on peut donc
désactiver le mot de passe de l'utilisateur et mettre les attaques par force brute en échec.
```bash
[ ! -z "${UN}" ] && passwd -l ${UN}
```
**Pour les serveurs uniquement, ne surtout pas faire cela sur une station de travail, il deviendrait impossible de s'y connecter !**

# Alerte par courriel
J'ai trouvé cette astuce sur [tutoriels-video][tutovideo] [^1], en Français, et j'ai aimé. Elle envoie un courriel d'alerte lorsque quelqu'un se connecte au serveur.
```bash
cat << EOF >> /etc/bash.bashrc
echo \`who\` \`date\` | mail -s "shell connection on \`hostname\`" root
EOF
```

[tutovideo]: https://www.tutoriels-video.fr/securiser-son-serveur-dedie-avec-iptables-fail2ban-et-rkhunter/
[^1]: https://www.tutoriels-video.fr/securiser-son-serveur-dedie-avec-iptables-fail2ban-et-rkhunter/
