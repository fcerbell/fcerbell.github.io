---
uid: NoSQLReportingIntroduction
author: fcerbell
title: Introduction to NoSQL reporting
layout: post
lang: en
#description:
#category: Test
#categories
#tags
#date
published: true
---

Whatever the database technology is, there is a business application using it
and there is most of the time a reporting need on the business data. I will try
to introduce how to design a reporting architecture, the concepts are applicable
to relational SQL databases and to non-relational NOSQL databases either.  There
are two distinct reporting needs : the operational reporting, which applies to
live operational data to create operational reports such as invoices, order
forms, assets inventories, and so on, and the business intelligence reporting
which is higher level reporting to give trends and to help people to take
decisions. In this first post, I'll try to explain the reporting general
concepts.


* TOC
{:toc}

# Operational reporting

This reporting is directly used by the business application to deliver
operational reports on the live data. The business needs this kind of reports.
As an example, if the business is to plan train travels, the business
application enables to find a train route for the user with appropriate date
and time, then to book the train and to charge the user's bank account. At the
end, the application needs to emit a ticket, which is an operational report. If
the business is to send parcels to customers, then a label has to be printed
depending on the size, weight, destination, preferred delivery service,
delivery level, sometimes with a specific barcode that need to be readable by
the delivery service optical readers.

In this context, the reporting is fully integrated into the business
application and is part of it. The application data model was designed for the
processing and the delivering of the train tickets. The report processing can
be either developped in the application, or a third party library embedded into
the application, or it can be a standalone third party reporting application.
Some third party tools can be embedded, other cannot, some are specific (stream
oriented or query oriented).

## Source data passed

Whatever the archiecture is, the reporting code needs to have the source data
to create the report. In this first case, the source data is queried or
generated by the application and passed to the reporting code (legacy, embedded
or externalized). This case is quite simple as the business application already
knows the business concepts, the business objects, the data model used in
the database. It also knows the needed source data to generate the report and
knows how to generate it (from queries or from computation).

So, the application eventually queries the data storage, using the usual API,
and pass to the reporting function the source data, the report template and the
output format to generate the report.

## Source data queried

In this second use case, the business application passes very few information
to the reporting function (internal, embedded or external), it will be up to
this reporting function to use the information to build the report, which means
that the reporting function needs to be able to compute the source data from
the information or to generate and execute a query on the data storage to get
its source data. This logic is usually included in the report template, it is
not supposed to be a business logic, but more a data access logic. An invoice
template does not need to know what is an invoice, but it has to know where to
find the invoice number, the customer's name and address, the item lines with
their prices, the VAT, and to know where to place them in the output report.

This use case is quite different as the reporting function needs to be able to 
access the data in the data storage. It needs to know how to create a query,
how to execute it, how to read the resultset. The stream based reporting tools
are not really concerned here, but all the query based one are.

Some reporting tools can be extended to learn how to generate queries, how to
execute them and how to understand their resultsets. Most of the time, they are
opensource reporting software such as Tibco's [JasperReports][] library or
[Pentaho][].  But a lot of reporting tools can not be extended, they are
provided with a set of connectors, period. The only flexibility for these tools
is provided with some generic connectors, most of the time an ODBC[^4]
connector, a JDBC[^5] connector, a CSV file connector, an XLS file connector
and an XML[^7] file connector, sometimes there are also an XML webservice
connector, and an ODBO[^1] connector.

Basically, it means that the report can use an SQL query, an XPath query, a
flat (no joins) filter on CSV, a legacy query on XLS, or an MDX[^8] query on an
OLAP[^3] datasource, but nothing else. When the source data are stored in any other
storage (key-value, JSON, graph, wide-columns, ...), there will be an issue.
Hopefully, some NOSQL databases provide a SQL interface, such as N1QL for
[Couchbase][].

# Business intelligence reporting

In the business intelligence reporting, the business application does not need
to provide the source data and ask the function to generate a predefined report
from a report template. Most of the time, the application provides a source data
connection and let the user create his own analysis. It means that the reporting
function needs to be able to connect to the data source to execute a predefined
query, or to generate an AdHoc query to return the exact resultset asked by the
user, leveraging the underlying data storage technology by pushing down the
aggregations and filters.

![BI Architecture][]
[BI Architecture][]

## Live, on-line operational data

In business intelligence reporting, there is a commonly accepted architecture.
The operational live data are stored in databases, historically relational
SQL databases and the data are normalized. These are live data, online data.

## The Operational Data Store (ODS[^11])

Then, they are pushed to an ODS (Operational Data Store) which is usually a
relational SQL database, too, with a normalized schema. It can store some
chosen historical data. The idea is to feed it enough (usually using an ETL[^9]
or ELT[^10] tool) to be able to feed the next level and to empty it. As an
example, the ODS can be fed daily, then it is used to feed the data warehouse
(DWH) and it is cleaned to begin a new month.

## The Datawarehouse (DWH[^12])

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
(KPI[^14]). Common dimensions are a time dimension, and a geographic
dimensions, but there are a lot of other dimensions implemented in the DWH,
depending on the business (sales territory, sales market, customer
segmentation, product category, product line, economic regions, ...). We will
focus on the geographic and time dimensions as they are typical BI[^15] 
dimensions.

A dimension is made of hierarchies. Why hierarchies and not hierarchy ? Because
if there was only one hierarchy, there would be no dimension need ! Dimensions
are a concept, hierarchies are implementations. 

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

In the time dimension, the *Date* level can store extra information such as
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
smaller granularity (the day) grouping (and duplicating) alltogether the year,
half, quarter, month and day information. This makes the records bigger and
duplicated, but minimize the hops (joins) and provide better performances with
relevant indexes (at the price of even more disk space needed).

### Facts tables

The fact tables are simpler to understand. There is one fact table to store all
preaggregated KPIs which share the same hierarchies. Each record is the KPIs
aggregation at the cross of the hierarchies. Given our example, if some KPIs
are sharing the Year/Month/Date and the Continent/Country/City hierarchy, there
would eventually be records for each Date/City combination that has a KPI
value. If there is no KPI value for a specific Date/City combination, there
will be no fact record for this combination.  That's why useless levels and
granularities should be avoided, it leads to disk space useage and to extra
computation when asking for useful granularity aggregations, ie storing hourly
data leade to 24*NbCities more records and there will always be a computation
for the daily aggregation which is the lowest level asked by the business,
instead of saving space and having immediate static results.

It is very common to have holes in the fact tables, there can be no existing
aggregated value for all the hierarchy level combinations. A city can exist in
the reference tables, but we have no customer there. All the dates could exist
(and most of the time, should) in the time dimension hierarchies, even if there
was no sale at a specific date : no sale occured at a specific date, for a
specific city and there will be no record for this combination in the fact
table. If we consider the DWH as an hyper-cube, it is very often full of ...
holes !

Obviously, a datawarehouse can be very big as it could contain a record for all
the hierarchies lowest granularity combination. With 10 KPIs only, and two
dimensions (and only one hierarchy in each) : 100 cities and a single year of
historical data, you will have 100x365=36,500 records.

## The Datamarts (DMT[^14])

Datamarts are often called hyper-cubes. There can be several datamarts built
from a single data warehouse. They can be built and rebuilt on demand and are
often wiped/rebuild by a nightly batch, with a frequency related to the
datawarehouse refresh frequency. Each datamart contains only a consistent
subset of the data warehouse, with one or few fact tables sharing the same
hierarchies that need to be compared together, at the business requested
granularity. It is possible to preaggregate KPI values in a datamart at a higher
level than in the datawarehouse. If the business user wants to zoom in the data
at a lower granularity, the analytic tool will *drill-through* by using the
datawarehouse data. A datamart is designed to provide consistent data, which are
comparables (same hierarchies), to answer to targetted business questions as
fast as possible. They are usually stored in a dedicated storage engine
(MOLAP[^16]), a relational storage engine with a star or snowflake schema
(ROLAP[^17]), or an hybrid storage (HOLAP[^18]) which can store preaggregated
intermediate levels. The datamarts can be seen as datasources designed to be
used in a pivot table. Some of the datamart storage provide a dedicated query
language : MDX, an SQL like query language for multi-dimensional data, often
transmitted over the network using XMLA protocol.

MDX sample :

~~~
SELECT
   { [Measures].[Store Sales] } ON COLUMNS,
   { [Date].[2002], [Date].[2003] } ON ROWS
FROM Sales
WHERE ( [Store].[USA].[CA] )
~~~

[BI Architecture]:{{site.url}}{{site.baseurl}}/assets/posts/NoSQLReportingIntroduction/BIArch_en.png "Business Intelligence Architecture"
[Couchbase]: http://www.couchbase.com "Couchbase website"
[JasperReports]: http://community.jaspersoft.com/project/jasperreports-library "JasperReports Library page"
[Pentaho]: https://www.pentaho.com "Pentaho website"
[^1]: ODBO (OLE DB for OLAP) is a connector type to connect to multi-dimensional data-sources
[^2]: OLE (Object Linking and Embedding) is a way to embed a copy of an object into another object or to create a link to a shared object from another object
[^3]: OLAP (OnLine Analytic Processing) : Multi-dimensional data manipulation
[^4]: ODBC (Open DataBase Connectivity) : a generic type of SQL database connector specification (Microsoft eco system)
[^5]: JDBC (Java DataBase Connectivity) : a generic type of SQL database connector specification for JAVA (cross platform)
[^6]: XMLA (XML for Analytics) : an XML specification specialized for analytics
[^7]: eXtensible Markup Language : Text based data exchange format 
[^8]: MDX (MultiDimensional eXpressions) : An SQL-like query language optimized to query multi-dimensional data-sources.
[^9]: ETL (Extract, Transform and Load) : Application that takes data from a datasource, transform them (aggregation, validation, ...) and loads them into a datasink
[^10]: ELT (Extract, Load and Transform) : Application that takes data from a datasource, inject them unchanged into a datasink and transform them (aggregation, validation, ...) using the sink manipulation tools
[^11]: ODS (Operational Data Store), temporary staging area to store operational data before pre-aggregation
[^12]: DWH (Data WareHouse), persistent area to store historical aggregates in a denormalized schema
[^13]: DMT (DataMart), persistent but ephemer area to store multi-dimensional hypercubes to create analysis
[^14]: KPI (Key Performance Indicator), Indicator
[^15]: BI (Business Intelligence)
[^16]: MOLAP (Multidimensional OLAP), storage engine optimized for OLAP
[^17]: ROLAP (Relational OLAP), OLAP storage engine in relational database
[^18]: HOLAP (Hybrid OLAP), Hybrid storage engine with several level of preaggregation