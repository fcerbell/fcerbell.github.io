---
uid: DataLoading
title: Loading data in Couchbase with RxJava
author: fcerbell
layout: post
#description:
category: tutos
#categories
tags: Java ReactiveX RxJava Couchbase Data
#date
#published: false
---

This short tutorial explains how to find an interesting data set (quantitatively
and qualitatively) and load it into Couchbase in order to play with it.

* TOC
{:toc}

Downloading a dataset
=====================

There are many sites with data sets. But they are often either too small or not
very interesting from a business perspective (logs, records of Technical
sensors, ...). Fortunately, a site has more than 1300 development indicators
aggregated by country for 215 countries over 50 years. It proposes indicators of
business (financial, industrial, demographic, social, ...) according to a time
axis and a geographical axis. This is perfect to have some fun.

We must first go to the site [WorldDataBank] to select the wanted indicateurs.
For the import step, I chose to put the countries in rows, the indicators in
groups and the years in columns. Then I exported to CSV. 

Since it is not possible to select the whole dataset for performances
constraints, I had to make several selections / export then I concatenated the
files. For convenience you can download the [whole file] [all.csv]. It
contains 1,300 indicators for 215 countries from 1960 to 2014, or about 5
million values (after removing the missing values).

Development environment
=======================

Couchbase's `cbdocloader` provides a tool to load JSON or CSV documents
in Couchbase, however the CSV format does not match the
desired document design in the database. Therefore we can not use this
tool. It is possible to use an ETL like Talend to transform
data and inject them into Couchbase, but I preferred to use the SDK
to illustrate its implementation simplicity, power and speed.

IntelliJ IDEA
-------------

You can use any development studio.
Personally I have a preference for [IntelliJ IDEA] when I did not edit
my files in *vi*. I find it lighter, faster and more responsive
than Eclipse.

Couchbase JAVA SDK 2.2
----------------------

To contact the Couchbase cluster, you will have to download the [SDK JAVA
Couchbase]. I met some issues with the latest version of SDK because of a bug in
the Jackson library, so I used the version SDK 2.1.4 for this tutorial. Once
downloaded and unzipped, you'll need to add the three JAR files
(Couchbase-core-io-1.1.4.jar, Couchbase-java-client-2.1.4.jar, rxjava-1.0.4.jar)
in your JAVA compiler's *classpath*. In IntelliJ, simply copy / paste into the
project and declare them as *library* with a right click.

Apache Commons-CSV
------------------

The source data file being in *CSV* format I, chose to use the [Apache Commons
CSV] library (1.2) to read the file. As for the Couchbase SDK, you must
decompress the file and add the library (commons-csv-1.2.jar) in the JAVA
compiler's *classpath* (copy / paste file in the project and declaration as
*library* by a right-clic).

Import application
==================

It is possible to use the SDK with development frameworks such as Spring, it is
possible (and recommended) to create classes for different objects (Repository,
Factory, AbstractStuff, VirtualStuff, PublicStuff, PrivateStuff, ...). But I
will not do it. The purpose of this article is to present simple information in
a minimum of files (and therefore classes). I will use only one class in
addition to my program or two classes in total, or two files.

I will not go into details of RxJava, to make it short, is a framework that
allows to request action execution on objects at the time where they are
available. Thus, the application no longer needlessly waits for a object to be
available, it continues its execution flow and the action will run in the
background, when the data will be there (This really is much more than that, but
that's the part that interests us for now).

All of the source code of this article is available in my [Couchbase-RxImporter]
repository on GitHub.

CSV file reading
----------------

The idea is very simple, the CSV file has to be in a well known format :

Country code | Country name | Serie code | Serie name | 1960 value | ... | 2014 value
-------------|--------------|------------|------------|------------|-----|------------
FRA          | France       | SP_POP_TOTL| Population | 46647521   | ... | 66201365

The CSV file name will be passed as program argument on the command line.

We will use the Apache-Commons-CSV library to read and parse the file, we will
skip the very first line (column header) and the empty lines. The JAVA code is
quite simple :

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

Couchbase cluster connection
------------------------------

Let's add the Couchbase cluster connection instructions before opening the
CSV file. By default, the Couchbase SDK is very verbose, we will first limit its
verbosity and then open the connection to the cluster.

In the applications's logic, we want to make a total reloading
at each launch. We also want to run tests in a row without
having to empty the bucket or recreating it each time from the web interface. So
let's start by testing the existence of the bucket to delete it and
test his absence to create it with the needed configuration. It allows us to be
sure that the bucket is in a known state : it exists, with the wanted settings
and that it is empty.

At the end of this sequence, we will "open" the "bucket" to make it available
for the application to populate it.

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

Even if it is not mandatory, it is better to try to write clean code and to
close properly the bucket and the cluster connection at the end of the
application :

```java
// Disconnect and clear all allocated resources
        cluster.disconnect();
```

If you use an IDE such as *Eclipse* or *IntelliJ*, it might already added import
statements at the begining of your code to import the required packages. If not,
you can add them manually :

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

Our application knows how to open a cluster connection, how to prepare a bucket
in a defined and well known state, how to read the CSV file lines and how to
close things properly.

Parsing and processing the records
----------------------------------
The underlying idea behind the Couchbase SDK is to use the [ReactiveX] framework 
that was initially developped by NetFlix, in its Java flavor (RxJava), to work
asyncroneously. The goal is to define actions to execute on objects "as soon as
they become available", to forget it and continue the application execution flow
without waiting for the object to be processed. The object is `Observable` and
the actions are defined in an `Observer`.

To achieve this, we will use the classes and methods defined in the Couchbase
SDK. First, we need to implement an `Observer` class with three methods :

* a method to trigger when a new `Observable` object is available to be
  processed (`onNext`) ;

* a methods to trigger when all the `Observable` objects have been processed
  (`onComplete`) ;

* a method to call when an error occured during the `Observable` objects fetch
  (`onError`).

The complete source code is available in my [Couchbase-RxImporter] GitHub
repository :

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
à jour avant de terminer le programme. Nous utiliseront le *callback*
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
série d'élement observable (`String[]`). Pour cela, je construis rapidement
chaque table de chaîne de caractères manuellement à partir des méthodes de la
classe `CSVRecord` :

```
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
parallélisées. Cela reviendrait donc à exécuter les insertions et les mises à
jours de façons linéaire, en perdant tous les bénéfices d'une parallélisation.

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




Création des index
==================

Le jeu de données est chargé. Nous allons créer quelques index basiques pour
pouvoir l'utiliser d'une manière générale. Pour cela, le plus simple est de se
connecter sur le serveur hébergeant Couchbase et de démarrer le client en ligne
de commande `/opt/couchbase/cbq` :

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
[all.csv]: {{site.url}}/assets/posts/DataLoading/all.csv.zip
[IntelliJ IDEA]: https://www.jetbrains.com/idea/
[SDK JAVA Couchbase]: http://developer.couchbase.com/documentation/server/4.0/sdks/java-2.2/download-links.html
[Apache Commons CSV]: https://commons.apache.org/proper/commons-csv/
[Couchbase-RxImporter]: https://github.com/fcerbell/Couchbase-RxImporter
[ReactiveX]: http://reactivex.io/
