---
uid: Debian112Preparation000Initialupdateandupgrade
title: Debian11, Préparation, Mise à jour Debian 10 Buster vers Debian 11 Bullseye
description: Comment configurer les dépôts de paquetages binaires sur une distribution GNU Linux Debian 10 Buster pour mettre tout le système à jour vers une Debian 11 Bullseye (« testing » actuellement), installer `aptitude` et accélérer le démarrage de la machine.
category: Informatique
tags: [ Préparation Debian11, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Upgrade, Mise à jour ]
---

Comment configurer les dépôts de paquetages binaires sur une distribution GNU Linux Debian 10 Buster pour mettre tout le système à jour vers une Debian 11 Bullseye (« testing » actuellement), installer `aptitude` et accélérer le démarrage de la machine.

* TOC
{:toc}

# Pré requis

Avant de commencer cette série d'articles pour préparer une machine Debian 11 générique, je m'attends à avoir une machine propre
Debian 10 Buster avec les étapes de la série [Postinstallation Debian 11](/pages/fr/tags/#postinstallation-debian11) steps executed. If not, read the blog archives.


# Connection en tant que root

Toutes les commandes seront exécutées en tant que *root*. Dans une installation *Debian* fraîche, `sudo` n'est pas installé par
défaut, nous verrons cela dans un prochain article. Vous pouvez vous connecter directement sous le compte *root*, si c'est
autorisé, sinon, en tant que simple utilisateur et utiliser la commande `su -` pour obtenir les privilèges de root.

# Réinitialisation des dépôts

Pour commencer, je ne souhaite pas avoir tous les dépôts listés dans un seul fichier. Je vide donc le fichier global. Les dépôts
seront listés dans des fichiers indépendants.
```bash
echo > /etc/apt/sources.list
```

# Ajout des dépôts

Maintenant, je crée un fichier par version, avec tous les dépôts de la version. Je n'ai pas besoin des dépôts des sources. Je
commente les lignes des dépôts dont je n'ai pas besoin, pour accélérer le processus *update* et limiter la taille de la base de
données.

## Stretch (9)

*Stretch* est l'ancienne version stable à l'heure où j'écris ces lignes. Si jamais j'avais besoin d'un vieux paquetage, je pourrai
décommenter une ligne de ce fichier.
```bash
cat > /etc/apt/sources.list.d/stretch.list << EOF
# Stretch

#deb http://ftp.fr.debian.org/debian/ stretch main non-free contrib
#deb http://security.debian.org/ stretch/updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ stretch-proposed-updates non-free contrib main
#deb http://ftp.fr.debian.org/debian/ stretch-updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ stretch-backports main contrib non-free
#deb http://www.deb-multimedia.org/ stretch main non-free
EOF
```

## Stable/Buster (10)

*Buster* est l'actuelle version stable, mais je ne souhaite pas installer de paquetages venant du dépôt *proposed-updates* car ils
cassent parfois les dépendences ou les mise-à-jours.
```bash
cat > /etc/apt/sources.list.d/buster.list << EOF
# Buster

deb http://ftp.fr.debian.org/debian/ buster main non-free contrib
deb http://security.debian.org/ buster/updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ buster-proposed-updates non-free contrib main
deb http://ftp.fr.debian.org/debian/ buster-updates main contrib non-free
deb http://ftp.fr.debian.org/debian/ buster-backports main contrib non-free
deb http://www.deb-multimedia.org/ buster main non-free
EOF
```

## Testing/Bullseye (11)

Voici la version actuellement en « testing », future version «stable», les dépôts de mise-à-jour de sécurité ne sont pas encore
disponibles, avant qu'elle ne soit passée en stable. 
```bash
cat > /etc/apt/sources.list.d/bullseye.list << EOF
# Bullseye

deb http://ftp.fr.debian.org/debian/ bullseye main non-free contrib
#deb http://security.debian.org/ bullseye/updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ bullseye-proposed-updates non-free contrib main
deb http://ftp.fr.debian.org/debian/ bullseye-updates main contrib non-free
deb http://ftp.fr.debian.org/debian/ bullseye-backports main contrib non-free
deb http://www.deb-multimedia.org/ bullseye main non-free
EOF
```

## SID/Bookworm (12)

La version «sid» (Still In Development) est actuellement *Bookworm*, elle passera en «testing» lorsque la testing passera en
stable. J'inclue les dépôt pour pouvoir y piocher certains paquetages, lorsqu'ils ne sont pas disponibles dans la version
précédente, mais uniquement depuis le dépôt principal.
```bash
cat > /etc/apt/sources.list.d/bookworm.list << EOF
# Bookworm

#deb http://ftp.fr.debian.org/debian/ bookworm main non-free contrib
#deb http://security.debian.org/ bookworm/updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ bookworm-proposed-updates non-free contrib main
#deb http://ftp.fr.debian.org/debian/ bookworm-updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ bookworm-backports main contrib non-free
#deb http://www.deb-multimedia.org/ bookworm main non-free
EOF
```

## Trixie

Cette version n'existe pas vraiment encore, ce sera la prochaine version «sid» de développement. Je la liste pour être complet et
préparer le futur, mais je n'ai jamais eu besoin d'installer des paquetage depuis une telle version, sur mes serveurs long-terme.
```bash
cat > /etc/apt/sources.list.d/sid.list << EOF
# Sid

#deb http://ftp.fr.debian.org/debian/ sid main non-free contrib
#deb http://security.debian.org/ sid/updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ sid-proposed-updates non-free contrib main
#deb http://ftp.fr.debian.org/debian/ sid-updates main contrib non-free
#deb http://ftp.fr.debian.org/debian/ sid-backports main contrib non-free
#deb http://www.deb-multimedia.org/ sid main non-free
EOF
```

## Experimental

Ces dépôts ne sont pas listés du tout, car il ne s'agit pas d'une version à part entière, juste un dépôt de paquetage pas encore
assez stable, ni pour la testing, ni pour la version en développement. C'est réservé aux mainteneurs Debian, je ne suis pas
(encore) assez fou !

# Configuration d'Apt

Quelques soient les lignes décommentées, la suite d'outils `apt` doit donner une priorité plus élevée à la version visée,
«bullseye». Cette règle est vraie avant que «Bullseye» soit sortie, mais également après. J'ai augmenté la taille du cache car
cela peut-être nécessaire, vu le nombre de dépôts à indexer.

```bash
cat >/etc/apt/apt.conf << EOF
APT::Default-Release "bullseye";
APT::Cache-Limit 150000000;
Acquire::Languages fr,en;
Acquire::ForceIPv4 "true";
EOF
```

# Préférences d'Apt

Par défaut, les paquetages des dépôts de la version «testing» ont la même priorité que ceux du dépôt «backports» de la version
stable. Lorsque c'est possible, je souhaite privilégier les paquetages des dépôts de la version stable, même s'il sont moins
récents que ceux de « testing », je dois donc artificiellement diminuer la priorité des paquetages des dépôts «testing», sauf que
la, maintenant, la version que je vise est la testing. Je ne vais donc **pas appliquer cette étape** avant que la version
«testing» (Bullseye) ne passe en «stable», je le ferai ensuite.

```bash
cat >> /etc/apt/preferences.d/00-backportsbeforetesting << EOF
Package: *
Pin: release a=testing
Pin-Priority: 50
EOF
```

# Installation d'Aptitude

J'aime utiliser `aptitude` sur mes machines, j'en ai l'habiture, particulièrement des commandes *search*, *show* et *why*. De
plus, je n'aime pas beaucoup le côté coloré et verbeux de `apt`. J'installe aussi immédiatement la clé publique du dépôt
*deb-multimedia* pour éviter les avertissements. La première ligne répond à une question d'un paquetage qui n'a pas été encore
installé, ainsi, debconf connaîtra déjà la réponse lorsque j'installerai le paquetage et qu'il posera la question, m'évitant une
interraction.

```bash
echo libc6 libraries/restart-without-asking boolean true | debconf-set-selections
apt-get -y update -oAcquire::AllowInsecureRepositories=true
apt-get -y --allow-unauthenticated install aptitude deb-multimedia-keyring
```

# Mise à jour du système en Bullseye

Ok, bien, maintenant, il est temps d'appliquer mes préférences et de faire la mise à jour complète du système.
```bash
echo base-passwd base-passwd/system/user/irc/home/_var_run_ircd/_run_ircd boolean true | debconf-set-selections
apt-get -y update &&
apt-get -y upgrade &&
apt-get -y dist-upgrade &&
apt-get -y autoremove &&
apt-get -y autoclean &&
apt-get clean &&
cat /etc/os-release
```
Félicitations ! Vous êtes désormais sur une Bullseye toute fraîche, comme si elle avait été installée par défaut, même si ce
n'était pas possible dans votre contexte.

# Accélération du redémarrage

Personne n'a accès à la console de mes serveurs. Je n'ai presque jamais eu recours à une console distante (KVM/IPMI) en temps
normaux. Du coup, je peux réduire le délai du menu GRUB et économiser quelques secondes. Dans tous les cas, le compte root sera
verrouillé sans mot de passe, une connexion en console serait possible, mais plus délicate.
```bash
sed -i 's/GRUB_TIMEOUT=./GRUB_TIMEOUT=1/' /etc/default/grub
update-grub
```

# Redémarrage

Ces mises-à-jour massive ont très probablement installé un nouveau noyau Linux, dans ce cas, un redémarrage est nécessaire pour
l'utiliser. D'autre part, la compilation de modules noyau utilise DKMS, qui lui-même utilise `uname` pour déterminer la version 
des source du noyau à utiliser. Il est donc préférable de redémarrer maintenant pour ne pas oublier plus tard.

```bash
reboot
```
