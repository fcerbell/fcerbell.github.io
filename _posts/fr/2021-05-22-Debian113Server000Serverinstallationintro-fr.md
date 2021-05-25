---
uid: Debian113Server000Serverinstallationintro
title: Debian11, Serveur, Introduction
description: Bien que Débian soit la meilleure distribution pour faire tourner un serveur, il faut la mettre à jour de temps en temps pour utiliser des technologies plus récentes. Je suis sur le point de migrer mon serveur agé de 8 ans de Debian 7 Wheezy à Debian 11 Bullseye, pour bénéficier d'un meilleur pare-feu, de Prometheus/Grafana à la place de Munin,... Voici la liste des procédures d'installations de base que j'utilise sur tous mes serveurs (sécurité, supervision, ...) et que je vais documenter dans les prochains articles.
category: Informatique
tags: [ Debian11 Serveur, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Introduction, Base, Generique ]
---
Bien que Debian soit la meilleure distribution pour faire tourner un serveur, il faut la mettre à jour de temps en temps pour utiliser des technologies plus récentes. Je suis sur le point de migrer mon serveur agé de 8 ans de Debian 7 Wheezy à Debian 11 Bullseye, pour bénéficier d'un meilleur pare-feu, de Prometheus/Grafana à la place de Munin,... Voici la liste des procédures d'installations de base que j'utilise sur tous mes serveurs (sécurité, supervision, ...) et que je vais documenter dans les prochains articles.

* TOC
{:toc}

## Pré-requis

Avant de commencer cette série pour spécialiser une machine avec un rôle de serveur, je m'attends à disposer d'une [installation propre de Debian 11](/pages/fr/tags/#préparation-debian11).

## Ancienne configuration

Voici un résumé rapide de la configuration de mon ancien serveur :
- scripts IPTables
- portsentry
- Tripwire
- Logcheck
- Logwatch

Il est extrèmement stable, comme on peut le constater sur la capture d'écran ci-dessous, plus de 900 jours sans redémarrage.

![oldserver.gif]({{ "/assets/posts/en/Debian113Server000Serverinstallationintro/fe355b596f7f4a62a30fa41cbd680401.gif" | relative_url }})

Il n'a jamais été piraté depuis son installation et a toujours rejeté les tentatives. La *seule* tentative qui ait réussi a été de
deviner le mot de passe (faible) d'une boite de messagerie et de l'utiliser pour envoyer des pourriels. J'ai pu arrêter ce
piratage en quelques minutes, grâce aux alertes et à la supervision.

## Nouvelle configuration

Cette série d'articles décrit comment installer et configurer les outils serveur de base ci-dessous, comme je le fais sur chacun
de mes serveurs. Il s'agit de ma base commune pour les serveurs, avant qu'ils ne soient spécialisés pour une tâche utile. Je
décrirai les services utiles dans la série [Services Debian 11](/pages/fr/tags/#services-debian11).

- Sécurité
  - iptables
  - portsentry
  - tripwire
  - rkhunter
  - fail2ban
  - logcheck/logwatch/fwlogwatch
  - backupmanager
- Supervision
  - Monit
  - Prometheus, Alertmanager
  - Grafana


