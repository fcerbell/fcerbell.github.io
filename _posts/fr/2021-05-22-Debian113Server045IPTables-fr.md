---
uid: Debian113Server045IPTables
title: Debian11, Serveur, Configuration évolutive d'IPTables
description: La fonction pare-feu `iptable` du noyau Linux est déjà inclue dans le noyau et l'application cliente est déjà installée. Je vais installer un paquetage pour sauvegarder les règles de pare-feu sur le disque et les recharger automatiquement au redémarrage. Je prépare également un jeu de règles évolutif avec une spécificité, il interdit toutes les connexions sortantes par défaut. Ainsi, si quelqu'un arrive à obtenir l'accès à mon serveur et à exécuter un script, ce dernier sera probablement bloqué et ne pourra pas renvoyer des informations à l'attaquant. J'utilise les cibles non-standard TARPIT et CHAOS contre des attaquants évidents et des règles de limitation de débit, comme moyen de riposte passive.
category: Informatique
tags: [ Debian11 Serveur, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, IPTables, Sécurité, Filtrage, Réseau, Pare-feu, Règles de pare-feu, Chaines de pare-feu, Crackeur, SSH, TCP, IP, ICMP, Loopback, IPv6, CHAOS, TARPIT, DROP ]
---
La fonction pare-feu `iptable` du noyau Linux est déjà inclue dans le noyau et l'application cliente est déjà installée. Je vais installer un paquetage pour sauvegarder les règles de pare-feu sur le disque et les recharger automatiquement au redémarrage. Je prépare également un jeu de règles évolutif avec une spécificité, il interdit toutes les connexions sortantes par défaut. Ainsi, si quelqu'un arrive à obtenir l'accès à mon serveur et à exécuter un script, ce dernier sera probablement bloqué et ne pourra pas renvoyer des informations à l'attaquant. J'utilise les cibles non-standard TARPIT et CHAOS contre des attaquants évidents et des règles de limitation de débit, comme moyen de riposte passive.

* TOC
{:toc}

# Pré-requis

## Variables existantes

Le nom de l'interface réseau externe (`WAN_IF`) est déjà défini dans le fichier de configuration par l'article [Variables de configuration](/Debian111PostInstall010Configurationvariables-fr/).

## Rechargement des variables dans l'environnement

Assurons-nous que la variable `WAN_IF` est disponible en rechargeant le fichier dans l'environnement :

```bash
source /root/config.env
```

# Préconfiguration des paquetages

```bash
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
```

# Installation

Je vais utiliser les cibles `CHAOS` et `TARPIT`. Elles sont disponibles en tant que module pour le noyau. Nous devons donc
installer aussi la chaine de construction des modules Debian. Elle compile et recompile les modules à chaque installation d'un
nouveau noyau. La beauté de Debian !!!

```bash
apt-get install -y iptables-persistent xtables-addons-dkms
```

# Blocage d'IPv6

Mes serveurs n'utilisent pas IPv6 du tout, mais j'ai préféré ne pas le désactiver pour autant. J'installe donc des règles de
pare-feu pour bloquer tout le traffic IPv6 entrant et sortant. Je journalise le traffic sortant, pour penser à désactiver IPv6
dans les applications installées.

```bash
cat << EOF > /etc/iptables/rules.v6
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
# Temporary rules to detect unwanted traffic 
-A OUTPUT -m limit --limit 10/min -j LOG --log-prefix "[IP6] "
COMMIT
EOF
```

# Règles et chaines IPv4

D'abord, je configure toutes les politiques par défaut (celles appliquées si aucune règle de la chaîne ne s'applique) à `DROP`. La
règle est simple : ce qui n'est pas autorisé est interdit ! Si un programme malicieux, pour une raison inconnue, était exécuté sur
le serveur, il tenterait probablement d'envoyer des informations vers l'extérieur, telles qu'un fichier de mot de passe, des clés
d'authentification, un portefeuille de crypto-monnaie... Mais, n'étant pas explicitement autorisé, il sera bloqué.

```bash
cat <<EOF > /etc/iptables/rules.v4
*raw
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
COMMIT
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
EOF
```

Je vais installer `portsentry` dans les prochains articles, mais le noyau peut aussi détecter les tentatives de scan et s'en
protéger grâce aux modules `psd` et `lscan`. Je ne connais pas d'amis cherchant à me scanner, j'utilise donc la cible `CHAOS` en
réponse aux scans. L'idée est de répondre avec des données aléatoires. Si j'ignorais les paquets, l'attaquant sachant que le
serveur existe, c'est que je me protège contre son scan. En répondant avec des données aléatoires, le serveur semble ne pas se
protéger contre le scan, l'attaquant va analyser les informations reçues en pensant qu'elles sont réelles, mais n'arrivera pas à
identifier l'empreinte de ma pile réseau et de mon système d'exploitation.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-N xt_portscan
-A xt_portscan -m psd -m limit --limit 10/min -j LOG --log-prefix "[PSD] "
-A xt_portscan -m psd -j CHAOS
-A xt_portscan -m lscan -p tcp --synscan -m limit --limit 10/min -j LOG --log-prefix "[SYNSCAN] "
-A xt_portscan -m lscan -p tcp --synscan -j CHAOS
-A xt_portscan -m lscan -p tcp --stealth -m limit --limit 10/min -j LOG --log-prefix "[STEALTH] "
-A xt_portscan -m lscan -p tcp --stealth -j CHAOS
-A xt_portscan -m lscan -p tcp --cnscan -m limit --limit 10/min -j LOG --log-prefix "[CNSCAN] "
-A xt_portscan -m lscan -p tcp --cnscan -j CHAOS
-A xt_portscan -m lscan -p tcp --grscan -m limit --limit 10/min -j LOG --log-prefix "[GRSCAN] "
-A xt_portscan -m lscan -p tcp --grscan -j CHAOS
EOF
```

Comme chaque connexion sortante est bloquée par défaut, je liste les adresses IP des dépôts Debian officiels dans une chaine
spécifique, pour accepter les paquets à destination de ces adresses et j'appellerai cette chaine depuis la chaine de traffic
sortant. Ce sera facile d'ajouter ou de retirer des IP dans cette chaine.

```bash
cat <<EOF >> /etc/iptables/rules.v4
-N DebianRepositories
-A DebianRepositories -d 128.31.0.62 -j ACCEPT
-A DebianRepositories -d 130.89.148.77 -j ACCEPT
-A DebianRepositories -d 149.20.4.15 -j ACCEPT
-A DebianRepositories -d 151.101.130.132 -j ACCEPT
-A DebianRepositories -d 151.101.194.132 -j ACCEPT
-A DebianRepositories -d 151.101.2.132 -j ACCEPT
-A DebianRepositories -d 151.101.66.132 -j ACCEPT
-A DebianRepositories -d 192.168.1.254 -j ACCEPT
-A DebianRepositories -d 199.232.178.132 -j ACCEPT
-A DebianRepositories -d 212.27.32.66 -j ACCEPT
-A DebianRepositories -d 91.121.146.196 -j ACCEPT
EOF
```

De même, le serveur a besoin de résoudre des adresses IP. Je crée donc une chaine DNS pour définir les requêtes DNS en TCP (à
priori non-indispensable pour l'instant) et UDP. La chaine contrôlant le traffic sortant appellera cette chaine.

```bash
cat <<EOF >> /etc/iptables/rules.v4
-N DNS
-A DNS -p udp --dport 53 -j ACCEPT
-A DNS -p tcp --tcp-flags FIN,SYN,RST,ACK SYN --dport 53 -j ACCEPT
EOF
```

SSH est la seule méthode de connexion aux serveurs, avec une authentification par clé exclusivement, ce qui limite les risques
d'attaque par brute-force. J'ajoute néanmoins une protection dans le pare-feu par limitation de flux. Cette règle n'accepte pas
plus de 3 paquets TCP sur le port 22 par minute. Les connexions déjà passées à travers cette chaine et acceptées par une chaine
suivante sont établies et seront donc acceptées en amont de ce limiteur. Le limiteur ne s'appliquera donc qu'aux paquets sans
rapport avec les connexions établies. C'est simple et efficace. Je journalise aussi les tentatives bloquées, avec un limiteur pour
éviter le remplissage des journaux, pas plus de 10 messages par minute. Enfin, pour les IP sources qui atteindraient le seuil de
blocage, leur traffix est dirigé vers la cible `TARPIT`... Cette destination ne termine jamais les échanges de demande de
connexion et les oublie. Ainsi, cela ne consomme aucune ressource sur le serveur, mais la machine de l'attaquant rempli sa table
de connexion avec des connexions en cours d'ouverture. Cette chaine sera appellée par les chaines entrantes à risques.
Enfin, je crée une chaine pour les connexions SSH autorisées, que j'appellerai seule ou après celle du limiteur.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-N SSH_ratelimiter
-A SSH_ratelimiter -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH --rsource
-A SSH_ratelimiter -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --rttl --name SSH --rsource -m limit --limit 10/min -j LOG --log-prefix "[SSHRATE]"
-A SSH_ratelimiter -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 --rttl --name SSH --rsource -j TARPIT

-N SSH
-A SSH -p tcp --dport 22 --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT
```

Le serveur n'est pas (encore) un serveur d'horloge (NTP), mais il doit pouvoir être un client pour synchroniser sa propre horloge.
Je crée donc une chaine définissant ce qu'est le protocole NTP et je la ferai appeler depuis la chaine gérant les flux sortants.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-N NTP
-A NTP -p udp --dport 123 -j ACCEPT
EOF
```

Je crée une chaine spécifique pour la validation du traffix entrant depuis l'interface externe. Cette chaine sera appelée par la
chaine globale de filtrage du traffic entrant. Elle va appeler le limiteur SSH pour éliminer les attaques, puis la chaine
acceptant les connexions SSH entrantes.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-N WAN_input
-A WAN_input -j SSH_ratelimiter
-A WAN_input -j SSH
EOF
```

De même, je crée une chaine de validation pour les connexions sortantes vers l'extérieur. J'y appelle la chaine listant les dépôts
Debian, celle autorisant les requêtes DNS et celle autorisant les requêtes NTP. 
```bash
cat <<EOF >> /etc/iptables/rules.v4
-N WAN_output
-A WAN_output -p tcp --dport 80 --tcp-flags FIN,SYN,RST,ACK SYN -j DebianRepositories
-A WAN_output -j DNS
-A WAN_output -j NTP
EOF
```

Puis, je configure la chaine de filtrage des arrivées. Elle commence par accepter les paquets en rapport avec une connexion déjà
validée, les paquets sur l'interface locale de bouclage (loopback), tous les paquets ICMP (on pourrait durcir ce filtrage), puis
elle appelle la chaine de filtrage des paquets entrants sur l'interface externe publique. À ce stade, la chaine a terminé
d'autoriser explicitement des paquets, les paquets atteignant ce stade sont donc à rejeter (par la politique par défaut), mais on
va les analyser pour prendre des mesures plus globales en appelant la chaine de détection de scan, on va aussi ignorer
prématurément les paquets NetBios en broadcast avant qu'ils n'atteignent la règle de journalisation. Enfin, on journalise ce qui
reste et on l'ignore (politique par défaut).
```bash
cat <<EOF >> /etc/iptables/rules.v4
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i ${WAN_IF} -j WAN_input
-A INPUT -j xt_portscan
# NetBIOS Name, Datagram and Session services
-A INPUT -p udp -m multiport --dports 137,138 -j DROP
-A INPUT -p tcp --dport 139 -j DROP
-A INPUT -m limit --limit 10/min -j LOG --log-prefix "[INPUT] "
EOF
```

Concernant la chaîne de filtrage du traffic sortant, on commence par accepter ce qui est en lien avec une connexion ouverte (donc
déjà acceptée), avec l'interface locale de loopback, tous les paquets ICMP. On appelle la chaine spécifique au traffic sortant
vers l'interface externe publique. Ce qui n'a pas encore été accepté sera ignoré par la politique par défaut, après avoir été
journalisé.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A OUTPUT -o lo -j ACCEPT
-A OUTPUT -p icmp -j ACCEPT
-A OUTPUT -o ${WAN_IF} -j WAN_output
-A OUTPUT -m limit --limit 10/min -j LOG --log-prefix "[OUTPUT] "
EOF
```

J'en profite pour préconfigurer quelques règles dans la chaine de filtrage des paquets en transit entre les interfaces externes.
Cela servira dans le cas d'un serveur à plusieurs interfaces servant de routeur ou de passerelle.
```bash
cat <<EOF >> /etc/iptables/rules.v4
-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -m limit --limit 10\/min -j LOG --log-prefix "[FORWARD] "
COMMIT
EOF
```

# Redémarrage pour appliquer

`systemctl restart netfilter-persistent` fonctionnerait, mais figerait la connexion courante car elle n'est pas connue et acceptée
comme connexion existante et qu'elle n'envoie plus de paquet acceptable par les chaines. Il faudrait se reconnecter. Autant
redémarrer pour tester ces chaines et règles. 
```bash
reboot
```
