---
uid: Debian113Server070fail2bantobanobviousattacksources
title: Debian11, Serveur, Installation de fail2ban pour bloquer les attaquants
description: Fail2ban parcoure les fichiers de journaux à la recherche de tentatives d'attaques et réagit pour bannir les attaquants temporairement ou définitivement en utilisant IPTables et TCPWrappers. Cette configuration utilise la cible TARPIT d'IPTables pour « punir » les attaquants. Cet article décrit l'installation d'une configuration de base, commune à tout type de serveur, je la spécialiserai en fonction du serveur souhaité (public ou routeur/passerelle) dans les articles suivants.
category: Informatique
tags: [ Debian 11 Serveur, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Fail2ban, TARPIT, Bannissement, Sécurité, IPTables, TCPWrappers ]
---
Fail2ban parcourt les fichiers de journaux à la recherche de tentatives d'attaques et réagit pour bannir les attaquants temporairement ou définitivement en utilisant IPTables et TCPWrappers. Cette configuration utilise la cible TARPIT d'IPTables pour « punir » les attaquants. Cet article décrit l'installation d'une configuration de base, commune à tout type de serveur, je la spécialiserai en fonction du serveur souhaité (public ou routeur/passerelle) dans les articles suivants.

# Présentation de Fail2ban

Fail2ban parcourt les fichiers de journalisation à la recherche de motifs d'attaque typiques, lorsque la même adresse IP source
est la cause de plusieurs tentatives de connexion infructueuse ou tente de scanner les ports du server, ... L'attaque a été
déjouée par la première ligne de défense, les règles IPTables ou TCPWrappers, mais continue. Ce n'est probablement pas une erreur
mais une véritable attaque et il est temps de bloquer plus que les tentatives individuelles.

Fail2ban peut exécuter des commandes arbitraires pour bloquer l'adresse IP source pour une certaine période, il peut aussi envoyer
des courriels avec les détails à l'administrateur, ajouter l'IP à des liste noire publiques, ou déclencher des contre-mesures
actives.

Les contremesures actives ne sont pas une bonne idée, les notifications par courriel peuvent rapidement remplir une boite aux
lettres sans valeur ajoutée, et l'ajout d'IP dans des listes noires nécessiteraient d'ouvrir des connexions réseau sortantes sur
le pare-feu. Personnellement, je ne pense pas que les ajouts automatiques dans les blacklist soient une action fiable. Il faut
garder en tête que ce ne sont que rarement les machines des attaquants qui exécutent les attaques, mais celles d'un réseau de
machines inocentes infectées par un virus. Toutes ces actions punieraient d'innocentes victimes de manière bien trop sévères à mon
sens.

* TOC
{:toc}

# Pré-requis
Cet article ne dépend que de la [Préparation d'une machine générique](/pages/fr/tags/#préparation-debian11).

## Variables existantes
Nous avons besoin des variables `LAN_*` déjà définies dans le fichier de configuration par l'article sur les [Variables de configuration](/Debian111PostInstall010Configurationvariables-fr/).

## Rechargement des variables
Assurons-nous que les variables soient bien chargées dans l'environnement.
```bash
source /root/config.env
```

# Installation commune
Le paquetage est très petit, facile et rapide à installer, il ne pose aucune question par défaut.
```bash
apt-get install -y fail2ban
```

## Bannir les bannis récidivistes
Lorsqu'un motif d'attaque se répète, Fail2ban déclenche une action temporaire pour bloquer les tentatives suivantes pendant un
temps défini. Cette règle ajoute un second niveau pour appliquer une règle encore plus restrictive si les bannis continuent à
tenter des attaques.
```bash
cat << EOF > /etc/fail2ban/jail.d/recidive.conf
[recidive]
enabled = true
EOF
```

## Utilisation de la cible IPTables TARPIT
Au lieu de simplement ignorer les paquets réseau pour les bloquer, avec la cible DROP, j'utilise la cible TARPIT. J'ai déjà
expliqué cette cible IPTable dans l'[article sur IPTables](/Debian113Server045IPTables-fr/), on sait déjà que le traffic est
malicieux, cela ne fait pas de mal, ne consomme pas plus de ressources locales et devrait arrêter les tentatives d'attaque
directement à la source.
```bash
cat << EOF > /etc/fail2ban/action.d/iptables-common.local
[Init]
blocktype = TARPIT
EOF
```

## Ajout d'une IP ou d'un LAN en liste blanche
L'utilisation normale ne devrait pas poser de problème, mais il reste prudent d'ajouter en liste blanche ma propre adresse IP pour éviter d'être banni en cas de fausse manipulation. Je commence
donc par ajouter mon adresse IP publique (ou classe) en liste blanche.
```bash
cat << EOF > /etc/fail2ban/jail.local
[DEFAULT]
ignoreip = 127.0.0.1/8 ${LAN_IP}/${LAN_NM}
#action = %(action_mw)s
EOF
```

## Ajutement de la durée de banissement
J'ajuste ensuite la durée de banissement temporaire à une heure, bien plus longtemps que la durée par défaut.
```bash
cat << EOF >> /etc/fail2ban/jail.local
bantime = 3600
EOF
```

## Ajustement des seuils de détection
Enfin, j'indique à `fail2ban` de déclencher une contre-mesure lorsqu'il trouve plus de 3 tentatives pendant les 10 dernières minutes, afin de détecter les attaques lentes.
```bash
cat << EOF >> /etc/fail2ban/jail.local
findtime = 600
maxretry = 3
EOF
```

## Application de la configuration
```bash
systemctl restart fail2ban
```

# Administration
Il faut garder en tête que cet outil bloque dynamiquement les connexions. On peut utiliser `fail2ban-client` pour gérer les hôtes
actuellement bannis grâce aux commandes `banned`, `ban` et `unban`. Ces commandes sont disponibles dans la version inclue dans
Debian 11 Bullseye, mais pas dans la version inclue dans Debian 10 Buster. Lorsqu'une machine est bannie, elle est ajoutée à des
chaines `iptables` que l'on peut consulter avec la commande `iptables -L -n -v` ainsi que dans le fichier blacklist de TCPWrapper
`/etc/hosts.deny`.

# Supports et liens

J'ai trouvé ces quelques resources intéressantes, en anglais et en Français.
- [booleanworld][booleanworld][^1] (en)
- [whyscream][whyscream][^2] (en)
- [nicolargo][nicolargo1][^3] (fr)
- [nicolargo][nicolargo2][^4] (fr)

# Notes de bas de page

[booleanworld]: https://www.booleanworld.com/protecting-ssh-fail2ban/ "Protecting SSH with Fail2Ban"
[whyscream]: http://whyscream.net/wiki/Fail2ban_monitoring_Fail2ban.md "Monitoring with Fail2ban"
[nicolargo1]: https://blog.nicolargo.com/2012/02/proteger-son-serveur-en-utilisant-fail2ban.html "Protéger son serveur avec Fail2ban"
[nicolargo2]: https://blog.nicolargo.com/2012/03/bannir-les-bannis-avec-fail2ban.html "Bannir les bannis avec Fail2ban"

[^1]: https://www.booleanworld.com/protecting-ssh-fail2ban/
[^2]: http://whyscream.net/wiki/Fail2ban_monitoring_Fail2ban.md
[^3]: https://blog.nicolargo.com/2012/02/proteger-son-serveur-en-utilisant-fail2ban.html
[^4]: https://blog.nicolargo.com/2012/03/bannir-les-bannis-avec-fail2ban.html
