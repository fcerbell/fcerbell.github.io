---
uid: NoSQLReportingWithCouchbase
author: fcerbell
title: NoSQL reporting with Couchbase
layout: post
lang: en
#description:
#category: Test
#categories
#tags
#date
published: true
---

Abstract

* TOC
{:toc}

# Operational reporting on live/online data

# Couchbase as an ODS

# Couchbase as a DWH

# Couchbase as a DMT with views


---

Concernant la possibilité de connecter des outils décisionnels à Couchbase. Il faut commencer par prendre en compte que Couchbase est utilisée comme base de données opérationnelle. Une architecture décisionnelle typique comporte théoriquement une base de type ODS (Operational Data Store) avec un schéma opérationnel, un Datawarehouse (DWH) ayant un schéma démoralisé plutôt en étoile ou en flocon et comportant des données nettoyées, validée et potentiellement pré-agrégées, et des Datamarts (DMT) avec des données agrégées dans un schéma en étoile ou flocon (pour faire du ROLAP) ou un stockage spécialisé (pour du HOLAP ou du MOLAP), le tout lié par des traitements Extract-Transform-Load (ETL) ou Extract-Load-Transform (ELT) et de validation/redressement des données. Il est cependant toujours possible de connecter un outil d’analyse décisionnelle à une base opérationnelle en ayant conscience des impacts en terme de dimensionnement de l’infrastructure et de qualité des données.

Dans ce contexte, la plupart des outils décisionnels (Qlikview, Tableau, BO, Pentaho, Jaspersoft) ne savent pas toujours dialoguer avec une base de données non-relationnelle et NoSQL. Ils utilisent principalement le SQL ou le MDX pour interroger les données. Certains outils (comme Pentaho et Jaspersoft) peuvent être étendus pour utiliser d’autres langages de requête. Un accès purement clé/valeur n’est pas toujours suffisant pour créer des rapports décisionnels sur des documents opérationnels non-modélisés dans un but décisionnel. Il est donc possible d’étendre ces outils pour leur permettre d’utiliser un accès clé/valeur, à condition d’avoir par ailleurs des traitements construisant des documents agrégés. Il est également possible d’étendre ces mêmes outils pour leur permettre d’exploiter les vues (MapReduce) de Couchbase et ainsi de bénéficier d’agrégations partiellement précalculées et distribuées, particulièrement les vues multi-dimensionnelles qui peuvent s’apparenter à un stockage OLAP. Mais surtout, Couchbase a l’avantage d’être une base de données NOSQL (dans le sens Not Only SQL) et de pouvoir interpréter des requêtes SQL grâce à ses pilotes ODBC et JDBC. Cela signifie qu’il est possible de connecter tout outil décisionnel en mesure d’utiliser une connection ODBC ou JDBC en lui fournissant une requête comme source de données. Dès lors, il devient possible d’exprimer des requêtes en SQL sur les documents opérationnels, et de les utiliser directement comme sources de données depuis les outils décisionnels.


* H1 : # Header 1
* H2 : ## Header 2
* H3 : ### Header 3
* H4 : #### Header 4
* H5 : ##### Header 5
* H6 : ###### Header 6
* Links : [Label](URL 'title')
* Links : [Label][linkid]
* Bold : **Bold**
* Italicize : *Italics*
* Strike-through : ~~text~~
* Highlight : ==text==
* Paragraphs : Line space between paragraphs
* Line break : Add two spaces to the end of the line
* Lists : * an asterisk for every new list item.
* Quotes : > Quote
* Inline Code : `alert('Hello World');`
* Horizontal Rule (HR) : --------
* Footnote[^1]

[linkid]: http://www.example.com/ "Optional Title"

[^1]: This is my first footnote

