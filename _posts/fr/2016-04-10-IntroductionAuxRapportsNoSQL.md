---
uid: NoSQLReportingIntroduction
author: fcerbell
title: Introduction aux rapports NoSQL
layout: post
lang: fr
#description:
category: Tutos
tags: [ NoSQL, Reporting ]
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

On retrouve souvent le terme anglo-saxon Business Intelligence (BI[^15]) lorsque
l'on parle de décisionnel.  Dans les rapports décisionnels, l'application métier
n'a pas besoin de fournir les données sources et de demander la génération d'un
rapport à partir d'un modèle à la fonction de rapports. La plupart du temps,
elle fournit une connexion sur les données sources et laisse l'utilisateur créer
ses propres analyses. Cela signifie que la fonction de génération des rapports
doit être en mesure de se connecter à la source de données, pour exécuter des
requêtes prédéfinies ou de générer une requête AdHoc pour récupérer le résultat
exact demandé par l'utilisateur, en exploitant la technologie de stockage
sous-jacente pour lui déléguer certaines agrégation ou filtrages.

![BI Architecture][]
[Architecture décisionnelle][BI Architecture]

## Sur les données opérationelles vivantes (chaudes)

Pour les rapports décisionnels, il y a une architecture generalement admise. Les
données opérationelles vivantes sont stockées dans des bases de données,
historiquement des bases SQL et les données sont normalisées. Ces données sont
communément appelées chaudes, vivantes ou encore en-ligne.

## Le puit de données (Operational Data Store, ODS[^11])

Elles sont ensuite poussées vers un ODS (Operational Data Store), qui est
habituellement dans une base de données relationnelle SQL, également, avec un
schéma normalisé. Il peut stocker un historique pour certaines données choisies.
L'idée est de le remplir assez (généralement à l'aide d'un outil ETL[^9] ou
ELT[^10]) pour être en mesure d'alimenter leniveau suivant avant de le purger.
Par exemple, l'ODS peut être alimenté quotidiennement puis ses données sont
utilisées pour alimenter l'entrepôt (data warehouse, DWH) et il est purgé pour
le cycle suivant.

## L'entrepôt (Data warehouse, DWH[^12])

Le niveau suivant est l'entrepôt de données (ou data warehouse, DWH, en
anglais), il n'est pas supposé avoir un schéma normalisé, mais un schéma qui
correspond aux besoins des rapports. La plupart du temps, il est stocké dans une
base de données relationnelle SQL, avec un schéma en étoile ou en flocon,
fortement dénormalisés. L'entrepôt est supposé contenir des données propres et
validées, préagrégées (pas de données inutiles, au cas où...). Si la granularité
la plus fine des rapports est la journée, vous ne devriez pas trouver de données
horaires dans l'entrepôt. Il contient habituellement deux types de tables : les
tables de faits pour stocker les valeurs des indicateurs et les tables de
dimension (ou référence), pour stocker les axes possibles d'analyse.

### Dimensions 

Les dimensions sont les différents axes selon lesquels analyser les indicateurs
(Key Performance Indicators, KPI[^14]). Les dimensions habituelles sont la
dimension temporelle et la dimension géographique mais il y en a de nombreuses
autres dimensions implémentées dans l'entrepôt, en fonction des besoins métiers
(territoire commercial, marché économique, segmentation des clients, catégories
des produits, lignes de produit, régions économiques, ...). Nous allons nous
concentrer sur les dimensions temporelles et géographiques, qui sont des
dimensions typiques dans le décisionnel.

Une dimension est constituée de hiérarchies. Pourquoi des hiérarchies et non pas
une hiérarchie ? Car s'il n'y en avait qu'une seule, il n'y aurait pas besoin
des dimensions ! Les dimensions sont des concepts, les hiérarchies sont leurs
implémentation possibles.

#### Hiérarchies

La dimension temporelle correspond au concept de temps, rien d'autre. Elle ne
décrit absolument pas la manière de l'implémenter. Le métier peut avoir besoin
d'analyser les indicateurs par mois, par semaine, par saison, par année
fiscale, ... Chacun étant incompatible avec les autres, chacun sera une
implémentation différente de la dimension temporelle, une hiérarchie différente.
La dimension géographique disposera également de plusieurs hiérarchies : régions
économiques, régions géo-politiques, administratives, territoires commerciaux,
...

##### Niveaux

Chaque hiérarchie est faite de niveaux, voici quelques exemples pour les
hiérarchies de la dimension temporelle :

* Année, Semestre, Trimestre, Mois, Date
* Année, Semaine, Jour de la semaine
* Plage d'années, Saison
* Année fiscale, Semestre, Trimestre, Mois (n'oubliez pas qu'il ne faut pas
* stocker une granularité plus fine que nécessaire)

Dans la dimension temporelle, le niveau *Date* peut porter des informations
supplémentaires telles que travaillé ou pas, vacance ou pas, premier/dernier
jour travaillé du mois/de la semaine... Le niveau *Année* peut porter aussi des
informations comme bissextile ou non. D'un point de vue métier, ces informations
peuvent être utilisées par des filtres ou en tant que facettes.

* Année : Bissextile
* Date : Travaillé, Férié, Vacances, PremierJourDuMois, DernierJourDuMois, ...

Comme l'entrepôt est habituellement stocké dans une base de données relationnelle
SQL, il dispose d'un schéma table/relation. Évidemment, une hiérarchie peut être
normalisée avec une table pour les années, une pour les semestres, etc. avec des
relations parent/enfant. Cela mène à un schéma dit en *flocon* mais, comme je
l'ai indiqué précédement, un entrepôt n'a pas un schéma normalisé, les
hiérarchies peuvent être applatiespour aboutir à une seule table par hiérarchie,
avec un enregistrement pour chaque niveau de plus fine granularité (Date),
regroupant (en les dupliquant) les autres niveaux (année, semestre, ...). Cela
rend les enregistrement plus volumineux et duplique les données, mais minimize
les sauts (jointures) et apporte de meilleures performances avec des index
appropriés (au prix d'encore plus d'espace disque).

### Les faits

Les tables de fait sont plus faciles à appréhender. Il y a une table de fait
pour stocker les indicateurs préaggrégés partageant les même hierarchies. Chaque
enregistrement porte les indicateurs situés au croisement des hiérarchies. Selon
notre exemple, si certains KPI partagent la hiérarchie Année/Mois/Jour et la
hiérarchie Continent/Pays/Ville, il y aura éventuellement des enregistrements
dans la table de fait liée à ces deux hiérarchies. Si aucune valeur de KPI
n'existe pour une combinaison Date/Ville, il n'y aura pas d'enregistrement.
C'est pourquoi les granularités de hiérarchie trop fines par rapport au besoin
doivent être évitées, elles entraînent une augmentation inutile de l'espace de
stockage nécessaire et des calculs d'agrégation même pour les plus faibles
granularités demandées par le métier. Si on stocke une granularity horaire, cela
signifie 24 enregistrements de plus par ville et, comme la granularité la plus
fine nécessaire aux métiers est la journée, il y aura toujours besoin
d'effectuer une agrégation même pour cette granularité la plus fine demandée par
les métiers au lieu de la servir depuis une valeur précalculée.

Il est fréquent d'avoir des trous dans les tables de faits, il n'y a pas
obligatoirement d'agrégation pour toutes les combinaisons de niveau
hiérarchique. Une ville peut exister dans les tables de références mais ne pas
avoir de clients, toutes les dates de l'année peuvent (et souvent doivent)
exister dans les hiérarchies temporelles même s'il n'y a pas eu de vente à cette
date : il n'y a peut-être pas eu de vente à une date spécifique pour une ville
spécifique et il n'y aura pas d'enregistrement de fait. Si on considère
l'entrepôt comme un hyper-cube, il est très souvent rempli de ... trous.

De toute évidence, un entrepôt peut devenir très volumineux car il est
susceptible de contenir un enregistrement pour toutes les combinaisons de plus
fine granularité de ses hiérarchies. Par exemple, soient 10 indicateurs
seulement et deux dimensions ne comportant qu'une seule hiérarchie chacune : 
100 viles et une année de données entraînent 36 000 enregistrements.

## Les hyper-cubes (Datamarts, DMT[^13])

Les hyper-cubes sont appelés datamarts en Anglais. Il est possible d'avoir
plusieurs hyper-cube construits à partir d'un seul entrepôt. Ils peuvent être
construits et reconstruits à la demande et sont souvent vidés puis repeuplés par
des traitements nocturnes à une fréquence correspondant au rafraîchissement de
l'entrepôt. Chaque hyper-cube contient uniquement un sous-ensemble cohérent de
l'entrepôt, avec une ou quelques tables de fait partageant les même hiérarchies
et devant être croisées pour répondre aux besoins du métier et à la granularité
souhaitée. Il est possible de préagréger les indicateurs à une granularité moins
fine dans les hyper-cubes que dans l'entrepôt, si l'utilisateur souhaite zoomer
plus fin, l'outil d'analyse fera un *drill-through* et utilisera les données de
l'entrepôt pour completer celles de l'hyper-cube. Un hyper-cube est concç pour
fournir des données cohérentes, compatibles entre-elles (même hiérarchies), pour
répondre à des interrogations ciblées des métiers aussi rapidement que possible.
Ils sont habituellement stockés dans des moteurs spécialisés (MOLAP[^16]), des
moteurs relationnels SQL (ROLAP[^17]) ou des moteurs hybrides (HOLAP[^18])
pouvant enregistrer des préagrégats à plusieurs niveaux. Les moteurs de stockage
d'hyper-cubes peuvent être considérés comme dessources de données pour les
tableaux à double entrées (connus sous le nom de tableaux croisés dynamiques).
Certains moteurs de stockage proposent un langage de requête spécifique : MDX,
proche du SQL, spécialisé pour les requêtes multi-dimensionnelles, ces requêtes
sont souvent transportées grâce au protocole XMLA.

Exemple de requête MDX :

~~~
SELECT
   { [Measures].[Store Sales] } ON COLUMNS,
   { [Date].[2002], [Date].[2003] } ON ROWS
FROM Sales
WHERE ( [Store].[USA].[CA] )
~~~

[BI Architecture]:{{site.url}}{{site.baseurl}}/assets/posts/NoSQLReportingIntroduction/BIArch_fr.png "Architecture décisionnelle"
[Couchbase]: http://www.couchbase.com "Site internet de Couchbase"
[JasperReports]: http://community.jaspersoft.com/project/jasperreports-library "Page internet de JasperReports"
[Pentaho]: https://www.pentaho.com "Site internet de Pentaho"
[^1]: ODBO (OLE DB for OLAP) est un connecteur pour accéder à des sources de données multi-dimensionnelles
[^2]: OLE (Object Linking and Embedding) est un moyen d'embarquer une copie d'un objet dans un autre objet ou de créer un lien vers un autre objet partagé.
[^3]: OLAP (OnLine Analytic Processing) : Manipulation de données multi-dimensionnelles
[^4]: ODBC (Open DataBase Connectivity) : un type de connecteur générique vers des bases de données SQL (dans le monde Microsoft)
[^5]: JDBC (Java DataBase Connectivity) : un type de connecteur générique vers des bases de données SQL (dans le monde JAVA)
[^6]: XMLA (XML for Analytics) : une spécification XML spécialisée pour les analyses
[^7]: eXtensible Markup Language : Format d'échange de données texte.
[^8]: MDX (MultiDimensional eXpressions) : un langage proche de SQL spécialisé pour les sources de données et les requêtes multi-dimensionnelles
[^9]: ETL (Extract, Transform and Load) : Application prenant des données depuis une source, les transformant (agrégation, validation, ...) et les chargeant dans un autre stockage.
[^10]: ELT (Extract, Load and Transform) : Application prenant des données depuis une source, les injectant sans modification dans un autre stockage et les transformant (agrégation, validation, ...) sur place à l'aide des fonctionnalités du stockage cible.
[^11]: ODS (Operational Data Store), emplacement de stockage temporaire des données opérationnelles avant leur pré-agrégation.
[^12]: DWH (Data WareHouse), zone de stockage persistent pour enregistrer l'historique des agrégation dans un format dénormalisé.
[^13]: DMT (DataMart), zone de stockage persistent mais éphémère pour mettre à disposition les hyper-cubes multi-dimensionnels à des fins d'analyses.
[^14]: KPI (Key Performance Indicator), Indicateur
[^15]: BI (Business Intelligence), terme Anglo-saxon pour décisionnel
[^16]: MOLAP (Multidimensional OLAP), moteur de stockage OLAP spécialisé
[^17]: ROLAP (Relational OLAP), moteur de stockage OLAP sur une base relationnelle
[^18]: HOLAP (Hybrid OLAP), moteur de stockage OLAP hybrid pouvant stocker des agrégats à plusieurs niveaux
