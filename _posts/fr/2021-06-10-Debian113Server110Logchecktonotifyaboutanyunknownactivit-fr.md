---
uid: Debian113Server110Logchecktonotifyaboutanyunknownactivit
title: Debian11, Serveur, Logcheck pour notifier toute activité inconnue
description: Installation et configuration de LogCheck, avec réglages. LogCheck parcourt les fichiers journaux du système, retire les motifs légitimes connus et envoie les lignes restantes à l'dministrateur. Il rapporte toute l'activité anormale, aidant à détecter des tentatives d'attaques, éventuellement réussies, qui ne seraient pas stoppées par d'autres outils. Je préfère avoir peu de notifications et les lire toutes que d'en avoir trop et de les ignorer.
category: Informatique
tags: [ Debian11 Serveur, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Logcheck, Analyse de log, Log, Journaux Sécurité, Notification, Détection ]
---

Installation et configuration de LogCheck, avec réglages. LogCheck parcourt les fichiers journaux du système, retire les motifs légitimes connus et envoie les lignes restantes à l'dministrateur. Il rapporte toute l'activité anormale, aidant à détecter des tentatives d'attaques, éventuellement réussies, qui ne seraient pas stoppées par d'autres outils. Je préfère avoir peu de notifications et les lire toutes que d'en avoir trop et de les ignorer.

![21f46bed14e58132cf0942f03f62b1b7.png]({{ "/assets/posts/en/Debian113Server110Logchecktonotifyaboutanyunknownactivit/c17687e78dda446e875215f3f532a1f2.png" | relative_url }})

* TOC
{:toc}

# Présentation de LogCheck

LogCheck fait partie de l'outillage global de la sécurité des serveurs. Il parcourt tous les principaux
fichiers journaux jusqu'à la fin, en retire les motifs habituels standard et envoie les lignes restantes à
l'administrateur. Il enregistre un curseur par fichier journal pour éviter de parcourir plusieurs fois les
mêmes lignes.

Ma politique est de considérer les attaques bloquées par ailleurs comme normales, car elles ont déjà été
bloquées et peuvent l'être encore plus, automatiquement. Je ne suis intéressé que par les motifs inconnus. Il
serait inutile d'avoir tellement de notifications que je ne les lise plus. Je préfère en recevoir moins et les
lire. Sur mes systèmes de test, dans un environnement protégé, mon but est de ne plus avoir de notification du
tout. Si je reçois une notification tous les jours lorsque `cron-daily` se déclenche, je ne vais plus les lire
car je les considère comme normales et je ne verrai pas si une attaque survient dans la même tranche horaire.

# Pré-requis
Cet article ne dépend que de la série sur la [Préparation d'une machine générique](/pages/fr/tags/#préparation-debian11).

## Variables existantes
Nous avons besoin des variables `LAN_*` et `WAN_*` qui ont déjà été définies dans le fichier de configuration
par les articles [Variables de configuration](/Debian111PostInstall010Configurationvariables-fr/) et [Configuration réseau](/Debian111PostInstall020Debian-Networkconfiguration-fr/).

## Chargement des variables
Assurons-nous que les variables sont bien disponibles dans l'environnement en exécutant le script de
configuration :
```bash
source /root/config.env
```

# Installation
Installons simplement l'outil à l'aide d'`apt-get`. Il est léger et ne pose aucune question.
```bash
apt-get install -y logcheck
```
# Configuration et ajustements

## Agrégation (groupe/compteur) des lignes
Tout d'abord, je ne souhaite pas reçevoir une liste exhaustive des lignes restantes dans mes courriels de
notification, je préfère les avoir groupées, le message est plus compact et utile. L'idée est de recevoir une
notification et d'enquêter éventuellement sur le serveur, pas d'historiser les journaux dans ma boite
électronique. Ensuite, je configure l'adresse électronique de destination à laquelle envoyer les notifications.
```bash
sed -i 's/^#\?SYSLOGSUMMARY=0/SYSLOGSUMMARY=1/' /etc/logcheck/logcheck.conf
sed -i 's/^#\?\(SENDMAILTO=\).*/\1"root"/' /etc/logcheck/logcheck.conf
```

## Motifs RegEx utiles

- Interface `en[op][0-9]s[0-9](p[0-9])?`
- IP4 `([0-9]{1,3}\.){3}[0-9]{1,3}`
- IP6 `([[:xdigit:]]{4}:){7}[[:xdigit:]]{4}`
- MAC `([[:xdigit:]]{2}:){13}[[:xdigit:]]{2}`

Je recommende fortement de toujours *encapsuler* les expressions régulières entre un accent circonflexe et un
dollar pour représenter une ligne complète et éviter de filtrer des lignes utiles.

## Ignorer les attaques bloquées par IPTables
IPTables continue à historiser beaucoup de connexions bloquées. Je ne souhaite pas être notifié de toutes ces
connexions bloquées, aucune action de ma part n'est requise, elles ont déjà été bloquées. Je veux être notifié
de l'activité anormale, non prévue, je filtre donc la plupart des problèmes déjà détectés et gérés. Je ne garde
que les tentatives non capturées par des règles spéficiques, celles qui atteignent la règle « attrape-tout ».
Les motifs sont très spécifiques et restrictifs sur des cas parfaitements connus, il peut donc subsister
beaucoup de lignes, au besoin, j'ajusterai les motifs pour filtrer avec moins de restrictions.
```bash
cat << EOF > /etc/logcheck/ignore.d.server/local-kernel
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[[ [:digit:]]+\.[[:digit:]]+\] \[STEALTH\] IN=[[:alnum:]]+ OUT= MAC=[[:alnum:]:]+ SRC=[.[:digit:]]{7,15} DST=[.[:digit:]]{7,15} LEN=[[:digit:]]+ TOS=0x[[:digit:]]+ PREC=0x[[:digit:]]+ TTL=[[:digit:]]+ ID=[[:digit:]]+ .*$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[[ [:digit:]]+\.[[:digit:]]+\] \[SYNSCAN\] IN=[[:alnum:]]+ OUT= MAC=[[:alnum:]:]+ SRC=[.[:digit:]]{7,15} DST=[.[:digit:]]{7,15} LEN=[[:digit:]]+ TOS=0x[[:digit:]]+ PREC=0x[[:digit:]]+ TTL=[[:digit:]]+ ID=[[:digit:]]+ .*$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[[ [:digit:]]+\.[[:digit:]]+\] \[CNSCAN\] IN=[[:alnum:]]+ OUT= MAC=[[:alnum:]:]+ SRC=[.[:digit:]]{7,15} DST=[.[:digit:]]{7,15} LEN=[[:digit:]]+ TOS=0x[[:digit:]]+ PREC=0x[[:digit:]]+ TTL=[[:digit:]]+ ID=[[:digit:]]+ .*$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[[ [:digit:]]+\.[[:digit:]]+\] \[GRSCAN\] IN=[[:alnum:]]+ OUT= MAC=[[:alnum:]:]+ SRC=[.[:digit:]]{7,15} DST=[.[:digit:]]{7,15} LEN=[[:digit:]]+ TOS=0x[[:digit:]]+ PREC=0x[[:digit:]]+ TTL=[[:digit:]]+ ID=[[:digit:]]+ .*$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[[ [:digit:]]+\.[[:digit:]]+\] \[INPUT\] IN=${WAN_IF} OUT= MAC=([[:xdigit:]]{2}:){13}[[:xdigit:]]{2} SRC=([0-9]{1,3}\.){3}[0-9]{1,3} DST=([0-9]{1,3}\.){3}255 LEN=164 TOS=0x00 PREC=0x00 TTL=64 ID=[[:digit:]]+ DF PROTO=UDP SPT=44752 DPT=6771 LEN=[[:digit:]]+$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[[ [:digit:]]+\.[[:digit:]]+\] \[INPUT\] IN=${WAN_IF} OUT= MAC=([[:xdigit:]]{2}:){13}[[:xdigit:]]{2} SRC=([0-9]{1,3}\.){3}[0-9]{1,3} DST=([0-9]{1,3}\.){3}255 LEN=44 TOS=0x00 PREC=0x00 TTL=64 ID=[[:digit:]]+ DF PROTO=UDP SPT=8612 DPT=861[02] LEN=24$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[[ [:digit:]]+\.[[:digit:]]+\] \[INPUT\] IN=${WAN_IF} OUT= MAC=([[:xdigit:]]{2}:){13}[[:xdigit:]]{2} SRC=([0-9]{1,3}\.){3}[0-9]{1,3} DST=255\.255\.255\.255 LEN=101 TOS=0x00 PREC=0x00 TTL=64 ID=[[:digit:]]+ DF PROTO=UDP SPT=[[:digit:]]+ DPT=161 LEN=81$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[[ [:digit:]]+\.[[:digit:]]+\] \[INPUT\] IN=${WAN_IF} OUT= MAC=([[:xdigit:]]{2}:){13}[[:xdigit:]]{2} SRC=([0-9]{1,3}\.){3}[0-9]{1,3} DST=255.255.255.255 LEN=[[:digit:]]+ TOS=0x[01]0 PREC=0x00 TTL=[[:digit:]]+ ID=[[:digit:]]+ (DF )?PROTO=UDP SPT=68 DPT=67 LEN=[[:digit:]]+$
# ff02:0000:0000:0000:0000:0000:0000:0002 = All local routers
# FF02:0000:0000:0000:0000:0000:0000:0001 = All local nodes
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[[ [:digit:]]+\.[[:digit:]]+\] \[IP6\] IN= OUT=en[op][0-9]s[0-9](p[0-9])? SRC=([[:xdigit:]]{4}:){7}[[:xdigit:]]{4} DST=ff02:(0000:){6}0002 LEN=56 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=133 CODE=0$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[[ [:digit:]]+\.[[:digit:]]+\] \[IP6\] IN= OUT=en[op][0-9]s[0-9](p[0-9])? SRC=(0000:){7}0000 DST=ff02:(0000:){6}0016 LEN=76 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=143 CODE=0 MARK=0xd4$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[[ [:digit:]]+\.[[:digit:]]+\] \[IP6\] IN= OUT=lo SRC=(0000:){7}0001 DST=(0000:){7}0001 LEN=[[:digit:]]+ TC=[[:digit:]]+ HOPLIMIT=64 FLOWLBL=[[:digit:]]+ PROTO=UDP SPT=[[:digit:]]+ DPT=[[:digit:]]+ LEN=[[:digit:]]+$
EOF
```

## Ignore les connexions SSH bloquées
Ces lignes sont des échecs de connexion SSH typiques. Elles ont été bloquées, puis le limiteur de débit et les
règles [Fail2ban](/Debian113Server070fail2bantobanobviousattacksources-fr/) vont réagir, si l'attaque persiste. Je n'ai pas besoin d'en être notifié.
```bash
cat << EOF > /etc/logcheck/ignore.d.server/local-ssh
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ sshd\[[[:digit:]]+\]: Received disconnect from [[:digit:].]+ port [[:digit:]]+.*\[preauth\]$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ sshd\[[[:digit:]]+\]: Disconnected from [[:digit:].]+ port [[:digit:]]+.*\[preauth\]$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ sshd\[[[:digit:]]+\]: Invalid user [_[:alnum:]]+ from [[:digit:].]+ port [[:digit:]]+$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ sshd\[[[:digit:]]+\]: Connection closed by [[:digit:].]+ port [[:digit:]:]+.*\[preauth\]$
EOF
```

## Activité normale de Systemd
Ces actions sont des opérations de maintenance normales automatiquement déclenchées par `systemd`, je ne m'en
préoccupe pas, du moment qu'elles fonctionnent ! ;)
```bash
cat << EOF > /etc/logcheck/ignore.d.server/local-systemd
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ systemd\[1\]: [-/:. [:alnum:]]+: Succeeded.$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ systemd\[1\]: [-/:. [:alnum:]]+: Succeeded.$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ systemd\[1\]: Started [-/:. [:alnum:]]+$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ systemd\[1\]: Created [-/:. [:alnum:]]+$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ systemd\[1\]: Starting [-/:. [:alnum:]]+$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ systemd\[1\]: Finished [-/:. [:alnum:]]+$
EOF
```

## CronApt
CronApt nous indique qu'il a tenté et réussi à mettre la base des paquetages à jour, ou qu'il a téléchargé des
paquetages, ou qu'il.... nous a envoyé un courriel !!! C'est un comportement normal et je suis donc déjà
prévenu des informations importantes par rapport à ce qu'il fait.
```bash
cat << EOF > /etc/logcheck/ignore.d.server/local-cronapt
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ cron-apt: CRON-APT ACTION: 9-notify$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ cron-apt: CRON-APT LINE: /usr/bin/apt-get -o quiet=2 -q -q --no-act upgrade$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ cron-apt: CRON-APT LINE: /usr/bin/apt-get -o quiet=2 update -o quiet=2$
EOF
```

## Divers
Il y a une procédure d'audit régulier déclenchée dans le noyau linux pour collecter des indicateurs de
performance. Cette procédure doit être aussi transparente que possible et sa période de déclenchement est
automatiquement ajustée si son appel prend trop de temps. C'est donc un message normal, au moins jusqu'à ce que
la période optimale soit trouvée (en fonction de la charge du système). Dans tous les cas, j'aurais bien
d'autres problèmes si la fréquence et les valeurs de ce message étaient anormales et qu'il devienne utile. J'ai
aussi regroupé dans ce fichier les filtrage des lignes normales concernant le démarrage de *fail2ban*, *dhcp*,
*ntp* et *rsyslogd*. *RKHunter* envoie déjà ses propres courriels de notification, inutile de dupliquer
l'information.
```bash
cat << EOF > /etc/logcheck/ignore.d.server/local-misc
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[[ [:digit:]]+\.[[:digit:]]+\] perf: interrupt took too long \([[:digit:]]+ > [[:digit:]]+\), lowering kernel.perf_event_max_sample_rate to [[:digit:]]+$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ fail2ban-server\[[[:digit:]]+\]: Server ready$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ isc-dhcp-server\[[[:digit:]]+\]: Starting ISC DHCPv4 server: dhcpd.$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ ntpd\[[[:digit:]]+\]: configuration OK$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ rsyslogd:  \[origin software="rsyslogd" swVersion="8.1901.0" x-pid="[[:digit:]]+" x-info="https://www.rsyslog.com"\] rsyslogd was HUPed$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ rkhunter: Please inspect this machine, because it may be infected.$
EOF
```

## Interface réseau LAN
S'il y a une seconde interface réseau sur le serveur, et s'il est utilisé comme routeur, le réseau interne peut
être redémarré, débranché, en panne, ... Je ne souhaite pas être prévenu par courriel, ce serait stupide
d'envoyer une notification quelquepart où je ne peux pas la consulter ! ;) De plus ces règles sont spécifiques
à mon matériel (interface et switch).
```bash
cat << EOF > /etc/logcheck/ignore.d.server/local-router
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[\s?[[:digit:]]+\.[[:digit:]]+\] e1000e 0000:03:00.0 enp3s0: 10/100 speed: disabling TSO$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[\s?[[:digit:]]+\.[[:digit:]]+\] e1000e: ${LAN_IF} NIC Link is Down$
^\w{3} [ :[:digit:]]{11} [-._[:alnum:]]+ kernel: \[\s?[[:digit:]]+\.[[:digit:]]+\] e1000e: ${LAN_IF} NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx$
```

# Tests

## Logcheck-test
Si vous n'êtes pas certains de vos règles, vous pouvez utiliser l'outil `logcheck-test` pour appliquer un
fichier de règles sur un fichier de journal, soit pour afficher les correspondances, soit pour afficher les
anomalies. Cela ne fait pas partie de mon installation standard, mais je voulais noter cette information car
elle peut toujours servir pour déboguer les règles et RegExp.

![475eb6586aeb857ecd7a2a5848487b3c.png]({{ "/assets/posts/en/Debian113Server110Logchecktonotifyaboutanyunknownactivit/396b3e745f0f4317af54713d5a046584.png" | relative_url }})

## Test des règles
Ce test va exécuter *logcheck* avec une configuration réelle, mais ne mettra pas le curseur de lecture à jour,
il peut donc être exécuté plusieurs fois. Il n'envoie pas de courriel, non plus.
```bash
sudo -u logcheck logcheck -o -t
```

## Test de notification
Celui-ci ne mettre pas le curseur à jour, non plus, il peut donc être rejoué autant que nécessaire, jusqu'à ce
que les notifications fonctionnent comme voulu.
```bash
sudo -u logcheck logcheck -t
```

# Supports et liens

- [zonewebmaster][zonewebmaster] [^1]
- [ictforce][ictforce] [^2]

# Notes de bas de page

[zonewebmaster]: https://www1.zonewebmaster.eu/serveur-debian-securite
[ictforce]: https://www.ictforce.be/2018/linux-security-logcheck/

[^1]: https://www1.zonewebmaster.eu/serveur-debian-securite
[^2]: https://www.ictforce.be/2018/linux-security-logcheck/
