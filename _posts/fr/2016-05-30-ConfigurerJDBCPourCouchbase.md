---
uid: ConfigureJDBCForCouchbase
title: Configurer JDBC pour Couchbase
description:
category: Informatique
tags: [ JDBC, Couchbase ]
---

Nous allons voir comment télécharger, installer, configurer et utiliser le
pilote JDBC de Simba pour Couchbase. Nous testerons la connection avec
SQuirreLSQL, et le pilote sera configuré pour servir toutes les nouvelles
connexions entrantes.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

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

Simba fournit un éditeur de schéma pour l'ajuster à vos besoins. Il se trouve
dans le sous-répertoire `SchemaEditor`, sous le dossier relatif à votre version
du pilote pour votre JDK. Vous pouvez double-cliquer sur le fichier JAR pour le
démarrer et choisir le fichier de schéma local à ouvrir. Vous devriez obtenir
la fenêtre suivante. Je ne vais pas décrire comment l'utiliser, je suggère de
lire le fichier de documentation PDF associé.

![Edit the schema file][09-SchemaEditor.png]

# Enregistrement du fichier de schéma dans la base

Ok, maintenant que nous disposons du fichier de schéma, correspondant à notre
besoin, nous pourrions le déployer partout avec le pilote JDBC et y faire
référence pour chaque connexion à la base, mais Simba offre une meilleure
solution. Nous pouvons déployer le schéma dans la base de données et le pilote
le retrouvera automatiquement lors des connexions. Ce sera plus facile à
maintenir, un seul endroit où le mettre à jour et il sera utilisé par toutes
les connexions... Allons-y !

L'idée est la même que précédemment, nous ne disposons que de quelques champs
standard JDBC pour interragir avec le pilote JDBC et nous allons les utiliser
pour lui indiquer l'emplacement du fichier et lui demander de l'envoyer sur le
cluster. Vous devriez toujours avoir la boîte de dialogue SQuirreLSQL ouverte
sur la définition de l'alias, avec notre première chaîne de connexion.
L'emplacement du fichier n'a pas changé, mais l'opération à demander au pilote
est d'envoyer ce fichier dans la base, comme indiqué dans la documentation, le
chiffre `2`. Il suffit donc de remplacer la valeur et de cliquer sur le bouton
*Test*.

![Upload the schema file][10-SquirrelUploadSchema.png]

En regardant dans la base, Il y a désormais un document supplémentaire dans
chaque *bucket*, le schéma. Au cas où vous seriez curieux, sa clé est
`~~~SchemaMap`.

# Ouverture d'une connexion JDBC SQL standard et utilisation

Bien, à partir de maintenant, à chaque connexion utilisant le pilote JDBC vers
ce cluster, le pilote va automatiquement retrouver la définition du schéma et
l'utiliser. Nous pouvons donc retirer tous les paramêtres d'interraction avec
le pilote de la chaîne de connexion et sauvegarder l'alias :

![Save the alias][11-SquirrelSaveAlias.png]

Cela ne fait pas que sauvegarder la définiton de l'alias, mais propose de
l'utiliser pour ouvrir une nouvelle connexion, nous devrions donc être connecté
au cluster :

![SquirrelConnected][12-SquirrelConnected.png]

Nous pouvons exécuter des requêtes SQL :

```sql
SELECT b.name, a.name, a.abv 
FROM beer a, brewery b 
WHERE a.brewery_id=b.PK 
```

![SquirrelQuery][13-SquirrelQuery.png]

Ou encore consulter les meta-données de ce SGBDR virtuel :

![SquirrelMeta][14-SquirrelMeta.png]

# Supports et liens

| Lien | Description |
|---|---|
| [Video] | Enregistrement vidéo de la démonstration |

# Notes de bas de page

[SQuirreLSQLWebSite]: http://squirrel-sql.sourceforge.net "Link to SQuirreLSQL's website"
[SimbaWebSite]: https://www.magnitude.com/drivers/couchbase-odbc-jdbc "Link to Simba's website"
[01-SimbaLicenseEmail.png]: {{ "/assets/posts/" | append: page.uid | append:"/01-SimbaLicenseEmail.png" | relative_url }} "Simba's email with license file"
[02-SimbaDownloadEmail.png]: {{ "/assets/posts/" | append: page.uid | append:"/02-SimbaDownloadEmail.png" | relative_url }} "Simba's email with download link"
[03-FolderStructure.png]: {{ "/assets/posts/" | append: page.uid | append:"/03-FolderStructure.png" | relative_url }} "Driver's folder structure"
[04-LicensefileInstallation.png]: {{ "/assets/posts/" | append: page.uid | append:"/04-LicensefileInstallation.png" | relative_url }} "License file installation"
[05-SquirrelAddDriverButton.png]: {{ "/assets/posts/" | append: page.uid | append:"/05-SquirrelAddDriverButton.png" | relative_url }} "Add driver button"
[06-SquirrelAddDriverDialog.png]: {{ "/assets/posts/" | append: page.uid | append:"/06-SquirrelAddDriverDialog.png" | relative_url }} "Add driver dialog"
[07-SquirrelAddAliasButton.png]: {{ "/assets/posts/" | append: page.uid | append:"/07-SquirrelAddAliasButton.png" | relative_url }} "Add alias button"
[08-SquirrelGenerateSchema.png]: {{ "/assets/posts/" | append: page.uid | append:"/08-SquirrelGenerateSchema.png" | relative_url }} "Generate the schema file"
[beers.json]: {{ "/assets/posts/" | append: page.uid | append:"/beers.json" | relative_url }} "My beers.json file"
[09-SchemaEditor.png]: {{ "/assets/posts/" | append: page.uid | append:"/09-SchemaEditor.png" | relative_url }} "Edit the schema file"
[10-SquirrelUploadSchema.png]: {{ "/assets/posts/" | append: page.uid | append:"/10-SquirrelUploadSchema.png" | relative_url }} "Upload the schema file"
[11-SquirrelSaveAlias.png]: {{ "/assets/posts/" | append: page.uid | append:"/11-SquirrelSaveAlias.png" | relative_url }} "Save the alias"
[12-SquirrelConnected.png]: {{ "/assets/posts/" | append: page.uid | append:"/12-SquirrelConnected.png" | relative_url }} "Connected using Squirrel"
[13-SquirrelQuery.png]: {{ "/assets/posts/" | append: page.uid | append:"/13-SquirrelQuery.png" | relative_url }} "Executing a SQL query from Squirrel"
[14-SquirrelMeta.png]: {{ "/assets/posts/" | append: page.uid | append:"/14-SquirrelMeta.png" | relative_url }} "Database Metadata from Squirrel"
[^1]: [https://www.magnitude.com/drivers/couchbase-odbc-jdbc][SimbaWebSite]
[Video]: https://youtu.be/FH0nBiCX2cw "Enregistrement vidéo de la démonstration"
