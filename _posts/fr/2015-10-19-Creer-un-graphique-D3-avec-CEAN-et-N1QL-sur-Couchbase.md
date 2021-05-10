---
uid: CeanAndD3
title: Créer un graphique D3 avec CEAN et N1QL sur Couchbase
description: Comment créer un graphique D3 sur Couchbase en utilisant la pile CEAN
category: Tutos
tags: [ CEAN, Couchbase, D3, NodeJS, ExpressJS, AngularJS, Reporting, N1QL]
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
d'autres systèmes d'exploitation (BSD, Windows, MacOS), mais l'application
NodeJS devrait rester la même.

Je vais utiliser une installation toute fraîche par défaut de Debian, uniquement
avec le jeu de paquets standard (pas d'interface graphique, pas de serveur
d'impression, pas de serveur HTTP, ...).

Couchbase Server
------------
En premier lieu, il faut bien évidemment disposer d'un cluster [Couchbase] au
minimum en version 4.0. Il est disponible en [téléchargement] sur le site
de [Couchbase].  Ce cluster doit comporter au moins un nœud avec le service
*Index* et au moins un nœud avec le service *Query*.

Installation de la pile CEAN de Couchbase
=========================================

Nous allons voir comment installer pas à pas la pile [CEAN] sur une distribution
GNU/Linux Debian 8 (jessie). Pour cela, nous allons suivre les instructions du site
officiel.

J'installe les dépendances pour l'installation ainsi que NodeJS :

```sh
sudo aptitude install -y git gcc make nodejs nodejs-legacy npm
```

Je m'assure d'avoir la dernière version de `npm` disponible pour éviter les
erreurs et avertissements lors de l'installation des autres dépendances :

```sh
sudo npm install -g npm
```

J'utilise ensuite *NodeJS Package Manager* pour installer *yeoman*. Le générateur
CEAN pour *yeoman* aura besoin de *bower* pour installer les dépendances de ma
future application. Bien que *grunt* soit facultatif, il facilitera le développement
de mon application, j'installe donc tout ça :

```sh
sudo npm install -g yo bower grunt grunt-cli
```

J'installe ensuite le générateur CEAN pour *yeoman* et le rends disponible :

```sh
git clone https://github.com/dmaier-couchbase/cean.git
cd cean/src/yeoman-generators/generator-cean
sudo npm link
cd
```

Voilà, toutes les dépendances sont satisfaites pour pouvoir générer le squelette
d'une application utilisant la pile [CEAN].

Création de l'application
=========================

Pour ce tutoriel, j'utilise un petit jeu de données. Le schéma est très simple :
chaque document liste les valeurs annuelles d'un indicateur de développement des
pays entre 2006 et 2012 pour un pays et un indicateur donnés. Comme nous
accéderons aux documents pour un pays et un indicateur donné, nous allons
utiliser ces informations comme clé primaire, même si nous n'utiliserons pas
directement ces clés (nous allons faire des requêtes N1QL et non des requêtes
Clé/Valeur).

Chargement des données
----------------------

Il faut commencer par créer un petit bucket dans le cluster Couchbase et
l'appeler << WorldDataBank >>. Je ne vais pas décrire dans le détail comment
créer un nouveau bucket. Il suffit de se connecter à l'interface
d'administration du cluster Couchbase à l'aide d'un navigateur et d'un compte
administrateur, puis d'aller dans l'onglet << Buckets >>, de cliquer sur le
bouton << New bucket >>. Il est inutile de donner plus de 100 Mo de mémoire à ce
bucket.

Ensuite, le plus simple est de télécharger le [jeu de données] que j'ai préparé
pour ce tutoriel, et de décompresser l'archive compressée :

```sh
unzip WorldDataBank.dump.zip
```

Il faut transférer le répertoire obtenu sur un ordinateur disposant des outils
de restauration de *Couchbase* :

```sh
scp -r WorldDataBank.dump utilisateur@nom_d_un_noeud_du_cluster:
```

et se connecter à cet ordinateur en ligne de commande :

```sh
ssh utilisateur@nom_du_noeud_du_cluster
```

Puis, il faut le charger dans le bucket << WorldDataBank >> du cluster
Couchbase à l'aide de l'outil de restauration `cbrestore` comme dans l'exemple
suivant (en remplaçant localhost par l'adresse ou le nom d'un des nœuds du
cluster) :

```sh
/opt/couchbase/bin/cbrestore -u Administrator -p Administrator /home/vagrant/WorldDataBank.dump http://localhost:8091/ -b WorldDataBank
```

Comme nous allons utiliser *N1QL*, il faut créer au moins les index primaires.
Pour cela, nous allons utiliser le client de requêtage en ligne de commande
fourni avec *Couchbase* : `/opt/couchbase/bin/cbq` et y exécuter les
commandes SQL suivantes :

```sql
CREATE PRIMARY INDEX ON WorldDataBank USING GSI;
CREATE INDEX Cat ON WorldDataBank(Category) USING GSI;
CREATE INDEX Counry ON WorldDataBank(Country_Name) USING GSI;
```

Enfin, on peut vérifier que les données sont bien présentes et que l'on peut
exécuter des requêtes *N1QL* avec. Toujours dans le client de requêtage en ligne
de commande, on peut tester une requête *N1QL* :

```sql
SELECT YR2006,YR2007 FROM WorldDataBank WHERE Country_Name='FRA' AND Category='LEB';
```

Ce qui devrait renvoyer le résultat suivant :

```json
{
    "requestID": "11fcb1ff-59ab-4c6a-9b72-fb6782a2d154",
    "signature": {
        "YR2006": "json",
        "YR2007": "json"
    },
    "results": [
        {
            "YR2006": "81.1121951219512",
            "YR2007": "81.2146341463415"
        }
    ],
    "status": "success",
    "metrics": {
        "elapsedTime": "42.479238ms",
        "executionTime": "42.479087ms",
        "resultCount": 1,
        "resultSize": 94
    }
}
```

Initialisation de la structure de l'application
-----------------------------------------------

*Yeoman* est un générateur de squelette d'application. [CEAN] est fournie sous la
forme d'un générateur pour *Yeoman*. Nous allons donc utiliser celui-ci pour
initialiser la structure de notre future application. Le générateur va créer les
répertoires de notre application, les peupler avec des modèles de fichier source
et installer les dépendances dont notre application aura besoin pour
fonctionner.

```sh
mkdir myapp
cd myapp/
yo cean myapp
```

J'ai constaté qu'il arrive parfois que la bibliothèque C Couchbase
(*libcouchbase*) ne s'installe pas toujours. On va forcer son installation
manuellement :

```sh
npm install couchbase
```

C'est le moment de tester que le squelette de l'application a bien été généré et
que les dépendances nécessaires à son exécution son bien installées :

```sh
grunt
```

Ajout d'une route pour exécuter une requête N1QL
------------------------------------------------

Nous allons commencer par créer une route sur le serveur qui associe un URL avec
des paramètres à l'exécution d'une requête *N1QL* en lui transmettant les
paramètres. Cette route côté serveur sera appelée par le service s'exécutant sur
le client. Pour ajouter la route et la logique associée à cette route, nous
allons l'ajouter au fichier `routes/demo.js` :

```js
/**
 * Get a N1ql Resultset
 */
router.get('/getN1ql', function (req, res) {
    var countryId = req.query.countryId;
    var categoryId = req.query.categoryId;

    if (helper.isDefined(countryId)&&helper.isDefined(categoryId))
    {
        var q="SELECT YR2006, YR2007, YR2008, YR2009, YR2010, YR2011, YR2012 FROM WorldDataBank WHERE Country_Name='"+countryId+"' AND Category='"+categoryId+"'";
        console.log("N1QLQUERY:" + q);
        var n1qlQuery = couchbase.N1qlQuery.fromString(q);
        bucket.query(n1qlQuery,
                function(err, cbres) {
                    if (err) {
                        var emsg = "Could not get the document!";
                        console.log("ERROR" + emsg);
                        res.json({ "error" : emsg });

                    } else {
                        console.log("Got " + JSON.stringify(cbres));
                        res.json(cbres);
                    }
                });
    }
    else
    {
        var emsg = "Did you pass all mandatory parameters?";
        console.log("ERROR: " + emsg);
        res.json({"error" : emsg});
    }
});
```

Cette méthode construit la requête *N1QL* en y intégrant les paramètres,
l'envoie sur la console du serveur pour la tracer et l'exécute. En cas
d'erreur, elle est tracée sur la console et renvoyée au service client, sinon,
le résultat est tracé sur la console du serveur et renvoyée au service client.

Il est possible de tester le service depuis un navigateur internet en saisissant
l'URL `http://localhost:9000/service/getN1ql?countryId=FRA&categoryId=LEB`, ce
qui devrait afficher le résultat (remis en forme pour le blog) :

```json
[
    {
        "YR2006":"81.1121951219512",
        "YR2007":"81.2146341463415",
        "YR2008":"81.4146341463415",
        "YR2009":"81.6634146341463",
        "YR2010":"82.1146341463415",
        "YR2011":"81.9682926829268",
        "YR2012":"81.9682926829268"
    }
]
```

Ajout d'une méthode de requêtage N1QL dans le service sur le client
-------------------------------------------------------------------

Le principe est que le côté client comporte un service qui puisse être utilisé
pour interroger le serveur sur un URL (et donc une route avec une fonction
applicative associée à l'URL). Nous avons déjà défini la route avec deux
paramètres sur le serveur. Nous devons donc créer un service du côté client qui
puisse être appelé pour interroger le serveur.

Nous allons donc ajouter une méthode dans le service existant `myservice`
pour iinterroger le cluster Couchbase. Voici la méthode à ajouter dans le
fichier `public/scripts/services/myservice.js` pour récupérer les valeurs
annuelles d'un pays et d'un indicateurs passés en paramètres :

```js
TMyService.prototype.getN1ql = function(countryId,categoryId)
{
    var url = "/service/getN1ql?countryId=" + countryId + "&categoryId=" + categoryId;
    var promise = this.httpService.get(url, {}).success(function (data) { /*Allows to handle the result and errors */ });
    return promise;
}
```

Désormais, le client, dans le navigateur, dispose d'un service Javascript que
l'on peut appeler avec deux paramètres, ce service va faire un appel asynchrone
(sans attendre le résultat) à une URL sur le serveur en transmettant les deux
paramètres, le serveur utilise une route pour associer l'URL et ses paramètres
à une fonction qui génère une requête N1QL, en demande l'exécution et renvoie
le résultat au service sur le client.

Installation de d3js et nvd3
----------------------------

Nous allons ensuite utiliser la bibliothèque [D3] pour effectuer le rendu des
résultats. Pour faciliter son utilisation, nous allons utiliser la bibliothèque
d'encapsulation [nvD3] et plus particulièrement sa version pour Angular,
[Angular-nvD3].

L'installation se fait à l'aide de la commande suivante exécutée dans le
répertoire de l'application :

```sh
bower install angular-nvd3
```

Théoriquement, elle devrait installer automatiquement toutes les
dépendances requises (Angular, [D3], et [nvD3]). Cependant, par précaution, au
cas où les dépendances n'auraient pas été correctement installées, il est
possible de les installer manuellement :

```sh
bower install angular
bower install d3
bower install nvd3
```

Nous allons également ajouter l'installation de toutes ces dépendances dans le
fichier de configuration de bower, `bower.json` :

```json
{
  "name": "myapp",
  "version": "0.0.0",
  "dependencies": {
    "angular": "1.3.x",
    "json3": "^3.3.0",
    "es5-shim": "^4.0.0",
    "bootstrap": "^3.2.0",
    "angular-cookies": "1.3.x",
    "angular-resource": "1.3.x",
    "angular-route": "1.3.x",
    "angular-nvd3": "~0.1.1",
    "nvd3": "~1.8.1"
  },
  "devDependencies": {
    "angular-mocks": "1.3.x",
    "angular-scenario": "1.3.x"
  },
  "appPath": "app"
}
```

Ajout du graphique et des contrôles dans la vue principale
----------------------------------------------------------

Tout d'abord, nous ajoutons l'inclusion de la bibliothèque dans notre application, dans le fichier `public/scripts/app.js` :

```javascript
/**
 * @ngdoc overview
 * @name cbDemoQaApp
 * @description
 * # 'myapp
 *
 * Main module of the application.
 */
var app = angular.module('myapp', [
    'ngCookies',
    'ngResource',
    'nvd3',
    'ngRoute'
]);

app.config(function($routeProvider) {
    $routeProvider
    .when('/', {
       templateUrl : 'views/main.html',
       controller : 'MyCtrl'
    })
    .otherwise({
        redirectTo: '/'
    });
});
```

Ensuite, il faut ajouter les inclusions nécessaires à la génération et à
l'affichage du graphique dans l'en-tête du fichier `public/index.html` :

```html
    <link rel="stylesheet" href="bower_components/nvd3/nv.d3.css">
    <script src="bower_components/d3/d3.js"></script>
    <script src="bower_components/nvd3/nv.d3.js"></script> <!-- or use another assembly -->
    <script src="bower_components/angular-nvd3/dist/angular-nvd3.js"></script>
```

L'application utilise une architecture *MVC* (Model-View-Controler) avec des
modèles. Nous allons donc ajouter les boutons de sélection dans le fichier de
la vue principale `public/views/main.html` pour permettre la sélection des
valeurs de paramètres et en commentant au passage le bouton de l'application de
démonstration :

```html
<div ng-include="'views/header.html'"/>
<div class = "row marketing">
    <div class = "well">
        <h3>Welcome!</h3>
        <p>
            {% raw %}{{msg}}{%endraw%}
        </p>
        <nvd3 options="options"
              data="data"
              config="config"
              events="events"
              api="api"></nvd3>
    </div>
    <form id="add" role="form">
    <select id="selectCountry" class="btn btn-default" ng-click="onFilterChange()">
        <option value="FRA">France</option>
        <option value="CAN">Canada</option>
        <option value="DEU">Germany</option>
    </select>
    <select id="selectCategory" class="btn btn-default" ng-click="onFilterChange()">
        <option value="LBTP">Population</option>
        <option value="LEB">Life expectancy at birth</option>
        <option value="NID">Number of infant death</option>
    </select>
        <!--button id="buttonAdd" class="btn btn-default" ng-click="onAddClicked()">Add Test Document</button-->
    </form>
</div>
<div ng-include="'views/footer.html'"/>
```

Modification du controlleur pour interroger le cluster et mettre le graphique à jour
---------------------------------------------------------------------------------

Nous allons maintenant écrire la partie cliente qui déclenche l'appel au
service lorsque les valeurs des listes sont modifiées, en transmettant les
nouvelles valeurs et en appelant la mise à jour du graphique lorsque les
données seront reçues. Pour cela, modifions le fichier de définition du
controleur principal `scripts/controllers/mycontroller.js` pour y ajouter cette
fonction :

```javascript
   $scope.onFilterChange = function () {
       var countryId=document.getElementById("selectCountry").value;
       var categoryId=document.getElementById("selectCategory").value;

       MyService.getN1ql(countryId,categoryId).then(
           function(ctx) {
               var result = ctx.data;
                $scope.options = {
                    chart: {
                        type: 'discreteBarChart',
                        height: 450,
                        margin : {
                            top: 20,
                            right: 20,
                            bottom: 60,
                            left: 55
                        },
                        x: function(d){ return d.label; },
                        y: function(d){ return d.value; },
                        showValues: true,
                        valueFormat: function(d){
                            return d3.format(',.2f')(d);
                        },
                        transitionDuration: 500,
                        xAxis: {
                            axisLabel: 'Years'
                        },
                        yAxis: {
                            axisLabel: categoryId,
                            axisLabelDistance: 30
                        }
                    }
                };

                $scope.data = [{
                    key: "Cumulative Return",
                    values: [
                        { "label" : "2006" , "value" : result[0].YR2006 },
                        { "label" : "2007" , "value" : result[0].YR2007 },
                        { "label" : "2008" , "value" : result[0].YR2008 },
                        { "label" : "2009" , "value" : result[0].YR2009 },
                        { "label" : "2010" , "value" : result[0].YR2010 },
                        { "label" : "2011" , "value" : result[0].YR2011 },
                        { "label" : "2012" , "value" : result[0].YR2012 }
                        ]
                    }];
           }
        );
   }
```

Test du résultat
----------------

Si vous avez arreté `grunt`, il est temps de le redémarrer :

```sh
grunt
Running "parallel:web" (parallel) task
Running "watch:frontend" (watch) task
Waiting...
Running "watch:web" (watch) task
Waiting...

Running "express:web" (express) task
Starting background Express server
cluster = {"dsnObj":{"scheme":"couchbase","hosts":[["192.168.56.101",0]],"bucket":"default","options":{}}}
bucket = {"_name":"default","_username":"default","_password":"","_cb":{},"connected":null,"waitQueue":[],"_events":{},"httpAgent":{"domain":null,"_events":{},"_maxListeners":10,"options":{},"requests":{},"sockets":{},"maxSockets":250}}

Running "watch:web" (watch) task
Completed in 0.249s at Mon Oct 19 2015 05:05:44 GMT-0400 (EDT) - Waiting...
Example app listening at http://0.0.0.0:9000

```

Vous pouvez ensuite connecter votre navigateur sur l'adresse et le port de votre
application `http://localhost:9000/` et vous devriez pouvoir utiliser votre
nouvelle application de visualisation interactive :

![Application]({{site.url}}{{site.baseurl}}/assets/posts/CeanAndD3/application.png)

La console de l'application devrait afficher les requêtes N1QL et les valeurs
retournées :

```sh
N1QLQUERY:SELECT YR2006, YR2007, YR2008, YR2009, YR2010, YR2011, YR2012 FROM
WorldDataBank WHERE Country_Name='FRA' AND Category='LBTP'
Got
[{"YR2006":64012572,"YR2007":64371099,"YR2008":64702921,"YR2009":65023142,"YR2010":65338149,"YR2011":65635082,"YR2012":65920302}]
```

Voila
=====

Vous avez vu comment initialiser une nouvelle application NodeJS basée sur la
pile de dévelopement CEAN, comment fonctionnent les routes, les services, les
controleurs, les vues, comment faire exécuter une requête N1QL paramétrée,
récupérer le résultat et le représenter à l'aide d'un graphique D3 interactif.

[téléchargement]: http://www.couchbase.com/nosql-databases/downloads
[Couchbase]: http://www.couchbase.com
[NodeJS]: https://nodejs.org
[CEAN]: https://sites.google.com/site/cbcean/documentation
[jeu de données]: {{site.url}}{{site.baseurl}}/assets/posts/CeanAndD3/WorldDataBank.dump.zip
[D3]: http://d3js.org
[NVD3]: http://nvd3.org
[Angular-nvD3]: http://krispo.github.io/angular-nvd3/
