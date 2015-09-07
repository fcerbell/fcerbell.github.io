---
uid: StartingWithCEAN
title: Créer un rapport avec CEAN et N1QL
author: fcerbell
layout: post
description: Comment créer un graphique D3 sur Couchbase en utilisant la pile CEAN
category: tutos
tags: [cean, couchbase, D3, nodejs, express, angular, reporting]
#published: false
---

[Couchbase], dispose d'une pile complète CEAN(Coucubase Express Angular NodeJS) permettant de développer rapidement une application [NodeJS]. Nous allons voir dans ce tutoriel comment créer un service côté serveur, un controlleur et des vues côté client pour obtenir une représentation graphique et moderne des données.

Pré-requis
==========
Comme pour tous mes tutoriels, il y a des pré-requis nécessaires. Voici ceux pour développer cette petite application.

Couchbase Server
------------
En premier lieu, il faut bien évidemment disposer d'un cluster [Couchbase] au minimum en version 4.0. À l'heure où j'écris ces lignes, il est disponible en [version beta][cb40beta] sur le site de [Couchbase]. Ce cluster doit comporter au moins un nœud avec le service *Index* et au moins un nœud avec le service *Query*.


La pile CEAN de Couchbase
-------------------------
Enfin, il faut disposer de la pile [CEAN]


[cb40beta]: http://www.couchbase.com/preview/couchbase-server-4-0
[Couchbase]: http://www.couchbase.com
[NodeJS]: https://nodejs.org
[CEAN]: https://sites.google.com/site/cbcean/documentation
