---
uid: NoSQLReportingIntroduction
author: fcerbell
title: Introduction aux rapports NoSQL
layout: post
lang: fr
#description:
category: Tutos
#categories
tags: nosql reporting
#date
published: true
---

Quelque soit la technologie de base de données, il y a une application métier
qui l'utilise et il y a, le plus souvent, un besoin de rapports sur les données
métier. Je vais tenter de présenter la manière de concevoir une architecture de
rapports, les concepts sont applicables à des bases de données SQL
relationnelles et aussi à des bases de données non-relationnelles NOSQL. Il
existe deux besoins de rapport différents : les rapports opérationels qui se
font sur les données vivantes (ou chaudes) pour créer des rapports opérationels
tels que des factures, des bons de commande, des inventaires, etc. et les
rapports décisionnels, avec un niveau d'abstraction plus élevé, pour donner des
tendances et pour aider les dirigeants à prendre des décisions. Dans ce premier
billet, je vais tenter d'expliquer les concepts généraux.

* TOC
{:toc}

# Rapports opérationels

Ce type de rapport est utilisé directement par l'application métier pour
délivrer des rapports sur les données chaudes. Le métier nécessite ce type de
rapport. Par exemple, si le métier est de planifier des voyages en train,
l'application métier permet de trouver des routes pour l'utilisateur en fonction
des dates et heures choisies, puis d'effectuer la réservation et de procéder au
paiement. À la fin, l'application doit émettre un ticket, ce qui constitue un
rapport opérationel. Si le métier est d'expédier des colis aux clients, alors
une étiquette d'expédition doit être imprimée en fonction de la taille, du
poids, de la destination, du transporteur préféré, du niveau de service choisi,
parfois avec un code à barres spécifique devant être lu par les lecteurs
optiques du transporteur.

Dans ce contexte, la génération des rapports est complètement intégrée dans
l'application métier et en fait partie. Le modèle de données de l'application a
été conçu pour les traitements et la générationd es tickets de train. La
génération des rapports peut être développées dans l'application, être une
bibliothèque tierce embarquée dans l'application ou encore être sous-traitée à
une application dédiée à cette tâche. Certains outils tierspeuvent être
embarqués, d'autres non, certain sont spécifiques (orientés flux ou orientés
requête).

## Données sources transmises par l'application

Quelque soit l'architecture, le code de génération des rapports doit disposer
des données source pour créer le rapport. Dans le premier cas, ces données
sources sont requêtées ou générées par l'application et transmises au code de
génération des rapports (qu'il soit propriétaire, embarqué ou externalisé). Ce
cas est plutôt simple car l'application métier connaît déjà les concepts
métiers, les objets métiers, le modèle de données utilisé dans la base de
données. Elle connaît également les données sources nécessaires à la génération
du rapport et sait comment les obtenir (que ce soit par requête ou par
algorithme).

Ainsi, l'application exécute éventuellement des requêtes sur la base de données,
à l'aide de son API habituelle, et transmet les données sources à la function de
génération des rapports, avec le modèle de rapport à utiliser et le format de
sortie souhaité.

## Données sources requêtées

Dans ce second cas, l'application métier ne transmet que peu d'informations à la
function de génération des rapports (propriétaire, embarquée ou externe), ce
sera à cette dernière d'utiliser les informations fournies pour construire le
rapport. ela signifie qu'elle devra être capable de générer les données sources
à partir des informations ou de construire et d'exécuter une requête sur la base
de données pour obtenir les données sources. Cette logique est habituellement
embarquée dans les modèles de rapports. Ils ne sont pas supposés contenir une
logique métier mais plus une logique d'accès aux données. Un modèle de
facture n'a pas besoin de connaître ce qu'est une facture, mais il doit savoir
où trouver le numéro de facture, le nom et l'adresse du client, les lignes de
produit avec leur prix, la TVA et où les placer sur le rapport.

Ce cas d'utilisation est un peu différent car la fonction de génération des
rapports doit être en mesure d'accéder aux données enregistrées dans la base.
Elle doit savoir générer des requêtes, comment les exécuter et comprendre les
jeux de résultats. Les outils orientés flux ne sont habituellement pas concernés
par ce type d'usage, en revanche, ceux orientés requête le sont.

Certains outils de génération de rapports peuvent être étendus pour apprendre à
générer des requêtes, à les exécuter et à en comprendre les résultats. La
plupart du temps, il s'agit de produits open source tels que Tibco
[JasperReports][] ou [Pentaho][]. Mais de nombreux autres outils ne peuvent pas
être étendus, ils sont généralement proposés avec un jeu de connecteurs, un
point c'est tout. La seule flexibilité de ces outils vient avec certains
connecteurs génériques, la plupart du temps un pilote ODBC[^4], un pilote
JDBC[^5], un connecteur CSV, un connecteur XLS, et un connecteur vers les
fichiers XML[^7], parfois on trouve également des connecteurs vers des services
web XML et un connecteur ODBO[^1].

Cela signifie simplement que le rapport peut utiliser une requête SQL ou XPath,
un filtre sur un fichier plat (sans jointure), une requête propriétaire sur des
fichiers XLS ou une requête MDX[^8] sur une source de données OLAP[^3], mais
rien d'autre. Lorsque la source de données est enregistrée dans n'importe quel
autre système de stockage (clé-valeur, JSON, Graphe, Colonnes, ...), cela posera
un problème. Heureusement, certaines bases de données NOSQL proposent une
interface SQL, telle que N1QL pour [Couchbase][].

# Rapports décisionnels

Dans les rapports décisionnels, l'application métier n'a pas besoin de fournir
les données sources et de demander la génération d'un rapport à partir d'un
modèle à la fonction de rapports. La plupart du temps, elle fournit une
connexion sur les données sources et laisse l'utilisateur créer ses propres
analyses. Cela signifie que la fonction de génération des rapports doit être en
mesure de se connecter à la source de données, pour exécuter des requêtes
prédéfinies ou de générer une requête AdHoc pour récupérer le résultat exact
demandé par l'utilisateur, en exploitant la technologie de stockage sous-jacente
pour lui déléguer certaines agrégation ou filtrages.

![BI Architecture][]
[Architecture décisionnelle][BI Architecture]

## Sur les données opérationelles vivantes (chaudes)

In business intelligence reporting, there is a commonly accepted architecture.
The operational live data are stored in a database, historically a relational
SQL database and the data are normalized. These are live data, online data.

## The Operational Data Store (ODS)

Then, they are pushed to an ODS (Operational Data Store) which is usually a
relational SQL database, too, with a normalized schema. It can store some
chosen historical data. The idea is to feed it enough (usually using an ETL[^9]
or ELT[^10] tool) to be able to feed the next level and to empty it. As an
example, the ODS can be fed daily, then it is used to feed the data warehouse
(DWH) and it is cleaned to begin a new month.

## The Datawarehouse (DWH)

The next level is the data warehouse (DWH), it is not supposed to have a
normalized schema, but a schema which fits to the reporting needs. Most of the
time, it is stored in a relational SQL database, with a star schema or a
snowflake schema, which are highly denormalized. The DWH is supposed to store
clean data, preaggregated data (no useless data, just in case of...), quality
data. If the reporting smaller granularity is the day, you should not find
hourly data in the DWH. There are usually two kinds of tables : facts tables to
store the actual indicators values, and the dimensions (or reference) tables to
store the possible analyzis axis.

### Dimensions 

Dimensions are the different axis to analyze the key performance indicators
(KPI). Common dimensions are a time dimension, and a geographic dimensions, but
there are a lot of other dimensions implemented in the DWH, depending on the
business (sales territory, sales market, customer segmentation, product
category, product line, economic regions, ...). We will focus on the geographic
and time dimensions as they are typical dimensions.

A dimension is made of hierarchies. Why hierarchies and not hierarchy ? Because
if there was only one hierarchy, there would be no dimension need ! Dimensions
are a concept. 

#### Hierarchies

The time dimension is the concept of time, nothing else. It does
not describe how the time is represented. Business may need to analyze the KPI
on monthes, on weeks, on seasons, on fiscal years, ... Each of them are
incompatible with the others, each one will be a different time dimension
implementation, a different hierarchy. The geographic dimension would also have
several hierarchies inside : Economic areas, countries, sales territories, ...

##### Levels

Each hierarchy is made of levels, here are some level examples for the time
dimension's hierarchies :

* Year, Half, Quarter, Month, Date
* Year, Week, Day of the week
* Year range, Season
* Fiscal year, Half, Quarter, Month (remember to not store too smaller
  granularity than needed)

In the time dimension, the date level can store extra information such as
week-end or not, holidays or not, first/last business day of the week/month or
not. The year level could also store information such as leap year or not. From
a business point of view, these extra information can be used as facets or
filters.

* Year : isLeap
* Day : isWeekDay, isHoliday, isFirstDayOfMonth, isLastDayOfMonth, ...

As the DWH is usually stored in a relational SQL database, it has a
table/relation schema. For sure, a hierarchy can be normalized with a table for
the years, a table for the halfs, and another for each levels, with a
parent-child relationship. This leads to a *snowflake* schema at the end, but as
I said previously, the DWH is not normalized, so the hierarchies can be
flattened to have only one table for each hierarchy, with one record for each
smaller granularity (the day) grouping alltogether the year, half, quarter,
month and day information. This makes the records bigger, but minimize the hops
(joins) and provide good performances with relevant indexes (at the price of
even more disk space needed).

### Facts tables

The fact tables are simpler to understand. There is one fact table to store all
preaggregated KPIs which share the same hierarchies. Each record is the KPIs
aggregation at the cross of the hierarchies. Given our example, if some KPIs are
sharing the Year/Month/Date and the Continent/Country/City hierarchy, there
would be a record for each Date/City combination. That's why useless levels and
granularities should be avoided, it leads to disk space useage and to extra
computation when asking for useful granularity aggregations, ie storing hourly
data leade to 24*NbCities more records and there will always be a computation
for the daily aggregation which is the lowest level asked by the business,
instead of saving space and having immediate static results.

Obviously, a datawarehouse can be very big as it contains a record for all the
hierarchies lowest granularity combination. With 10 KPIs only, and two
dimensions (and only one hierarchy in each) : 100 cities and a single year of
historical data, you will have 100x365=36,500 records.

## The Datamarts (DMT)

Datamarts are often called hyper-cubes. There can be several datamarts built
from a single data warehouse. They can be built and rebuilt on demand and are
often wiped/rebuild by a nightly batch, with a frequency related to the
datawarehouse refresh frequency. Each datamart contains only a consistent
subseti of the data warehouse, with one or few fact tables sharing the same
hierarchies, at the business requested granularity. A datamart is designed to
provide consistent data, which are comparables (same hierarchies), to answer to
targetted business questions as fast as possible. They are usuallu stored in a
dedicated storage engine (MOLAP), a relational storage engine with a star or
snowflake schema (ROLAP), or an hybrid storage (HOLAP) which can store
preaggregated intermediate levels. The datamarts can be seen as datasources
designed to be used in a pivot table. Some of the datamart storage provide a
dedicated query language : MDX, an SQL like query language for multi-dimensional
data, often transmitted over the network using XMLA protocol.

MDX sample :

~~~
SELECT
   { [Measures].[Store Sales] } ON COLUMNS,
   { [Date].[2002], [Date].[2003] } ON ROWS
FROM Sales
WHERE ( [Store].[USA].[CA] )
~~~

[BI Architecture]:{{site.url}}/assets/posts/NoSQLReportingIntroduction/BIArch_fr.png "Architecture décisionnelle"
[Couchbase]: http://www.couchbase.com "Couchbase website"
[JasperReports]: http://community.jaspersoft.com/project/jasperreports-library "JasperReports Library page"
[Pentaho]: https://www.pentaho.com "Pentaho website"
[^1]: ODBO (OLE[^1] DB for OLAP[^3]) is a connector type to connect to multi-dimensional data-sources
[^2]: OLE (Object Linking and Embedding) is a way to embed a copy of an object into another object or to create a link to a shared object from another object
[^3]: OLAP (OnLine Analytic Processing) : Multi-dimensional data manipulation
[^4]: ODBC (Open DataBase Connectivity) : a generic type of SQL database connector specification (Microsoft eco system)
[^5]: JDBC (Java DataBase Connectivity) : a generic type of SQL database connector specification for JAVA (cross platform)
[^6]: XMLA (XML for Analytics) : an XML specification specialized for analytics
[^7]: eXtensible Markup Language : Text based data exchange format 
[^8]: MDX (MultiDimensional eXpressions) : An SQL-like query language optimized to query multi-dimensional data-sources.
[^9]: ETL (Extract, Transform and Load) : Application that takes data from a datasource, transform them (aggregation, validation, ...) and loads them into a datasink
[^10]: ELT (Extract, Load and Transform) : Application that takes data from a datasource, inject them unchanged into a datasink and transform them (aggregation, validation, ...) using the sink manipulation tools
