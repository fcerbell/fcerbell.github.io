---
uid: DataLoading
title: Loading data in Couchbase with RxJava
author: fcerbell
layout: post
lang: en
#description:
category: tutos
#categories
tags: Java ReactiveX RxJava Couchbase Data
#date
#published: false
---

This short tutorial explains how to find an interesting data set (quantitatively
and qualitatively) and load it into Couchbase in order to play with it. This is
a quick and dirty application, it could be largely improved and optimized. I
wrote it quickly because I needed something quickly up-and-running to load my
data. I decided to write a post on it and I only cleaned the very-dirty things
before writing this post. It is clearly not a production-class program ! ;)

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

This first version is very simple, but also very efficient.

We will now use this class in our main program to load information in our
cluster. The SDK works asynchroneously, if we start the loading and stop the
program without waiting, the odds are high that not all the information will be
loaded. We could wait for a delay using `Thread.sleep(delay)` but if the
specified delay is too short, we will still loose information and if the delay
is too long, we will wait uselessly. The fix is to use a distributed counter (to
be thread proof), to update it when all the data are processed and to end the
program when the counter is updated. We will use the `doOnCompleted` method to
update it :

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

This piece of code can not work yet. It still miss things. The `Observable`
provide `CVSRecords` whereas the `Observer` waits for `String[]`.

First, we will filter the `Observable` to remove the lines with an empty
`CountryCode`, these lines are empty lines usually at the end of the file :

```java
        Observable
                .from(records)
                .filter(r -> !r.get("CountryCode").isEmpty())
```

Then, we will convert each `Observable` record (`CSVRecord`) to an `Observable`
list of string arrays (`String[]`), as expected by the `Observer`. We could also
change the `Observer` to accept `CSVRecords` and to process them. I quickly
build q string array by using the `CSVRecords` methods manually, it could be
improved to deal with an arbitrary number of columns but I dont need this :

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

We could call the `Observer` on this result, but our CSV file has a lot of
undefined values. In the *BigData* world, an undefined value is not stored. So,
we will remove theses undefined values. We will also change the counter value at
the end of processing to notify the main class that it can end. And finally, we
will subscribe our `Observer` to the built `Observable` so that it will process
each item, using a scheduler to use parallel threads (in that case, one per
core) :

```java
                .filter(valueLine -> valueLine[5] != null)
                .doOnCompleted(latch::countDown)
                .subscribeOn(Schedulers.computation())
                .subscribe(new RecordObserver());
```

So, the whole bloc should be :

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

Conflicts resolution
--------------------

For each CSV line, the program finds the documents in which he needs to write
the line details. For each of these documents, he search for the document in the
Couchbase cluster. If the document already exists, he has to add the detail to
the document, so the document is fetched from Couchbase, the details are added
and the document is then pushed back to Couchbase. If the document did not
already exist, it is created from scratch, and pushed to Couchbase. As the
import program can be executed in parallel threads, it is possible that several
threads need the same document at the same time. One of the change will be lost.

The usual relational databases provide usually transactions to avoid this. It is
possible to make the read/change/write sequence atomic. Couchbase does not
support transactions, it is not a relational database and it is not its goal.

A first possibility, pessimistic and usual, would be to use a *mutex* to protect
the critical section. This critical section begins at the document search and
ends at the document write. This section could be executed by one and only one
thread at a time. The problem is that this section is the whole payload of the
thread. Furthermore, it would be a waste to forbid two parallel execution when
the needed document is not the same. At the end, it would mean to have several
threads executing a linear flow.

A second possibility is to lock the document at read time and to unlock it at
write time. We would also have to check that a non existing document at read
time still does not exist when we write it otherwise the thread would have to
restart from the begining because another thread created the document in the
meantime. This implementation would avoid overwritings and would lead to an
acceptable parallel execution rate, but it also use a lot of CPU cycles on the
cluster side (with locks) and on the client side (with the conflict management).
It could be interesting if we know in advance that there will be a lot of
collisions as it would avoid the collisions before they actually happen thanks
to the locks.

The third possibility is optimistic. It considers that there will be collisions,
but that there will be few collisions. It will not protect "a priori" against
potential collisions but will accept to spend extra time to fix the collision
when it happens. The thread will search for the document if it exists, read it
with its serial number (CAS), alter it and write it back if the serial number
wasn't change meanwhile. If the document did not exist, it will be created and
written in *insert only* mode. So, if the serial number changed during the
critical section or if the document was created by another thread, it will
trigger an exception that will have to deal with the collision : restart from
the begining of the critical section until it succeed.

In our import, the informations are sorted by Country/Indicator/Year bloc. There
are collision risk but not too high. We should use an optimistic implementation
(even if I try to be prepared for the worst, I am still optimistic).

We have to change our `Observer`... But not too much, because the `get` method
already gets the serial number attached to the document and the `replace` method
already takes care of it when it is defined. We only have to use the `insert`
method instead of the `upsert` one in case of a new document to trigger an
exception when the document was created by another thread. :

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

Indexing
========

The dataset is loaded. We will create few general purpose indexes to be able to
use it. Instead of sending commands from the application, I found easier to
execute the SQL queries from the command line tool `/opt/couchbase/bin/cbq` :


```sh
/opt/couchbase/bin/cbq
```

The very first index is a general index. The second one is the primary index,
mandatory to execute *N1QL* queries, it indexes the document's primary keys (to
have the list of the documents). Then, the two last are the most probably needed
index to use our dataset. *GSI* means *Global Secondary Index*, it is a new
centralized index type introduced in 4.0 used by *N1QL*.

```sql
CREATE PRIMARY INDEX ON default;
CREATE PRIMARY INDEX ON WorldDevelopmentIndicators;
CREATE INDEX Year ON WorldDevelopmentIndicators(Year) USING GSI;
CREATE INDEX CountryCode ON WorldDevelopmentIndicators(CountryCode) USING GSI;
```

Voilà
=====

We now have a dataset which is both rich and big enough. We can begin to explore
it with an analysis tool or a reporting tool. But this will be explained in
another post...

[WorldDataBank]: http://databank.worldbank.org/data/reports.aspx?source=world-development-indicators#
[all.csv]: {{site.url}}{{site.baseurl}}/assets/posts/DataLoading/all.csv.zip
[IntelliJ IDEA]: https://www.jetbrains.com/idea/
[SDK JAVA Couchbase]: http://developer.couchbase.com/documentation/server/4.0/sdks/java-2.2/download-links.html
[Apache Commons CSV]: https://commons.apache.org/proper/commons-csv/
[Couchbase-RxImporter]: https://github.com/fcerbell/Couchbase-RxImporter
[ReactiveX]: http://reactivex.io/
