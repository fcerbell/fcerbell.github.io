---
uid: ConfigureJDBCForCouchbase
author: fcerbell
title: Configurer JDBC pour Couchbase
layout: post
lang: fr
#description:
#category: Test
#categories
#tags
date: 2016-05-27
published: true
---

Nous allons voir comment télécharger, installer, configurer et utiliser le
pilote JDBC de Simba pour Couchbase. Nous testerons la connection avec
SQuirreLSQL, et le pilote sera configuré pour servir toutes les nouvelles
connexions entrantes.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la fin de cet article.

* TOC
{:toc}

# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/FH0nBiCX2cw" frameborder="0" allowfullscreen></iframe></center>

# Pré-requis

Je suppose que vous avez déjà un cluster Couchbase en état de fonctionner, même
s'il ne dispose que d'un seul nœud. Comme le pilote JDBC s'appuie sur N1QL,
vous devez disposer d'un jeu de données d'exemple, du service d'index sur un
des nœuds du cluster, du service de requêtes sur un des nœuds du cluster et
d'un index primaire.

# À propos du pilote JDBC

Couchbase ne développe pas les pilotes JDBC et ODBC. Simba est une entreprise
qui développe des pilotes ODBC/JDBC depuis longtemps. Leurs pilotes peuvent
traduire les requêtes SQL dans des langages NoSQL specifiques et peuvent
traiter par eux-même, du côté client, les fonctionnalités manquantes. Dans le
cas de Couchbase, la tâche est plus facile car Couchbase fournit une
fonctionnalité proche du SQL (N1QL), qui est très proche du standard SQL en
termes de syntaxe, de grammaire et de fonctionnalités. Plus simplement, cela
signifie que la plus grande partie d'une requête SQL pourra être poussée vers
le cluster Couchbase et que peu de fonctionnalités auront besoin d'être
traitées du côté client, diminuant ainsi la surcharge.

# Téléchargement du pilote

La toute première étape est d'aller sur le site internet de Simba, pour choisir
le pilote adhéquat, s'enregistrer pour une évaluation de 30 jours et de
télécharger le binaire. Vous recevrez un courriel avec un fichier de licence
temporaire pour activer le pilote.

Connectez vos navigateur sur la [page de description du
pilote][SimbaWebSite][^1] du site de Simba.

Ensuite, vous devrez cliquer sur le bouton *Download now (30 days free trial)*
pour choisir et ajouter le pilote pertinent à votre panier. J'ai choisi le
pilote *JAVA (JDBC)*. Simba propose un pilote pour le JDK 1.6 et un autre pour
les JDK supérieurs à 1.7 dans le même paquetage. Ensuite, cliquez sur *Proceed
to checkout* pour valider votre panier à 0$ ! ;) Il vous sera demandé de saisir
vos informations personnelles et votre addresse électronique. Puis Simba vous
enverra trois courriels :

* un message de bienvenue

* un fichier de licence :

![Simba's license file][01-SimbaLicenseEmail.png]

* un lien de téléchargement du pilote :

![Driver download link][02-SimbaDownloadEmail.png]

Je suggère de créer un nouveau dossier pour y stocker à la fois les fichiers du
pilote et celui de la licence. Ensuite, sauvegardez le fichier de licence et
téléchargez le pilote dans ce dossier.

Le pilote est téléchargé dans une archive compressée qu'il faut décompresser en
utilisant votre outil favori. Vous trouverez deux autres archives compressées à
l'intérieur qui correspondent aux deux versions du pilote. Je suggère de les
décompresser aussi. Vous devriez disposer de l'arborescence suivante :

![Driver's Folders][03-FolderStructure.png]

Vous disposez de tout ce dont vous avez besoin pour installer le pilote dans
votre application pure-SQL favorite. Toutes les informations que j'ai utilisées
pour écrire cet article sont disponibles dans la documentation PDF inclue, **je
recommende très fortement de lire la documentation PDF du pilote** car je
n'utilise qu'un sous-ensemble des fonctionnalités disponibles.

# Installation de la licence

Les pilotes JDBC de Simba recherchent le fichier de licence dans leur propre
répertoire et dans le répertoire personnel de l'utilisateur. Je déteste avoir
la pagaille à la racine de mon répertoire personnel, je suggère donc de
déployer le fichier de licence dans le répertoire du pilote. Il suffit de
copier le fichier (sans le renommer) dans les répertoires des deux versions du
pilote :

![License file installation][04-LicensefileInstallation.png]

# Installation de SQuirreLSQL

Ensuite, l'idée est d'utiliser un client pur-SQL. Il y en a tellement... J'ai
choisi d'utiliser SQuirreLSQL car il est léger et facile d'installation. Je
l'ai utilisé et l'utilise encore relativement souvent, au moins pour tester
rapidement les chaînes de connexion JAVA.

Vous pouver trouver et télécharger SQuirreLSQL pour votre plateforme sur le
[site internet de SQuireLSQL][SQuirreLSQLWebSite]. Vous obtiendrez un
installeur dans un fichier JAR. Vous devriez pouvoir l'exécuter en double
cliquand dessus depuis votre explorateur de fichiers favori ou en tapant la
ligne de commande indiquée sur la page de téléchargement depuis un
interpréteur. Vous devez disposer d'un JDK installé et fonctionnel.

# Ajout du pilote dans SQuirreLSQL

Une fois SQuirreLSQL installé, il ne reconnait pas Couchbase comme une source
de données SQL potentielle. Nous devons donc ajouter le pilote JDBC dans sa
liste de pilotes connus. Il faut ouvrir l'onglet *Drivers* (Pilotes) sur la
gauche de la fenêtre principale et cliquer sur le bouton *Add a new driver*
(Ajouter un nouveau pilote) :

![Squirrel Add a new driver button][05-SquirrelAddDriverButton.png]

Ensuite, il faut saisir un nom de pilote, je suggère *Couchbase*, un modèle de
chaîne de connexion qui aidera à en écrire une, je suggère d'en utiliser une
très simple telle que `jdbc:couchbase://localhost:8093/default`, le champs site
internet est facultatif, en revanche, il faut entrer le nom de la classe du
pilote : soit `com.simba.couchbase.jdbc4.Driver` si on utilise une version du
JDK antérieure à 1.7, sinon `com.simba.couchbase.jdbc41.Driver` si le JDK est
plus récent. Enfin, il faut utiliser le bouton *Add* de l'onglet *Extra Class
Path* pour ajouter tous les fichiers JAR présents dans le dossier correspondant
à la version souhaitée :

![Squirrel Add a new driver Dialog][06-SquirrelAddDriverDialog.png]

SQuirreLSQL connaît notre pilote et peut désormais l'utiliser pour créer une
nouvelle connexion.

# Création d'un fichier de description du schéma de la base

Couchbase est NOSQL et ne stocke pas les données dans des tables, avec une
existence physique. Les requêtes SQL fonctionnent sur des tables, nous devons
donc fournir des tables logiques ou virtuelles au pilote JDBC de manière à
exécuter des requêtes SQL. Nous devons définir une association entre les
documents JSON stockés dans Couchbase et des tables virtuelles, sans réelle
existence physique, pour exécuter des requêtes SQL. Cette définition est
appelée un schéma.

Un pilote JDBC peut être utilisé dans des développements JAVA, dans une
application JAVA, et peut présenter une API permettant de créer n tel schéma.
Mais il peut également être utilisé depuis une interface utilisateur. La
plupart des applications ne fournissent que peu de champs à passer au pilote
JDBC, ainsi Simba a choisi d'utiliser un de ces champs pour transmettre les
instructions nécessaires à la création du schéma.

Le pilote JDBC Simba tente automatiquement de créer un schéma par défaut en
analysant un sous-ensemble des documents stockés et il peut l'utiliser. Au lieu
de faire cette analyse à chaque connexion, il est plus efficace d'enregistrer
le schéma et, éventuellement, de le personnaliser.

Pour créer un fichier schéma, nous devons créer une nouvelle connexion en
utilisant une chaîne de connexion incluant des paramètres supplémentaires afin
de sauvegarder le schéma dans un fichier.

Il faut ouvrir l'onglet *Alias*, sur le côté gauche, et cliquer sur le bouton
*Ajouter un nouvel alias* :

![Squirrel Add a new alias button][07-SquirrelAddAliasButton.png]

Cela ouvre une boîte de dialogue *Add alias*. Dans SQuirreLSQL, un alias est
une définition de connexion. Nous allons définir une nouvelle connexion et
utiliser le bouton *Test* pour l'ouvrir et la refermer, c'est suffisant pour
faire créer le schéma et l'écrire sur le disque local. Nous devons lui donner
un nom, comme nous allons utiliser le bucket `beer-sample`, je suggère de la
nommer `beer-sample`, nous devons ensuite choisir le pilote à utiliser
(`Couchbase`), et éditer la chaîne de connexion (adresse IP et paramètres) :

![Generate the schema file][08-SquirrelGenerateSchema.png]

En cliquant sur le bouton *Test*, une boîte de dialogue va demander
l'identifiant et le mot de passe de connexion, car nous n'en avons pas défini
dans l'alias. Cela va ouvrir la connexion en utilisant les paramètres de
génération du schéma et l'écrire sur le disque. Le premier paramètre
(`SchemaMapOperation=1`) indique l'opération à effectuer (écrire le fichier sur
disque) et le second paramètre (`LocalSchemaFile=/tmp/beers.json`) donne le
chemin et le nom du fichier, que vous pouvez adapter à votre système. Si vous
souhaitez regarder le contenu d'un tel fichier sans effectuer les
manipulations, vous pouvez consulter [le mien][beers.json].

# Édition du schéma

Il n'y a pas besoin d'éditer le schéma dans notre cas. Le pilote JDBC utilise
un champ des documents pour les répartir dans des tables virtuelles, le champ
par défaut est `type` et, par chance, nous disposons d'un tel champ avec cette
signification. Dans les échantillons, il y a trois valeurs possibles pour ce
champ : *beer*, *brewery* et *brewery_address*. Cela signifie que le pilote
JDBC, sans plus de détails, a identifié trois tables et y a regroupé les
différents documents. Il a ensuite parcouru un sous-ensemble de documents pour
tenter de lister tous les champs possibles dans chacune de ces tables. Dans
certains cas, il peut ne pas en parcourir assez pour découvrir tous les champs
possibles de chaque type de document et il faut les ajouter manuellement dans
le schéma. Ce n'est pas utile dans notre cas. Une fois encore, tout cela est
parfaitement documenté dans le fichier PDF.

Simba provides a schema editor to edit the file. It is in the *SchemaEditor*
subfolder, under the driver version relevant to your JDK version. You can
double clic on the JAR file to start it, and choose to open your schema file.
You should have the following window. I wont describe or document how to use
it, I suggest that you open and read the associated PDF file.

![Edit the schema file][09-SchemaEditor.png]

# Upload the database schema description file

Ok, now that we have a schema file, fitting our needs, we could deploy it
everywhere with the JDBC driver and reference this local file for each
connection to our database, but Simba provides a better approach. We can deploy
the schema file in the database, and the JDBC driver will automatically
retrieve it from there at each connection. It will be easier to maintain, only
one place to update and it will work from everywhere... Lets upload it !

The idea is the same, we only have theses few JDBC fields to control the JDBC
driver, and we have o use them to tell him to upload the local schema file to
the database. So, you should still have the SQuirreLSQL alias dialog open, with
our first connection string. The local file location did not change, but the
operation is now *upload*, as per the documentation, number 2. So, you just
have to change the value from 1 to 2 and clic on the *Test* button:

![Upload the schema file][10-SquirrelUploadSchema.png]

If you noticed, there is one more document in each bucket, now, the schema.
Should you be curious, here is its key: *~~~SchemaMap*

# Open a standard JDBC SQL connection and play

Well, now, each time that the Simba JDBC driver is used somewhere to connect to
this Couchbase cluster, it will automatically retrieve the schema definition
and use it. So, we can remove all the extra API parameters from the connection
string and save the connection:

![Save the alias][11-SquirrelSaveAlias.png]

It not only save the alias, but also open a connection using it, so, you should
be connected to the cluster:

![SquirrelConnected][12-SquirrelConnected.png]

Then, you can execute SQL queries:

```sql
SELECT b.name, a.name, a.abv 
FROM beer a, brewery b 
WHERE a.brewery_id=b.PK 
```

![SquirrelQuery][13-SquirrelQuery.png]

Or view the virtual RDBMS meta data:

![SquirrelMeta][14-SquirrelMeta.png]

# Materials and Links

| Link | Description |
|---|---|
| [MainBook][mainbook], Slides([dualhead][maindeck_dualhead], [notesonly][maindeck_notesonly], [paper][maindeck_paper], [slidesonly][maindeck_slidesonly]) | Article booklet to print and associated slidedeck |
| [DemoBook][demobook], Slides([dualhead][demodeck_dualhead], [notesonly][demodeck_notesonly], [paper][demodeck_paper], [slidesonly][demodeck_slidesonly]) | Demo script booklet to print and associated slidedeck |
| [LabsBook][labsbook], Slides([dualhead][labsdeck_dualhead], [notesonly][labsdeck_notesonly], [paper][labsdeck_paper], [slidesonly][labsdeck_slidesonly]) | Hands-on scripts booklet to print and associated slidedeck |
| [ExercicesBook][exercicesbook], Slides([dualhead][exercicesdeck_dualhead], [notesonly][exercicesdeck_notesonly], [paper][exercicesdeck_paper], [slidesonly][exercicesdeck_slidesonly]) | Exercices and solutions booklet to print and associated slidedeck |
| [Video] | Demonstration screencast recording |

# Footnotes

[SQuirreLSQLWebSite]: http://squirrel-sql.sourceforge.net "Link to SQuirreLSQL's website"
[SimbaWebSite]: http://www.simba.com/drivers/couchbase-odbc-jdbc/ "Link to Simba's website"
[01-SimbaLicenseEmail.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/01-SimbaLicenseEmail.png "Simba's email with license file"
[02-SimbaDownloadEmail.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/02-SimbaDownloadEmail.png "Simba's email with download link"
[03-FolderStructure.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/03-FolderStructure.png "Driver's folder structure"
[04-LicensefileInstallation.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/04-LicensefileInstallation.png "License file installation"
[05-SquirrelAddDriverButton.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/05-SquirrelAddDriverButton.png "Add driver button"
[06-SquirrelAddDriverDialog.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/06-SquirrelAddDriverDialog.png "Add driver dialog"
[07-SquirrelAddAliasButton.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/07-SquirrelAddAliasButton.png "Add alias button"
[08-SquirrelGenerateSchema.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/08-SquirrelGenerateSchema.png "Generate the schema file"
[beers.json]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/beers.json "My beers.json file"
[09-SchemaEditor.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/09-SchemaEditor.png "Edit the schema file"
[10-SquirrelUploadSchema.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/10-SquirrelUploadSchema.png "Upload the schema file"
[11-SquirrelSaveAlias.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/11-SquirrelSaveAlias.png "Save the alias"
[12-SquirrelConnected.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/12-SquirrelConnected.png "Connected using Squirrel"
[13-SquirrelQuery.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/13-SquirrelQuery.png "Executing a SQL query from Squirrel"
[14-SquirrelMeta.png]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/14-SquirrelMeta.png "Database Metadata from Squirrel"
[mainbook]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/mainbook.pdf "Description"
[maindeck_dualhead]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/maindeck_dualhead.pdf "Description"
[maindeck_notesonly]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/maindeck_notesonly.pdf "Description"
[maindeck_paper]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/maindeck_paper.pdf "Description"
[maindeck_slidesonly]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/maindeck_slidesonly.pdf "Description"
[demobook]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/demobook.pdf "Description"
[demodeck_dualhead]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/demodeck_dualhead.pdf "Description"
[demodeck_notesonly]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/demodeck_notesonly.pdf "Description"
[demodeck_paper]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/demodeck_paper.pdf "Description"
[demodeck_slidesonly]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/demodeck_slidesonly.pdf "Description"
[labsbook]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/labsbook.pdf "Description"
[labsdeck_dualhead]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/labsdeck_dualhead.pdf "Description"
[labsdeck_notesonly]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/labsdeck_notesonly.pdf "Description"
[labsdeck_paper]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/labsdeck_paper.pdf "Description"
[labsdeck_slidesonly]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/labsdeck_slidesonly.pdf "Description"
[exercicesbook]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/exercicesbook.pdf "Description"
[exercicesdeck_dualhead]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/exercicesdeck_dualhead.pdf "Description"
[exercicesdeck_notesonly]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/exercicesdeck_notesonly.pdf "Description"
[exercicesdeck_paper]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/exercicesdeck_paper.pdf "Description"
[exercicesdeck_slidesonly]: {{site.url}}{{site.baseurl}}/assets/posts/ConfigureJDBCForCouchbase/exercicesdeck_slidesonly.pdf "Description"
[Video]: https://youtu.be/FH0nBiCX2cw "Description"
[^1]: [http://www.simba.com/drivers/couchbase-odbc-jdbc/][SimbaWebSite]
