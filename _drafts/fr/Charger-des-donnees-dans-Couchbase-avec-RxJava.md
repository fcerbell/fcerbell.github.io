---
uid: DataLoading
title: Charger des données dans Couchbase avec RxJava
author: fcerbell
layout: post
#description:
category: Tuto
#categories
tags: Java ReactiveX RxJava Couchbase Data
#date
#published: false
---

Ce petit tutoriel explique comment trouver un jeu de données intéressant (quantitativement et qualitativement) et le charger dans CouchBase pour pouvoir le manipuler ensuite.  

Télécharger des données
=======================

Il existe de nombreux sites avec des jeux de données. Mais ils sont souvent soit trop petits, soit peu intéressants d'un point de vue métier (logs, relevés de capteurs techniques, ...). Heureusement, un site regroupe plus de 1300 indicateurs du dévelopement des pays agrégés pour 215 pays, sur 50 ans. Il nous propose donc des indicateurs métiers (financiers, industriels, démographiques, sociaux, ...) selon un axe temps et un axe géographique. C'est parfait pour pouvoir s'amuser.  

Il faut commencer par aller sur le site [WorldDataBank] pour y effectuer sa selection d'indicateurs.Pour l'importation, j'ai choisi de placer en ligne les pays, en groupe les indicateurs, et en colonne les années. Ensuite, j'exporte en CSV. 

Comme il n'est pas possible de tout sélectionner pour des contraintes de volumes, j'ai du faire plusieurs selections/exportation puis j'ai concaténé les fichiers. Pour plus de facilité, vous pouvez télécharger le [Fichier complet][all.csv]. Il contient les 1300 indicateurs pour les 215 pays, de 1960 à 2014, soit environ 5 million de valeurs (en retirant les valeurs absentes).

Environnement de développement
==============================

Couchbase fournit un outil *cbdocloader* pour charger des documents au format JSON ou CSV dans Couchbase, cependant le format du CSV ne
correspond pas au schéma souhaité dans la base de document. Nous ne pouvons donc pas utiliser cet outil. Il est possible d'utiliser un ETL comme
celui de Talend pour transformer les données et les injecter dans Couchbase, mais j'ai préféré utiliser le SDK pour illustrer sa simplicité de
mise en œuvre, sa puissance et sa rapidité.

IntelliJ IDEA
-------------

Il est possible d'utiliser n'importe quel studio de développement. Personnellement j'ai une préférence pour [IntelliJ IDEA] lorsque je n'édite pas mes fichiers sous *vi*. Je le trouve plus léger, plus rapide et plus réactif qu'Eclipse.

Couchbase JAVA SDK 2.2
----------------------

Pour pouvoir communiquer avec le cluster Couchbase, il va falloir télécharger le [SDK JAVA Couchbase]. J'ai rencontré quelques soucis avec la dernière version du SDK à cause d'un bug dans la bibliothèque Jackson, j'ai donc utilisé la version 2.1.4 du SDK pour ce tutoriel.  Une fois le fichier téléchargé et décompressé, vous aurez besoin d'ajouter les trois fichiers JAR (couchbase-core-io-1.1.4.jar, couchbase-java-client-2.1.4.jar, rxjava-1.0.4.jar) dans le *classpath* de votre compilateur JAVA. Dans *IntelliJ*, il suffit de faire un copier/coller dans le projet et de les déclarer en tant que *library* d'un clic droit de la souris.


Apache Commons-CSV
------------------

Le fichier de données sources étant au format *CSV*, j'ai choisi d'utiliser la bibliothèque [Apache Commons CSV] 1.2 pour lire le fichier. Tout comme pour le SDK de Couchbase, il faut décompresser le fichier et ajouter la bibliothèque (commons-csv-1.2.jar) dans le *classpath* du compilateur JAVA (copier/coller du fichier dans le projet et déclaration comme *library* par un clic droit de la souris).

Application de chargement
=========================

Il est possible d'utiliser le SDK avec des framework comme *Spring*, il est possible (et recommandé) de faire de classes propres pour les
différents objets (Entrepot/Repository, Usine/Factory, TrucAbstrait, TrucVirtuel, TrucsPublics, TrucsPrivés...).  Mais je ne le ferai pas. Le
but de cet article est de présenter des informations simples dans un minimum de fichiers (et donc de classes). Je ne vais utiliser qu'une seule
classe en plus de mon programme, soit deux classes au total, ou deux fichiers.

Je ne vais pas rentrer dans les détails de RxJava, pour faire court, c'est un framework qui permet de demander l'exécution d'actions sur des objets au moment où ils sont disponibles. Ainsi, l'application n'attend plus inutilement qu'un objet soit disponible, elle continue son flot d'exécution et l'action s'exécutera en arrière-plan, lorsque la donnée sera là (C'est vraiment beaucoup plus que ça, mais c'est la partie qui nous intéresse pour l'instant).




Création des index
==================

Le jeu de données est chargé. Nous allons créer quelques index basiques pour pouvoir l'utiliser d'une manière générale. Pour cela, le plus simple est de se connecter sur le serveur hébergeant Couchbase et de démarrer le client en ligne de commande :

```sh
/opt/couchbase/bin/cbq
```

Le premier index correspond à un index général. Le second est l'index primaire indispensable pour utiliser le langage N1QL. Il index les clés primaires des documents. Les deux derniers index correspondent aux cas d'utilisation théorique de notre jeu de données, d'une manière générale.  *GSI* signifie * Global Secondary Index*, il s'agit d'un nouveau type d'index centralisé (par opposition aux index locaux distribués que sont les vues).

```sql
CREATE PRIMARY INDEX ON default;
CREATE PRIMARY INDEX ON WorldDevelopmentIndicators;
CREATE INDEX Year ON WorldDevelopmentIndicators(Year) USING GSI;
CREATE INDEX CountryCode ON WorldDevelopmentIndicators(CountryCode) USING GSI;
```

Voilà
=====

Nous disposons désormais d'un jeu de données à la fois riche et conséquent pour commencer à l'explorer avec un outil d'analyse ou de rapports, par exemple, mais ceci est le sujet d'un prochain article... En attendant, si cet article vous a plût, n'hésitez pas à vous abonner au [flux RSS]({{site.url}}/feed.xml) ou à le partager sur vos réseaux sociaux préférés. Vous pouvez aussi poser des questions ou donner des informations complémentaires dans les commentaires ci-dessous.

[WorldDataBank]: http://databank.worldbank.org/data/reports.aspx?source=world-development-indicators#
[all.csv]: {{site.url}}/assets/posts/DataLoading/all.csv.zip
[IntelliJ IDEA]: https://www.jetbrains.com/idea/
[SDK JAVA Couchbase]: http://developer.couchbase.com/documentation/server/4.0/sdks/java-2.2/download-links.html
[Apache Commons CSV]: https://commons.apache.org/proper/commons-csv/
