---
uid: ConnecterJasperACouchbase
title: JDBC connection from JasperReports Server to Couchbase
author: fcerbell
layout: post
description:
category: tutos
tags: [couchbase, jaspersoft, reporting, jdbc, n1ql]
#published: false
---

[Couchbase], a NOSQL BigData database, now offers a new language, N1QL, to write queries. This article will show you how to use the new [Couchbase] JDBC driver in [JasperReports Server][jrs] (I will use tje JRS acronym from now), in order to execute SQL queries on the [Couchbase] database.

Prerequisites
=============
As for any tutorial, there are needed prerequisites. Here are them for this tuto.

Couchbase Server
----------------
First, you need a [Couchbase] cluster v4.0 or later. As I am writing this text, there is a [beta version][cb40beta] available on [Couchbase]'s website. This cluster needs to have at least one node with the *Index* service and one node with the *Query* service.

JasperReports Server
--------------------
Then, you will need a working JRS. The easiest is to download the evaluation version. It has all the commercial features and enables you to test the server for one month from the installation date. This evaluation edition embeds an application server (Tomcat) and a database server (PostgreSQL). So, by accepting all the default choices, the server will be installed with all its prerequisites.

Couchbase JDBC driver
---------------------
Finally, you need the JDBC driver provided by [Couchbase]. It is currently not publicly available but you can ask Couchbase for it.

Folder structure creation
=========================
We will start by creating a folder structure to place the different elements of this tutorial following the best practices. This part is not mandatory to add Couchbase's JDBC driver and to create a data source, nevertheless it is better and will be assumed to be executed in other tutorials.

First, we have to login into JRS as *jasperadmin* with the default password *jasperadmin* (Best practices **strongly** discourage to connect as *superuser*, this account is designed to administrate the JRS instance, at the instance level). *jasperadmin* is an accound with the administrator role. It is automatically created when an organization is created. In our case, with an evaluation installation, it exists and we will use it to add the data source and make it available to the other users. By default, *jasperadmin* can read and write everywhere whereas *joeuser* (the default simple user automatically created) can only write in a single repertoire.

When a user connects to JRS, he goes to his organization's repository. The repository is like a shared folder, with sub-folders and objects. It is possible to give (or not) permissions on the folders and objects, to named users or to roles (groups).

We have to open the repository, by opening the *View* menu and selecting *Repository* item :

![Menu Afficher/Référentiel]({{site.url}}/assets/posts/ConnecterJasperACouchbase/JRS_fr-01.png)

A JRS instance can be available in SaaS. It means that it can accept connections from *John Doe*/*BeautifulFlowers* and from *John Doe*/*Flowers for everyone*, each of them will only be able to see his company's data through his company's report templates (or shared templates), in a customized user interface (colors, logo, layout, ...). So, there are private locations for each company (organization) and common shared locations. In the tutorial, we will place the data source in the common area so that every organization will be able to use it. We will begin by creating a project folder in this place : */Public/WorldDevelopment*. Right clic on the */Public* folder to create a new sub-folder :

![Menu Nouveau/Dossier]({{site.url}}/assets/posts/ConnecterJasperACouchbase/JRS_fr-02.png)

Enter the folder's name *WorldDevelopment* :

![Création du dossier du projet]({{site.url}}/assets/posts/ConnecterJasperACouchbase/JRS_fr-03.png)


Parmi les éléments que nous allons créer, il y a des éléments techniques (les sources de données, les requêtes, les logos, les invites, ...) et les éléments métier (modèles de rapports, rapports, affichages à la demande, tableaux de bord, ...). Les éléments métier dépendent des éléments techniques pour pouvoir fonctionner. En revanche, autant l'utilisateur métier final souhaite voir les éléments métiers, autant il n'est pas intéressé par leurs dépendances techniques. Il est donc utile de les rendre utilisables par l'utilisateur final, sans lui laisser les voir pour ne pas polluer son interface. Nous allons donc créer un sous-répertoire technique dans lequel nous rangerons tous les éléments pour lesquels l'utilisateur final doit avoir les permissions d'utilisation, sans les permissions de listage : */Public/WorldDevelopment/Resources*.

![Création du dossier des ressources techniques]({{site.url}}/assets/posts/ConnecterJasperACouchbase/JRS_fr-04.png)

Nous allons continuer à suivre les bonnes pratiques. Il n'est pas question de mettre en vrac tous les objets techniques, nous allons donc les ranger dans des sous-répertoires techniques. Dans ce tutoriel, nous voyons comment créer une source de données, nous allons donc ranger cette source de données avec toutes les autres sources de données du projet *WorldDevelopment* dans un sous-répertoire : */Public/WorldDevelopment/Resources/DataSources*.

![Création du dossier des sources de données]({{site.url}}/assets/posts/ConnecterJasperACouchbase/JRS_fr-05.png)

Nous allons donc utiliser le sous-répertoire *Resources* pour ranger tous les éléments techniques pour lesquels les utilisateurs auront les permissions d'utilisation sans pour autant avoir les permissions d'affichage. Pour cela, nous allons changer les permissions sur le dossier *Resources*. Il faut faire un clic droit sur le dossier Resources et choisir *Autorisations* :

![Menu contextuel des autorisations]({{site.url}}/assets/posts/ConnecterJasperACouchbase/JRS_fr-06.png)

Donnons la permission *Exécuter seulement* au rôle *ROLE_USER* et refermons la boîte de dialogue :

![Permissions sur les ressources techniques]({{site.url}}/assets/posts/ConnecterJasperACouchbase/JRS_fr-07.png)

Nous disposons maintenant d'une structure de répertoires commune à toutes les organisations (il n'y en a qu'une seule par défaut à l'installation) et dont les éléments techniques seront cachés aux utilisateurs métiers.

Ajouter le pilote JDBC dans le classpath
========================================

Par défaut, JRS ne fournit pas le pilote JDBC pour Couchbase. Il faut donc ajouter le pilote dans le classpath de la JVM exécutant JRS. Ayant installé JRS avec l'installeur d'évaluation, Apache Tomcat a été installé et configuré pour exécuter JRS. Il se trouve dans le sous-répertoire *apache-tomcat* du répertoire d'installation. L'application JRS se trouve dans le sous-répertoire *apache-tomcat/webapps/jasperserver-pro*. Il est donc possible d'ajouter le pilote au niveau du serveur de conteneur JAVA (Tomcat), dans le sous-répertoire *apache-tomcat/lib* ou au niveau de l'application dans le sous-répertoire *apache-tomcat/webapps/jasperserver-pro/WEB-INF/lib*. J'ai fait le choix de l'installer au niveau du serveur de conteneur.

Il faut donc copier tous les fichiers du pilote JDBC (sauf éventuellement le fichier PDF), dans le sous-répertoire des bibliothèques partagées de Tomcat :

```bash
cp SimbaCouchbaseJDBC41_Beta_Update3/*.{jar,lic} /opt/jasperreports-server-6.1.0/apache-tomcat/lib/
```

Une fois les fichiers du pilote installés, nous pourrions nous connecter à l'interface WEB en tant que *superuser* et définir manuellement notre connection, cependant il existe une solution plus élégante : nous allons indiquer à JRS que nous disposons d'un nouveau pilote et comment l'utiliser, cela permet de mieux l'intégrer dans l'interface de JRS et de documenter la création d'une nouvelle source de données par un simple administrateur. Il va falloir ajouter la section suivante décrivant le pilote dans le fichier de configuration */opt/jasperreports-server-6.1.0/apache-tomcat/webapps/jasperserver-pro/WEB-INF/applicationContext-webapp.xml*, dans la section *jdbcBasicConnectionMap* (ligne 64) :

```xml
<entry key="couchbase">
    <util:map>
        <entry key="label" value="Couchbase"/>
        <entry key="jdbcUrl" value="jdbc:couchbase://$[dbHost]:$[dbPort]/$[dbName];UseN1QLMode=1"/>
        <entry key="jdbcDriverClass" value="com.simba.couchbase.jdbc41.Driver"/>
        <entry key="defaultValues">
            <util:map>
                <entry key="dbHost" value="localhost"/>
                <entry key="dbPort" value="8093"/>
                <entry key="dbName" value="default"/>
            </util:map>
        </entry>
    </util:map>
</entry>
```

Puis, il faut redémarrer Tomcat. Bien qu'il soit possible de redémarrer uniquement Tomcat, nous allons utiliser le script global qui va redémarrer à la fois Tomcat et PostgreSQL dans le cas d'une installation d'évaluation :

```
cd jasperreports-server-6.1.0
./ctlscript.sh restart
```

Le pilote est désormais disponible dans JRS.

Créer la source de données JDBC
===============================

Nous pouvons maintenant créer la source de données JDBC utilisant le pilote Couchbase pour permettre à JRS de se connecter à Couchbase et d'exécuter des **requêtes SQL sur cette base NOSQL**.

Il faut commencer par se reconnecter à JRS en tant que *jasperadmin* avec le mot de passe *jasperadmin*. Puis, il faut aller dans le répertoire */Public/WorldDevelopment/Resources/DataSources*, faire un clic droit et choisir *Nouveau/Source de données* :

![Menu Ajouter une source de données]({{site.url}}/assets/posts/ConnecterJasperACouchbase/JRS_fr-08.png)

Sélectionner *Source de données JDBC*, puis choisir *Couchbase*. Grâce à la modification des fichiers de configuration que nous avons effectuée plus tôt, le pilote est connu de JRS et il nous suffit de le choisir. JRS connaît déjà le nom de la classe JAVA à charger et les valeurs par défaut pour les différents champs. Il suffit just de remplacer *localhost* dans l'URL de connexion pour indiquer un des nœeuds du cluster Couchbase et de valider les informations en cliquant sur le bouton *Test* :

![Propriétés de la source de données]({{site.url}}/assets/posts/ConnecterJasperACouchbase/JRS_fr-09.png)

La dernière étape consiste à choisir un nom pour cette nouvelle source de données, j'ai choisi de l'appeler *Couchbase_DS* :

![Enregistrer la source de données]({{site.url}}/assets/posts/ConnecterJasperACouchbase/JRS_fr-10.png)

Voila
=====

Vous disposez désormais d'une connexion JDBC vers votre cluster Couchbase. Vous pouvez l'utiliser pour exécuter des requêtes N1QL (SQL) sur le cluster Couchbase. Il faut évidemment que vous disposiez d'un *bucket* avec des documents, ainsi que des index primaires et secondaires. Mais nous verrons cela lors d'un prochain article.


[cb40beta]: http://www.couchbase.com/preview/couchbase-server-4-0
[Couchbase]: http://www.couchbase.com
[jrs]: http://community.jaspersoft.com/project/jasperreports-server
