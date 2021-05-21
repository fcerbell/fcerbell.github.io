---
uid: ConfigureJDBCForCouchbase
title: Configure JDBC for Couchbase
description:
category: Computers
tags: [ JDBC, Couchbase ]
---

Here, we will see how to download, install, configure and use Simba's JDBC
driver for Couchbase. We will test the connection with SQuirreLSQL and the
driver will be configured for any other incomming connection.

You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/kK4GxAwJKD0" frameborder="0" allowfullscreen></iframe></center>

# Prerequisites

I assume that you already have a working Couchbase cluster, even a single-node
cluster. As the JDBC driver relies on N1QL, you need to have a sample dataset,
the index service running on one of your cluster nodes, the query service
running on one of your cluster nodes, and a primary index.

# About the JDBC driver

Couchbase does not develop the JDBC and the ODBC drivers by itself. Simba is a
company that developed ODBC/JDBC drivers for a long time. Their drivers can
translate SQL queries into NoSQL specific languages and can handle themselves
the missing features on client (driver) side. In the case of Couchbase, the
task is easier because Couchbase provides a SQL like feature (N1QL) that is
very close to standard SQL in terms of syntax, grammar and features. Basically,
it means that most of a standard SQL query can be pushed down to a Couchbase
cluster and very few features need to be processed on client side, lowering the
overhead.

# Download the driver

The very first step is to go to Simba's website, to choose the right driver, to
register for a 30 days evaluation and to download the bits. You will receive an
email with a temporary license file to activate the driver.

Connect your browser to the [Driver's description page][SimbaWebSite][^1] on
Simba's website.

Then, you need to clic on the *Download now (30 days free trial)* to choose and
add the relevant driver to your cart. I chose the *JAVA (JDBC)* driver here.
Simba provides a driver for JDK from 1.6 and another for JDK from 1.7 in the
same package.  Then, you can clic on *Proceed to checkout* for your $0.00 cart!
;) You will be asked for personal details and email. Then, Simba will send you
three emails: 

* a welcome message

* a license file:

![Simba's license file][01-SimbaLicenseEmail.png]

* a driver download link:

![Driver download link][02-SimbaDownloadEmail.png]

I suggest that you create a new folder to store both the driver and the license
files. Then, save the license file and download the driver files in this
folder.

The driver is downloaded in a compressed archive that you should uncompress
using your favorite tool. You'll find two other compressed archives inside,
which are the different versions of the driver. I suggest to uncompress them
too. You should end with the following folder structure:

![Driver's Folders][03-FolderStructure.png]

You got everything needed to install the driver in your favorite SQL-only
application. All the information that I used to write this post are available
in the included PDF documentations, **I strongly recommend to read the driver
PDF documentation** because I only use a subset of the available features.

# Install the licence

The Simba JDBC drivers search for the license file in their own folder and in
your home directory. I hate to have garbages at the root of my home directory,
so I suggest that we deploy the license file in the driver's folder. You only
need to copy the license file (without renaming it) in the two driver version
folders :

![License file installation][04-LicensefileInstallation.png]

# Install SQuirreLSQL

Next, the idea is to have a SQL-only client. There are so many... I chose to
use SQuirreLSQL because it is lightweight and easy to install. I used it and
still use it quite often, at least to quick check the JAVA connection strings. 

You can find and download SQuirreLSQL for your platform on [SQuirreLSQL
website][SQuirreLSQLWebsite]. You will get an installer in a JAR file for your
platform. You should be able to execute is by double clicking on it from your
favorite file browser or by entering the command given on the download page in
a shell. You need to have a working JDK installed.

# Add the driver to SQuirreLSQL

Once SQuirreLSQL is installed, it does not know Couchbase as a potential SQL
datasource. So, we have to add the Couchbase JDBC driver in his driver list.
Open the *Drivers* tab on the left side of the main window and clic on the *Add
a new driver* button:

![Squirrel Add a new driver button][05-SquirrelAddDriverButton.png]

Then, you have to enter a driver name, I suggest *Couchbase*, a connection
string example that will help you each time you will create a new connection, I
suggest to have a very simple one such as
`jdbc:couchbase://localhost:8093/default`, the website field is optional, you
need to enter the driver class name which is
`com.simba.couchbase.jdbc4.Driver` if you use a JDK version older than 1.7, or
`com.simba.couchbase.jdbc41.Driver` if your JDK version is newer. Finally, you
have to use the *Add* button in the *Extra Class Path* tab to add all the
driver's JAR files from either the *CouchbaseJDBC41* or *CouchbaseJDBC4*
folder: 

![Squirrel Add a new driver Dialog][06-SquirrelAddDriverDialog.png]

SQuirreLSQL knows our driver and can now use it to create a connection.

# Create the database schema description file

Couchbase is NOSQL, and does not store the data in tables, with a physical
existence. SQL queries work on tables, so we have to provide logical or virtual
tables to the JDBC driver in order to execute SQL queries. We have to define a
mapping between the JSON documents stored in Couchbase and virtual tables,
without any real physical existence, to execute SQL queries. This definition is
called a schema. 

A JDBC driver can be used in JAVA development, when developping a JAVA
application, and could provide an API to create such a schema, but it can also
be used from a end-user application interface. Most of such applications
provide only few fields to pass to the JDBC driver, so Simba chose to use these
few fields to pass statements to create a schema file.

The Simba driver automatically tries to create a default schema, by analyzing a
subset of the stored documents and can use it. Instead of doing this process at
each connection, it is more efficient to store this schema, and eventually to
customize it.

To create a base schema file, we have to create a new connection, with a
connection string including extra properties (or parameters) to dump the schema
file on the filesystem.

We need to open the *Alias* tab, on the left side, and to clic on the *Add a
new alias* button:

![Squirrel Add a new alias button][07-SquirrelAddAliasButton.png]

It opens an *Add Alias* Dialog, in SQuirreLSQL, an Alias is a connection
definition. We will define a connection, and will use the *Test* button to
open/close a connection to Couchbase with the technical parameters, it is
sufficient to create the schema file. So, you have to give it a name, as we
will use the *beer-sample* bucket I suggest to name it with this name, to
choose the *Couchbase* driver that we configured, to edit the connection string
(change the IP address and add the parameters at the end):

![Generate the schema file][08-SquirrelGenerateSchema.png]

When you clic on the *Test* button, it will ask you for a user and password, as
we did not define them in the Alias. It will open a connection, using the
technical parameters to generate a schema and write it to a file. The first
parameter (`SchemaMapOperation=1`) tells to dump the schema to a file on the local
filesystem and the second one (`LocalSchemaFile=/tmp/beers.json`) is the file
path and file name (you can adapt it to your system).  If you want to see how
it looks like without creating it by yourself, you can have a look at [my
beers.json file][beers.json].

# Edit the schema file

You dont need to edit it in our case. The JDBC driver use a document field to
split the documents into virtual tables, the default name for this field is
`type` and, by chance, we have such a field, with this exact meaning. In the
samples, we have three possible values for this field, in each document:
*beer*, *brewery*, and *brewery address*. It menas that the JDBC driver,
without further parameters, identified 3 tables and groupped the documents by
type in these virtual tables. It also parsed a subset of the documents to try
to find all possible fields in each type of documents. In some cases, it might
not scan enough documents to have all the possible fields and you could have to
add them manually in the schema. It is not needed in our case. Once again,
everything is documented. 

Simba provides a schema editor to edit the file. It is in the `SchemaEditor`
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
Should you be curious, here is its key: `~~~SchemaMap`

# Open a standard JDBC SQL connection and play

Well, now, each time that the Simba JDBC driver is used somewhere to connect to
this Couchbase cluster, it will automatically retrieve the schema definition
and use it. So, we can remove all the extra API parameters from the connection
string and save the connection:

![Save the alias][11-SquirrelSaveAlias.png]

It not only saving the alias, but also open a connection using it, so, you
should be connected to the cluster:

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
| [Video] | Demonstration screencast recording |

# Footnotes

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
[Video]: https://youtu.be/kK4GxAwJKD0 "Demonstration video recording"
[^1]: [https://www.magnitude.com/drivers/couchbase-odbc-jdbc][SimbaWebSite]
