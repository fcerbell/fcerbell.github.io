---
uid: DataLoading
title: Charger des données dans Couchbase avec RxJava
description:
category: Informatique
tags: [ Java, ReactiveX, RxJava, Couchbase, Données ]
---

Ce petit tutoriel explique comment trouver un jeu de données intéressant
(quantitativement et qualitativement) et le charger dans CouchBase pour pouvoir
le manipuler ensuite. Il s'agit d'une application de type preuve de concept,
elle pourrait être très largement améliorée et optimisée. Je l'ai écrite pour
charger rapidement mes données dans mon cluster, sans gérer tous les cas et sans
optimisation. J'ai ensuite voulu la documenter et la partager dans ce blog, je
l'ai un peu nettoyée, mais ce n'est en aucun cas une application à déployer en
production ! ;)

* TOC
{:toc}

Télécharger un jeu de données
=============================

Il existe de nombreux sites avec des jeux de données. Mais ils sont souvent soit
trop petits, soit peu intéressants d'un point de vue métier (logs, relevés de
capteurs techniques, ...). Heureusement, un site regroupe plus de 1300
indicateurs du dévelopement des pays agrégés pour 215 pays, sur 50 ans.  Il nous
propose donc des indicateurs métiers (financiers, industriels, démographiques,
sociaux, ...) selon un axe temps et un axe géographique. C'est parfait pour
pouvoir s'amuser.

Il faut commencer par aller sur le site [WorldDataBank] pour y effectuer sa
selection d'indicateurs. Pour l'importation, j'ai choisi de placer en ligne les
pays, en groupe les indicateurs, et en colonne les années. Ensuite, j'exporte en
CSV.

Comme il n'est pas possible de tout sélectionner pour des contraintes de
volumes, j'ai du faire plusieurs selections/exportation puis j'ai concaténé les
fichiers. Pour plus de facilité, vous pouvez télécharger le [Fichier
complet][all.csv]. Il contient les 1300 indicateurs pour les 215 pays, de 1960 à
2014, soit environ 5 million de valeurs (en retirant les valeurs absentes).

Environnement de développement
==============================

Couchbase fournit un outil `cbdocloader` pour charger des documents au format
JSON ou CSV dans Couchbase, cependant le format du CSV ne correspond pas au
schéma souhaité dans la base de document. Nous ne pouvons donc pas utiliser cet
outil. Il est possible d'utiliser un ETL comme celui de Talend pour transformer
les données et les injecter dans Couchbase, mais j'ai préféré utiliser le SDK
pour illustrer sa simplicité de mise en œuvre, sa puissance et sa rapidité.


IntelliJ IDEA
-------------

Il est possible d'utiliser n'importe quel studio de développement.
Personnellement j'ai une préférence pour [IntelliJ IDEA] lorsque je n'édite pas
mes fichiers sous *vi*. Je le trouve plus léger, plus rapide et plus réactif
qu'Eclipse.

Couchbase JAVA SDK 2.2
----------------------

Pour pouvoir communiquer avec le cluster Couchbase, il va falloir télécharger le
[SDK JAVA Couchbase]. J'ai rencontré quelques soucis avec la dernière version du
SDK à cause d'un bug dans la bibliothèque Jackson, j'ai donc utilisé la version
2.1.4 du SDK pour ce tutoriel.  Une fois le fichier téléchargé et décompressé,
vous aurez besoin d'ajouter les trois fichiers JAR (couchbase-core-io-1.1.4.jar,
couchbase-java-client-2.1.4.jar, rxjava-1.0.4.jar) dans le *classpath* de votre
compilateur JAVA. Dans *IntelliJ*, il suffit de faire un copier/coller dans le
projet et de les déclarer en tant que *library* d'un clic droit de la souris.


Apache Commons-CSV
------------------

Le fichier de données sources étant au format *CSV*, j'ai choisi d'utiliser la
bibliothèque [Apache Commons CSV] 1.2 pour lire le fichier. Tout comme pour le
SDK de Couchbase, il faut décompresser le fichier et ajouter la bibliothèque
(commons-csv-1.2.jar) dans le *classpath* du compilateur JAVA (copier/coller du
fichier dans le projet et déclaration comme *library* par un clic droit de la
souris).

Application de chargement
=========================

Il est possible d'utiliser le SDK avec des framework comme *Spring*, il est
possible (et recommandé) de faire de classes propres pour les différents objets
(Entrepot/Repository, Usine/Factory, TrucAbstrait, TrucVirtuel, TrucsPublics,
TrucsPrivés...).  Mais je ne le ferai pas. Le but de cet article est de
présenter des informations simples dans un minimum de fichiers (et donc de
classes). Je ne vais utiliser qu'une seule classe en plus de mon programme, soit
deux classes au total, ou deux fichiers.

Je ne vais pas rentrer dans les détails de RxJava, pour faire court, c'est un
framework qui permet de demander l'exécution d'actions sur des objets au moment
où ils sont disponibles. Ainsi, l'application n'attend plus inutilement qu'un
objet soit disponible, elle continue son flot d'exécution et l'action
s'exécutera en arrière-plan, lorsque la donnée sera là (C'est vraiment beaucoup
plus que ça, mais c'est la partie qui nous intéresse pour l'instant).

La totalité des sources de cet article est disponible dans mon dépôt
[Couchbase-RxImporter] sur GitHub.

Lecture du fichier CSV
----------------------

L'idée est très simple, le fichier CSV est dans un format connu et imposé :

Code pays | Nom Pays | Code série | Nom série | Valeur 1960 | ... | Valeur 2014
----------|----------|------------|-----------|-------------|-----|------------
FRA       | France   | SP_POP_TOTL| Population| 46647521    | ... | 66201365

Le nom du fichier CSV à charger sera passé en argument de ligne de commande au
programme.

Nous utilisons la bibliothèque Apache-Commons-CSV pour lire et interpréter le
fichier en ignorant la première ligne (ligne d'en-tête de colonne) et les lignes
vides. Le code pour cela est relativement simple :

```java
package net.cerbelle.WDI;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;

import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;


/**
 * Created by fcerbell on 11/09/2015.
 *
 */
public class Import {

    public static void main(String[] args) throws IOException {

        System.out.println("WorldDevelopmentIndicators loader");
        System.out.println("File to load : " + args[0]);

        Reader in = new FileReader(args[0]);
        Iterable<CSVRecord> records = CSVFormat
                .EXCEL
                .withHeader("CountryName", "CountryCode", "SerieName", "SerieCode"
                        , "1960", "1961", "1962", "1963", "1964", "1965", "1966", "1967", "1968", "1969"
                        , "1970", "1971", "1972", "1973", "1974", "1975", "1976", "1977", "1978", "1979"
                        , "1980", "1981", "1982", "1983", "1984", "1985", "1986", "1987", "1988", "1989"
                        , "1990", "1991", "1992", "1993", "1994", "1995", "1996", "1997", "1998", "1999"
                        , "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009"
                        , "2010", "2011", "2012", "2013", "2014"
                )
                .withSkipHeaderRecord()
                .withNullString("..")
                .withIgnoreEmptyLines()
                .parse(in);

        for (CSVRecord record : records) {
            System.out.println(record);
        }

    }
}

```

Connexion au cluster Couchbase
------------------------------

Ajoutons les instructions de connexion au cluster Couchbase avant l'ouverture du
fichier CSV. Par défaut, le SDK Couchbase est très bavard, nous allons donc en
limiter la verbosité. Puis ouvrir une connexion sur le cluster.

Dans la logique de l'application, nous voulons effectuer un rechargement total à
chaque lancement. Nous voulons également pouvoir faire des tests à la suite sans
devoir vider le bucket ou le recréer à chaque fois depuis l'interface WEB. Nous
allons donc commencer par tester l'existence du bucket pour le supprimer, puis
tester son absence pour le créer avec la configuration qui nous intéresse. Cela
nous permet d'être certain de l'état du bucket : il existe, dans la
configuration voulue, et il est vide.

À la fin de cette séquence, nous allons << ouvrir >> le << bucket >> pour le mettre
à disposition de la suite de l'application et permettre de le charger.

```java
        Logger logger = Logger.getLogger("com.couchbase.client");
        logger.setLevel(Level.WARNING);
        for(Handler h : logger.getParent().getHandlers()) {
            if(h instanceof ConsoleHandler){
                h.setLevel(Level.WARNING);
            }
        }

        // Connect to the cluster
        Cluster cluster;
        System.out.println("Cluster connection");
        cluster = CouchbaseCluster.create(clusterAddress);

        // Create a cluster manager
        ClusterManager clusterManager = cluster.clusterManager(clusterUsername,clusterPassword);

        // Drop the bucket if already existing
        if (clusterManager.hasBucket(bucketName)) {
            System.out.println("Drop bucket");
            clusterManager.removeBucket(bucketName);
        }

        // Create the bucket if not already existing
        if (!clusterManager.hasBucket(bucketName)) {
            System.out.println("Create bucket bucket");
            BucketSettings bucketSettings = new DefaultBucketSettings.Builder()
                    .type(BucketType.COUCHBASE)
                    .name(bucketName)
                    .password("")
                    .quota(300) // megabytes
                    .replicas(0)
                    .indexReplicas(false)
                    .enableFlush(false)
                    .build();
            clusterManager.insertBucket(bucketSettings);
        }

        // Open the WDI bucket
        System.out.println("Open bucket");
        WDIBucket = cluster.openBucket(bucketName);

```

Même si ce n'est pas obligatoire, autant programmer proprement et ajouter la
fermeture du << bucket >> et de la connexion au << cluster >> à la fin de notre
application :

```java
// Disconnect and clear all allocated resources
        cluster.disconnect();
```

Si vous développez dans une interface de développement intégrée comme *Eclipse*
ou *IntelliJ*, elle a certainement ajouté des lignes d'importation de
paquetages au début de votre programme. Si ce n'est pas le cas, ajoutez-les
manuellement :

```java
import com.couchbase.client.java.Bucket;
import com.couchbase.client.java.Cluster;
import com.couchbase.client.java.CouchbaseCluster;
import com.couchbase.client.java.bucket.BucketType;
import com.couchbase.client.java.cluster.BucketSettings;
import com.couchbase.client.java.cluster.ClusterManager;
import com.couchbase.client.java.cluster.DefaultBucketSettings;

import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.util.concurrent.CountDownLatch;
import java.util.logging.ConsoleHandler;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.Logger;
```

Notre programme sait désormais ouvrir une connexion sur le cluster, préparer un
<< bucket >> dans une configuration voulue, parcourir les lignes d'un fichier
CSV, les lire et les interpréter, pour ensuite refermer les objets Couchbase.

Parcourir les enregistrements et les traiter
--------------------------------------------

Le principe du SDK Couchbase est d'utiliser le framework [ReactiveX] initialement
développé par NetFlix, appliqué à JAVA (RxJava) pour travailler de manière
asynchrone. L'idée est de définir les actions à effectuer sur des objets
lorsqu'ils seront disponibles et de continuer à faire ce que l'on veut sans
attendre. L'objet à traiter est un `Observable`, les actions à effectuer sur cet
objet lorsqu'il sera disponible sont définies dans un `Observer`.

Pour cela, nous allons utiliser les classes et les méthodes fournies pas le SDK
Couchbase. Nous allons commencer par implémenter une classe `Observer` qui
disposera de trois méthodes :

* une méthode à déclencher lorsqu'un objet `Observable` à traiter est disponible (`onNext`);

* une méthode à déclencher lorsque tous les objets `Observable` ont été traités
  (`onComplete`) ;

* une méthode à déclencher lorsqu'une erreur s'est produite dans la récupération
  des objets `Observable` à traiter (`onError`).

Le code source complet de cette classe est disponible dans mon dépôt
[Couchbase-RxImporter] sur GitHub :

```java
package net.cerbelle.WDI;

import com.couchbase.client.java.document.JsonDocument;
import com.couchbase.client.java.document.json.JsonObject;
import rx.Observer;

/**
 * Created by fcerbell on 16/09/2015.
 * CSVRecord upsert
 */
public class RecordObserver implements Observer<String[]> {
    @Override
    public void onCompleted() {
        System.out.println("Finished.");
    }

    @Override
    public void onError(Throwable exception) {
        System.out.println("Oops!");
        exception.printStackTrace();
    }

    @Override
    public void onNext(String[] r) {
        JsonDocument indicatorsDocument;
        JsonObject indicatorsObject;

//        System.out.println(r[0] + " " + r[1] + " " + r[2] + " " + r[3] + " " + r[4] + " " + r[5] + " (Observed by : " + Thread.currentThread().getName() + ")");
        String Year = r[0];
        String CountryCode = r[1];
        String CountryName = r[2];
        String SerieCode = r[3];
        String SerieName = r[4];
        String Value = r[5];

        indicatorsDocument = Import.WDIBucket.get(Year + "_" + CountryCode);
        if (indicatorsDocument == null) {
            indicatorsObject = JsonObject.empty();
        } else {
            indicatorsObject = indicatorsDocument.content();
        }
        indicatorsObject
                .put("Year", Year)
                .put("CountryCode", CountryCode)
                .put("CountryName", CountryName)
                .put(SerieCode.replace('.', '_'), Double.valueOf(Value));
        indicatorsDocument = JsonDocument.create(Year + "_" + CountryCode, indicatorsObject);
        Import.WDIBucket.upsert(indicatorsDocument);
    }
}
```

Cette première version est très simple, tout en étant efficace.

Nous allons maintenant utiliser cette classe dans notre programme principal pour
charger les informations dans notre cluster. Le SDK fonctionne de manière
asynchrone, si nous démarrons le chargement puis terminons le programme sans
attendre, il est probable (et même certain) que toutes les informations ne
seront pas traitées. On pourrait bien attendre un délai en utilisant
`Thread.sleep(delai)`, mais si le delai est trop court, nous perdrions des
informations et si le délai est trop long, nous perdrons du temps inutilement...
La solution consiste à définie un compteur distribué (pour resister à
d'éventuels effets de bord liés à la parallélisation), à attendre qu'il soit mis
à jour avant de terminer le programme. Nous utiliseront la méthode
`doOnCompleted` pour le modifier, ce qui donne la trame suivante :

```java
        final CountDownLatch latch = new CountDownLatch(1);
        Observable
                .from(records)
                .doOnCompleted(latch::countDown);
        try {
            latch.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
```

Ce code ne peut pas fonctionner pour l'instant, il manque encore des éléments,
en effet, l'`Observable` fournit des éléments de type `CVSRecord` alors que
l'`Observer` attend un tableau de `String`.

Pour commencer, nous allons filtrer les lignes pour lesquelles le champs
`CountryCode` est vide, cela correspond au lignes vides pouvant se trouver à la
fin du fichier :

```java
        Observable
                .from(records)
                .filter(r -> !r.get("CountryCode").isEmpty())
```

Nous allons ensuite convertir chaque élément observable (`CSVRecord`) en une
série d'élement observable (`String[]`) comme attendus par l'`Observer`. Nous
pourrions aussi modifier l'`Observer` pour qu'il accepte un `CSVRecord` en
entrée et le traite. Pour cela, je construis rapidement chaque table de chaîne
de caractères manuellement à partir des méthodes de la classe `CSVRecord`. Cela
pourrait être amélioré pour gérer un nombre arbitraire de colonnes, mais je n'en
ai pas besoin :

```java
                .flatMap(
                        r -> Observable.from(new String[][]{
                                {"1960", r.get("CountryCode"), r.get("CountryName"), r.get("SerieCode"), r.get("SerieName"), r.get("1960")},
                                {"1961", r.get("CountryCode"), r.get("CountryName"), r.get("SerieCode"), r.get("SerieName"), r.get("1961")},
                                ...
                                {"2013", r.get("CountryCode"), r.get("CountryName"), r.get("SerieCode"), r.get("SerieName"), r.get("2013")},
                                {"2014", r.get("CountryCode"), r.get("CountryName"), r.get("SerieCode"), r.get("SerieName"), r.get("2014")}
                        })
                )
```

Nous pourrions appeler l'`Observer` sur ce résultat, cependant notre fichier CSV
comporte beaucoup de valeurs non définies. Dans le monde *BigData*, une valeur
non-définie n'est habituellement pas stockées. Nous allons donc filtrer les
valeurs non-définies pour ne pas créer de valeurs vides dans la base, nous
allons en profiter pour modifier le compteur qui mettra fin au programme et
nous allons inscrire notre `Observer` à ce flux d'éléments observables
(`String[]`) pour qu'il applique les traitements (écriture dans la base), de
manière parallèle selon un ordonnanceur créant un fil d'exécution par cœur
processeur disponible :

```java
                .filter(valueLine -> valueLine[5] != null)
                .doOnCompleted(latch::countDown)
                .subscribeOn(Schedulers.computation())
                .subscribe(new RecordObserver());
```

Le bloc complet ressemble donc à :

```java

        final CountDownLatch latch = new CountDownLatch(1);
        Observable
                .from(records)
                .filter(r -> !r.get("CountryCode").isEmpty())
                .flatMap(
                        r -> Observable.from(new String[][]{
                                {"1960", r.get("CountryCode"), r.get("CountryName"), r.get("SerieCode"), r.get("SerieName"), r.get("1960")},
                                {"1961", r.get("CountryCode"), r.get("CountryName"), r.get("SerieCode"), r.get("SerieName"), r.get("1961")},
                                {"1962", r.get("CountryCode"), r.get("CountryName"), r.get("SerieCode"), r.get("SerieName"), r.get("1962")},
                                ...
                                {"2010", r.get("CountryCode"), r.get("CountryName"), r.get("SerieCode"), r.get("SerieName"), r.get("2010")},
                                {"2011", r.get("CountryCode"), r.get("CountryName"), r.get("SerieCode"), r.get("SerieName"), r.get("2011")},
                                {"2012", r.get("CountryCode"), r.get("CountryName"), r.get("SerieCode"), r.get("SerieName"), r.get("2012")},
                                {"2013", r.get("CountryCode"), r.get("CountryName"), r.get("SerieCode"), r.get("SerieName"), r.get("2013")},
                                {"2014", r.get("CountryCode"), r.get("CountryName"), r.get("SerieCode"), r.get("SerieName"), r.get("2014")}
                        })
                )
                .filter(valueLine -> valueLine[5] != null)
                .doOnCompleted(latch::countDown)
                .subscribeOn(Schedulers.computation())
                .subscribe(new RecordObserver());

        try {
            latch.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
```

Gestion des conflits
--------------------

Pour chaque ligne du fichier, le programme détermine les documents dans lesquels
placer les informations de la ligne. Pour chacun de ces documents, il rechercher
le document dans le cluster Couchbase. Si le document existe déjà, l'information
de la ligne doit y être ajoutée, le document est donc chargé depuis Couchbase,
l'information y est ajoutée et le document est remplacé dans Couchbase. Si le
document n'existait pas, il est créé et enregistré dans Couchbase. Le programme
d'importation pouvant être paralélisé, il est possible que plusieurs fils
d'exécution aient besoin d'accéder en création ou en modification au même
document en même temps et il y a un risque pour que deux fils d'exécution lisent
le contenu de la même ligne, la modifient chacun de son côté, puis l'écrive dans
la base. Cela signifie qu'une des modifications sera écrasée par l'autre.

Les base de données relationnelle traditionnelle supportent généralement les
transactions. Il est donc possible de rendre la suite d'opérations entre la
recherche et l'écriture atomiques. Couchbase ne dispose pas de mécanisme de
transaction, ce n'est pas son but.

Une première approche pessimiste et classique, consiste à utiliser des *mutex*
pour protéger la section critique. La section critique qui serait à protéger
commencerait à la recherche du document dans Couchbase et irait jusqu'à
l'écriture du nouveau document ou du document modifié dans Couchbase.  Cette
section ne pourrait être exécutée que par un seul fil d'exécution à la fois. Le
problème est que cette section correspond quasiment à la totalité des opérations
parallélisées. Par ailleurs, ce serait du gâchis d'interdire deux accès
simultané à la base lorsque les documents ne sont pas les mêmes. Cela
reviendrait donc à exécuter les insertions et les mises à jours de façons
linéaire, en perdant tous les bénéfices d'une parallélisation.

Une second approche pessimiste consiste à verrouiller le document lors de sa
lecture et à le déverrouiller lors de son écriture. Si le document n'existait
pas lors de la lecture et existe lors de l'écriture, il faudrait que le fil
d'exécution reprenne depuis le début car un autre fil d'exécution a créé le
document entre temps. Cette implémentation permet d'éviter les écrasements, elle
permet d'avoir un taux d'exécution en parallèle acceptable, cependant, elle
entraine une surcharge de cycles CPU du côté cluster (avec les verrous) et du
côté client (avec la gestion des conflits). Elle pourrait éventuellement être
intéressante si on sait à l'avance qu'il y aura beaucoup de collisions car elle
permet de les anticiper et d'en éviter un certain nombre par avance grâce aux
verrous.

Une troisème approche optimiste consiste à considérer qu'il y aura des
collisions, mais qu'il y en aura peu. On va donc éviter les protections << a
priori >> qui pénalisent tous les accès, en acceptant de devoir gérer parfois
une collision, quite à ce que ce traitement soit un peu plus complexe. Le fil
d'exécution va rechercher le document, s'il existe, il va le lire avec son
numéro de série (CAS), le modifier et l'écrire dans la base en incrémentant le
numéro de série si celui-ci n'a pas été modifié par ailleurs. Si le document
n'existe pas, il va être créé et écrit dans le cluster. Si le numéro de série
avait changé ou si un document avait été créé entre temps, le fil d'exécution
recommence depuis la recherche du document jusqu'à ce qu'il arrive à écrire
l'information dans le document.

Dans le cadre de notre importation, les informations à insérer sont classées par
blocs Pays/Indicateurs/Années. Il y a des risques de collisions, mais ils sont
limités. Nous allons donc tenter une approche optimiste (Même si j'essaye de
prévoir et de préparer le pire, j'essaie de rester optimiste).

Nous devons donc modifier notre `Observer`... Mais très peu, car la méthode
`get` retourne le document en incluant le numéro de série et ce numéro de série
est pris en compte par la méthode `replace`. En revanche, il faut appeler
explicitement la méthode `insert` lorsque nous créons un nouveau document pour
qu'elle échoue si le document existe déjà :

```java
        indicatorsObject
                .put("Year", Year)
                .put("CountryCode", CountryCode)
                .put("CountryName", CountryName)
                .put(SerieCode.replace('.', '_'), Double.valueOf(Value));
        if (indicatorsDocument == null) {
            indicatorsDocument = JsonDocument.create(Year + "_" + CountryCode, indicatorsObject);
            Import.WDIBucket.insert(indicatorsDocument);
        } else {
            indicatorsDocument = JsonDocument.create(Year + "_" + CountryCode, indicatorsObject);
            Import.WDIBucket.replace(indicatorsDocument);
        }
```

Création des index
==================

Le jeu de données est chargé. Nous allons créer quelques index basiques pour
pouvoir l'utiliser d'une manière générale. Pour cela, le plus simple est de se
connecter sur le serveur hébergeant Couchbase et de démarrer le client en ligne
de commande `/opt/couchbase/bin/cbq` :

```sh
/opt/couchbase/bin/cbq
```

Le premier index correspond à un index général. Le second est l'index primaire
indispensable pour utiliser le langage N1QL. Il index les clés primaires des
documents. Les deux derniers index correspondent aux cas d'utilisation théorique
de notre jeu de données, d'une manière générale.  *GSI* signifie * Global
Secondary Index*, il s'agit d'un nouveau type d'index centralisé (par opposition
aux index locaux distribués que sont les vues).

```sql
CREATE PRIMARY INDEX ON default;
CREATE PRIMARY INDEX ON WorldDevelopmentIndicators;
CREATE INDEX Year ON WorldDevelopmentIndicators(Year) USING GSI;
CREATE INDEX CountryCode ON WorldDevelopmentIndicators(CountryCode) USING GSI;
```

Voilà
=====

Nous disposons désormais d'un jeu de données à la fois riche et conséquent pour
commencer à l'explorer avec un outil d'analyse ou de rapports, par exemple, mais
ceci est le sujet d'un prochain article...

[WorldDataBank]: http://databank.worldbank.org/data/reports.aspx?source=world-development-indicators#
[all.csv]: {{ "/assets/posts/DataLoading/all.csv.zip" | relative_url }}
[IntelliJ IDEA]: https://www.jetbrains.com/idea/
[SDK JAVA Couchbase]: http://developer.couchbase.com/documentation/server/4.0/sdks/java-2.2/download-links.html
[Apache Commons CSV]: https://commons.apache.org/proper/commons-csv/
[Couchbase-RxImporter]: https://github.com/fcerbell/Couchbase-RxImporter
[ReactiveX]: http://reactivex.io/
