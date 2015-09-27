---
uid: CeanAndD3
title: Créer un graphique D3 avec CEAN et N1QL sur Couchbase
author: fcerbell
layout: post
description: Comment créer un graphique D3 sur Couchbase en utilisant la pile CEAN
category: tutos
tags: [cean, couchbase, D3, nodejs, express, angular, reporting, N1QL]
#published: false
---

[Couchbase], dispose d'une pile complète CEAN(Couchbase Express Angular NodeJS)
permettant de développer rapidement une application [NodeJS]. Nous allons voir
dans ce tutoriel comment initialiser le développement d'une nouvelle application
NodeJS utilisant CEAN avec Yeoman, créer un service côté serveur, un controlleur
et des vues côté client pour obtenir une représentation graphique et moderne des
données.


* TOC
{:toc}

Pré-requis
==========
Comme pour tous mes tutoriels, il y a des pré-requis nécessaires. Voici ceux
pour développer cette petite application.

Système d'exploitation
----------------------
Je suis un grand fan de Debian depuis 1999, je vais donc utiliser cette
distribution Linux pour créer mon application. Les commandes seront très
similaires sur les distributions dérivées de Debian (Ubuntu) et leurs dérivées
(Mint). Il faudra certainement les adapter pour d'autres distributions et pour
d'autres systèmes d'exploitation (*BSD, Windows, MacOS), mais l'application
NodeJS devrait rester la même.

Je vais utiliser une installation toute fraîche par défaut de Debian, uniquement
avec le jeu de paquets standard (pas d'interface graphique, pas de serveur
d'impression, pas de serveur HTTP, ...).

Couchbase Server
------------
En premier lieu, il faut bien évidemment disposer d'un cluster [Couchbase] au
minimum en version 4.0. À l'heure où j'écris ces lignes, il est disponible en
[release candidate][cb40rc0] sur le site de [Couchbase]. Ce cluster doit comporter
au moins un nœud avec le service *Index* et au moins un nœud avec le service
*Query*.

Installation de la pile CEAN de Couchbase
=========================================

Nous allons voir comment installer pas à pas la pile [CEAN] sur une distribution
GNU/Linux Debian 8 (jessie). 

```sh
sudo aptitude install -y git gcc make nodejs nodejs-legacy npm
sudo npm install -g npm
sudo npm install -g yo bower grunt grunt-cli
git clone https://github.com/dmaier-couchbase/cean.git
cd cean/src/yeoman-generators/generator-cean
sudo npm link
cd
```

Création de l'application
=========================

Pour ce tutoriel, j'utilise un petit jeu de données. Le schéma est très simple
: chaque document liste les valeurs annuelles d'un indicateur de développement
des pays entre 2006 et 2012 pour un pays et un indicateur donnés. Comme nous
accéderons aux documents pour un pays et un indicateur donné, nous allons
utiliser ces informations comme clé primaire, même si nous n'utiliserons pas
directement ces clés (nous allons faire des requêtes N1QL et non des requêtes
Clé/Valeur).

Chargement des données
----------------------

Il faut commencer par créer un petit bucket dans le cluster Couchbase et
l'appeler << WorldDataBank >>. 

Ensuite, le plus simple est de télécharger 
le [jeu de données] que j'ai préparé pour ce tutoriel.

Puis, il faut le charger dans le bucket << WorldDataBank >> du cluster
Couchbase à l'aide de l'outil de restauration `cbrestore`.

Comme nous allons utiliser *N1QL*, il faut créer au moins les index primaires.

Enfin, on peut vérifier que les données sont bien présentes et que l'on peut
exécuter des requêtes *N1QL* avec.

Initialisation de la structure de l'application
-----------------------------------------------

```sh
mkdir myapp
cd myapp/
yo cean myapp
npm install couchbase
grunt
```

Installation de d3js et nvd3
----------------------------

Ajout du graphique et des contrôles dans la vue principale
----------------------------------------------------------

Ajout d'une méthode de requêtage N1QL au service par défaut
-----------------------------------------------------------

Modification du controlleur pour appeler la requête et mettre le graphique à jour
---------------------------------------------------------------------------------

Ajout d'une route pour accéder au service
-----------------------------------------

Test du résultat
----------------

Voila
=====

[cb40rc0]: http://www.couchbase.com/preview/couchbase-server-4-0
[Couchbase]: http://www.couchbase.com
[NodeJS]: https://nodejs.org
[CEAN]: https://sites.google.com/site/cbcean/documentation
