---
uid: Debian111Bootstrap000Introduction
title: Debian11 Bootstrap Introduction
description: Cet article est le premier d'une longue série. Je possède mon propre domaine, avec tout un lot de services, dont une suite complète de messagerie, des boites virtuelles, des filtres pour classer les messages sur le serveur (sieve/managesieve), plusieurs applications web telles que Redmine, Mercurial, FileZ, Pydio, des outils de supervision. Je vais tout réinstaller de zéro et mettre mes notes d'installation à jour. Vous saurez comment j'installe, sécurise, configure et administre mes VMs, serveurs internets public postes de travail et portables.
category: Informatique
tags: [ Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Mise à jour, IPTables, CronApt, Fail2Ban, PortSentry, RKHunter, Tripwire, Logcheck, Logwatch, FWLogwatch, BackupManager, Monit, OpenNTPd, Prometheus, AlertManager, Grafana, Bind, Named, Mail Transport Agent, MTA, Mail Delivery Agent, MDA, mSMTPd, DHCP, isc-DHCPd, TFTPd, NFS, NetBoot, Routeur, Firewall, Pare-feu, Apache2, mod_security2, mod_evasive, mod_rewrite, mod_proxy, mod_wstunnel, WebSockets, Authentification, Awffull, Webalyzer, Awstats, VHosts, SSL, HTTP, HTTPs, TaskWarrior, Taskd, Joplin, Mariadb, Mysql, PHPMyAdmin, YOURLS, URL Shortener, Shortener, Réducteur d'URL, PrivateBin, ZeroBin, PasteBin, Mercurial, Hg, HgWeb, Redmine, Buildbot, CICD, Squid, Proxy, e2Guardian, Dansguardian, Controle parental, Parental, Dovecot, Managesieve, Sieve, Postfix, Utilisateurs virtuels, Domaines virtuels, Adresses virtuelles, Boites virtuelles, Virtuel, PostfixAdmin, Amavis, SpamAssassin, Razor, Mailzu, RBLCheck, MailGraph, QueueGraph, PostGrey, Procmail, Roundcube, Squirrel, DSpam ]
---
Cet article est le premier d'une longue série. Je possède mon propre domaine, avec tout un lot de services, dont une suite complète de messagerie, des boites virtuelles, des filtres pour classer les messages sur le serveur (sieve/managesieve), plusieurs applications web telles que Redmine, Mercurial, FileZ, Pydio, des outils de supervision. J'ai installé ça en 2013 sur une Debian 7 Wheezy, ça n'a jamais été craqué et le serveur est très stable (actuellement 900 jours sans redémarrage). Debian 11 Bullseye est sur le point de sortir, je vais tout réinstaller de zéro et mettre mes notes d'installation à jour. J'ai décidé de partager mes notes d'installation [Debian][debianorg] [^1] pour les VM, serveurs, stations de travail. Vous saurez comment j'installe, sécurise, configure et administre mes VMs, serveurs internets public postes de travail et portables. Je n'ai pas la prétention d'avoir une procédure d'installation parfaite, mais je suis presque sûr que vous apprendrez quelque chose aujourd'hui.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports imprimables associés à la [fin de cet
article](#supports-et-liens).

* TOC
{:toc}

# Introduction

J'utilise uniquement Debian depuis 1999 absolument partout, sur les stations de travail, les portables, les serveurs. Je possède
mes domaines et gère les DNS, la messagerie, les pages web, le partage de fichiers, la gestion de projets... Il se dit que Debian
n'a jamais besoin d'être réinstallée grâce à `apt`. Malgré cela, je préfère réinstaller mes machines de temps en temps. À chaque
fois, j'apprends quelque chose et maintiens mes connaissances à jour.

Je rédige toujours mes documentations pour pouvoir reproduire mes installations et configurations. Désormais, je prends mes notes
et les partage entre tous mes périphériques grâce à [Joplin][Joplin] [^2], au format Markdown. Je construis mon blog avec
[Jekyll][Jekyll] [^3] en Markdown... Vous devinez... C'est votre jour de chance aujourd'hui, je vais convertir mes notes en
articles de Blog.

# Sujets traités

J'ai résumé la liste dans les mot-clés suivants :
Debian, Buster, Bullseye, upgrade, iptables, cronapt, cron-apt, fail2ban, portsentry, rkhunter, tripwire, logcheck, logwatch, fwlogwatch, backupmanager, backup-manager, monit, openntpd, prometheus, alertmanager, grafana, bind, named, mail transport agent, MTA, mail delivery agent, MDA, msmtpd, dhcp, isc-dhcpd, tftpd, nfs, netboot, router, firewall, apache2, mod_security2, mod_evasive, mod_rewrite, mod_proxy, mod_wstunnel, websockets, authentication, awffull, webalyzer, awstats, vhosts, ssl, http, https, taskwarrior, taskd, joplin, mariadb, mysql, phpmyadmin, yourls, url shortener, privatebin, zerobin, pastebin, mercurial, hg, hgweb, redmine, buildbot, cicd, squid, proxy, e2guardian, dansguardian, parental control, Dovecot, Managesieve, manage-sieve, sieve, Postfix, virtual users, virtual domains, virtual mailboxes, Postfixadmin, amavis, spamassassin, razor, mailzu, rblcheck, mailgraph, queuegraph, postgrey, procmail, roundcube, squirrel, dspam

# Sujets non traités

Lors de l'installation d'une VM, il y a des étapes particulières auxquelles penser. L'affectation d'une adresse IP statique en est
une, mais certaines sont moins évidentes. Avez-vous la maîtrise de l'hyperviseur ? Probablement pas dans le cloud et les disques
de vos VM ne sont rien d'autre que de simples fichiers qui peuvent être copiés et analysés par un tiers. Connaissez-vous les lois
Américaines *Patriot act* et *Safe harbour* ? L'encryption des disques est donc une réelle nécessité.

Bien qu'il soit possible de convertir un système déjà installé sur des disques non-chiffrés vers des disques chiffrés, je ne
couvrirai pas cette configuration avancée particulière. Mais rien ne vous empêche de réfléchir au problème et à ses solutions.

# Structure de ces articles

- La première partie, bootstrap, décrit les toutes premières étapes à effectuer après l'installation
- La seconde partie, base, décrit les outils communs que j'installe sur toutes mes machines
- La troisième partie, serveur, décrit les outils communs à tous mes serveurs (sécurité, supervision, sauvegardes, ...)
- La quatrième partie, services, décrit l'installation et la configuration de chacun des services potentiels à déployer sur les
  serveurs
- La cinquième et dernière partie décrit la finalisation, le ménage avant le dernier redémarrage et l'ouverture du service

Je suis paresseux et j'écris mes notes de manière à ce qu'elles soient faciles à reproduire, par copier-coller du code. Ainsi,
vous pourrez aussi facilement reproduire mes installations, cependant, je recommande **fermement** de bien comprendre, non
seulement chaque bloc de code avant de l'exécuter, mais aussi et surtout les raisons pour lesquelles j'ai choisi de l'écrire de
cette manière. Chaque choix de configuration a été conçu pour correspondre avec tous les autres choix, afin de construire un
système homogène et cohérent.

Vous aurez besoin de vous connecter par `ssh` à vos machines et de vous auto-promouvoir root grâce à `su -`. Si vous ne savez pas
ce que cela signifie, vous pouvez continuer à lire, enregistrer cette page dans vos favoris et revenir plus tard, mais, par pitié,
ne tentez pas d'appliquer ces articles sur des serveurs publics.

# Supports et liens

- [Debian][debianorg]
- [Joplin][joplin]
- [Jekyll][jekyll]

# Notes de bas de page

[debianorg]: http://www.debian.org "Debian website"
[^1]: [http://www.debian.org][debianorg] "Debian website"

[joplin]: https://joplinapp.org/ "Joplin app website"
[^2]: [https://joplinapp.org/][joplin] "Joplin app website"

[jekyll]: https://jekyllrb.com/ "Jekyll website"
[^3]: [https://jekyllrb.com/][jekyll] "Jekyll website"
