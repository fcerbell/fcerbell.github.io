---
uid: PlayingWithRedisAndGeoQueries
title: Playing with Redis and Geo queries
author: fcerbell
layout: post
lang: en
#description:
#category: Test
#categories
#tags
#date: 9999-01-01
published: true
---

While I was searching for sample data to play with in Redis, I
discovered not only a good sample dataset but also a feature to
play with. The dataset contains Lat/Lon/Alt values and Redis has
powerful and interesting geo operations. This post describe a
way to bulk load data airports, airlines and routes with indexes
into Redis^e Pack (Enterprise edition previously known as RLEC)
and how to query by distance.

* TOC
{:toc}

# Prerequisites

You need a working Redis server, It can be either [Redis
community edition] or [Redis enterprise edition].

# Getting the dataset

I was searching for a big dataset. This dataset had to cover
more than one country (I have a lot about France), and more than
just EMEA, if possible. Geo data would be nice, it has to be
easily understandable by everyone (Butterfly sexuality study in
Guatemala would not be a goot fit).

I found the [OpenFlights] website with a list of airlines, a
list of airports and a list of routes. Each airport also have
geo data. Unfortunately, it does not include timetables and the
data set is not huge. Anyway, it is still very interesting.

You need to download at least three files from
[GitHub/jpatokal/openflights](https://github.com/jpatokal/openflights):

* airlines.dat
* airports-extended.dat
* routes.dat


# Bulk load

These files are clean CSV files. There are several way to load
them, but I chose to convert them in Redis operations using one
of my favorite tools, *sed*. It would also be possible to write
a small application that reads the files and load them. To be
efficient, a bulk load has to pipeline the commands and to be
asynchronous. In our case, the size is small and I won't care,
maybe later, in another post, with more data to load.

## Data conversion

**I could be a lot more efficient by parsing only once each file
and generate the indices commands together with the data, but I
wanted to be more readable than performant.**

### Data

First of all, for each file, I created a small *sed* script to
convert the file in Redis operations. These three scripts
replace the `null` value with an empty string, remove the
escaped double quotes. The script for the routes also creates an
unique id for each route (*airline/departure/destination*).

**airlines.sed**

``` sed
# Airlines records
 
# Replace NULL values by empty string
s/\\N/""/g
# Remove escaped double quotes from values
s/\\"/'/g

s/^\([^,]*\)/HMSET "airlines:\1"/
s/","/" NAME "/
s/","/" ALIAS "/
s/","/" IATA "/
s/","/" ICAO "/
s/","/" CALLSIGN "/
s/","/" COUNTRY "/
s/","/" ACTIVE "/
```

`sed -f airlines.sed airlines.dat  | head` generates:

```
HMSET "airlines:-1" NAME "Unknown" ALIAS "" IATA "-" ICAO "N/A" CALLSIGN "" COUNTRY "" ACTIVE "Y"
HMSET "airlines:1" NAME "Private flight" ALIAS "" IATA "-" ICAO "N/A" CALLSIGN "" COUNTRY "" ACTIVE "Y"
HMSET "airlines:2" NAME "135 Airways" ALIAS "" IATA "" ICAO "GNL" CALLSIGN "GENERAL" COUNTRY "United States" ACTIVE "N"
HMSET "airlines:3" NAME "1Time Airline" ALIAS "" IATA "1T" ICAO "RNX" CALLSIGN "NEXTIME" COUNTRY "South Africa" ACTIVE "Y"
HMSET "airlines:4" NAME "2 Sqn No 1 Elementary Flying Training School" ALIAS "" IATA "" ICAO "WYT" CALLSIGN "" COUNTRY "United Kingdom" ACTIVE "N"
HMSET "airlines:5" NAME "213 Flight Unit" ALIAS "" IATA "" ICAO "TFU" CALLSIGN "" COUNTRY "Russia" ACTIVE "N"
HMSET "airlines:6" NAME "223 Flight Unit State Airline" ALIAS "" IATA "" ICAO "CHD" CALLSIGN "CHKALOVSK-AVIA" COUNTRY "Russia" ACTIVE "N"
HMSET "airlines:7" NAME "224th Flight Unit" ALIAS "" IATA "" ICAO "TTF" CALLSIGN "CARGO UNIT" COUNTRY "Russia" ACTIVE "N"
HMSET "airlines:8" NAME "247 Jet Ltd" ALIAS "" IATA "" ICAO "TWF" CALLSIGN "CLOUD RUNNER" COUNTRY "United Kingdom" ACTIVE "N"
HMSET "airlines:9" NAME "3D Aviation" ALIAS "" IATA "" ICAO "SEC" CALLSIGN "SECUREX" COUNTRY "United States" ACTIVE "N"
```

**airports.sed**

```sed
# Airports data

# Replace NULL values by empty string
s/\\N/""/g
# Remove escaped double quotes from values
s/\\"/'/g

s/^\([^,]*\)/HMSET "airports:\1"/
s/","/" NAME "/
s/","/" CITY "/
s/","/" COUNTRY "/
s/","/" IATA "/
s/","/" ICAO "/
s/",/" LATITUDE "/
s/,/" LONGITUDE "/
s/,/" ALTITUDE "/
s/,"/" TIMEZONE "/
s/","/" DST "/
s/","/" TZDB "/
s/","/" TYPE "/
s/","/" SOURCE "/
```

`sed -f airports.sed airports-extended.dat | head` generates:

```
HMSET "airports:1" NAME "Goroka Airport" CITY "Goroka" COUNTRY "Papua New Guinea" IATA "GKA" ICAO "AYGA" LATITUDE "-6.081689834590001" LONGITUDE "145.391998291" ALTITUDE "5282,10" TIMEZONE "U" DST "Pacific/Port_Moresby" TZDB "airport" TYPE "OurAirports"
HMSET "airports:2" NAME "Madang Airport" CITY "Madang" COUNTRY "Papua New Guinea" IATA "MAG" ICAO "AYMD" LATITUDE "-5.20707988739" LONGITUDE "145.789001465" ALTITUDE "20,10" TIMEZONE "U" DST "Pacific/Port_Moresby" TZDB "airport" TYPE "OurAirports"
HMSET "airports:3" NAME "Mount Hagen Kagamuga Airport" CITY "Mount Hagen" COUNTRY "Papua New Guinea" IATA "HGU" ICAO "AYMH" LATITUDE "-5.826789855957031" LONGITUDE "144.29600524902344" ALTITUDE "5388,10" TIMEZONE "U" DST "Pacific/Port_Moresby" TZDB "airport" TYPE "OurAirports"
HMSET "airports:4" NAME "Nadzab Airport" CITY "Nadzab" COUNTRY "Papua New Guinea" IATA "LAE" ICAO "AYNZ" LATITUDE "-6.569803" LONGITUDE "146.725977" ALTITUDE "239,10" TIMEZONE "U" DST "Pacific/Port_Moresby" TZDB "airport" TYPE "OurAirports"
HMSET "airports:5" NAME "Port Moresby Jacksons International Airport" CITY "Port Moresby" COUNTRY "Papua New Guinea" IATA "POM" ICAO "AYPY" LATITUDE "-9.443380355834961" LONGITUDE "147.22000122070312" ALTITUDE "146,10" TIMEZONE "U" DST "Pacific/Port_Moresby" TZDB "airport" TYPE "OurAirports"
HMSET "airports:6" NAME "Wewak International Airport" CITY "Wewak" COUNTRY "Papua New Guinea" IATA "WWK" ICAO "AYWK" LATITUDE "-3.58383011818" LONGITUDE "143.669006348" ALTITUDE "19,10" TIMEZONE "U" DST "Pacific/Port_Moresby" TZDB "airport" TYPE "OurAirports"
HMSET "airports:7" NAME "Narsarsuaq Airport" CITY "Narssarssuaq" COUNTRY "Greenland" IATA "UAK" ICAO "BGBW" LATITUDE "61.1604995728" LONGITUDE "-45.4259986877" ALTITUDE "112,-3" TIMEZONE "E" DST "America/Godthab" TZDB "airport" TYPE "OurAirports"
HMSET "airports:8" NAME "Godthaab / Nuuk Airport" CITY "Godthaab" COUNTRY "Greenland" IATA "GOH" ICAO "BGGH" LATITUDE "64.19090271" LONGITUDE "-51.6781005859" ALTITUDE "283,-3" TIMEZONE "E" DST "America/Godthab" TZDB "airport" TYPE "OurAirports"
HMSET "airports:9" NAME "Kangerlussuaq Airport" CITY "Sondrestrom" COUNTRY "Greenland" IATA "SFJ" ICAO "BGSF" LATITUDE "67.0122218992" LONGITUDE "-50.7116031647" ALTITUDE "165,-3" TIMEZONE "E" DST "America/Godthab" TZDB "airport" TYPE "OurAirports"
HMSET "airports:10" NAME "Thule Air Base" CITY "Thule" COUNTRY "Greenland" IATA "THU" ICAO "BGTL" LATITUDE "76.5311965942" LONGITUDE "-68.7032012939" ALTITUDE "251,-4" TIMEZONE "E" DST "America/Thule" TZDB "airport" TYPE "OurAirports"
```

**routes.sed**

```sed
# All routes ID

# Replace NULL values by empty string
s/\\N/""/g
# Remove escaped double quotes from values
s/\\"/'/g
# Remove double quotes from empty strings
s/""//g

# First build a unique route id as the first field
s/\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)/\1\3\5,&/

s/^\([^,]*\)/HMSET "routes:\1"/
s/",/" AIRLINE "/
s/,/" AIRLINEID "/
s/,/" SRCAIRPORT "/
s/,/" SRCAIRPORTID "/
s/,/" DSTAIRPORT "/
s/,/" DSTAIRPORTID "/
s/,/" CODESHARE "/
s/,/" STOPS "/
s/,/" EQUIPEMENT "/
s/\r/"&/
```

`sed -f routes.sed routes.dat | head` generates:

```
HMSET "routes:2BAERKZN" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "AER" SRCAIRPORTID "2965" DSTAIRPORT "KZN" DSTAIRPORTID "2990" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BASFKZN" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "ASF" SRCAIRPORTID "2966" DSTAIRPORT "KZN" DSTAIRPORTID "2990" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BASFMRV" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "ASF" SRCAIRPORTID "2966" DSTAIRPORT "MRV" DSTAIRPORTID "2962" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BCEKKZN" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "CEK" SRCAIRPORTID "2968" DSTAIRPORT "KZN" DSTAIRPORTID "2990" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BCEKOVB" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "CEK" SRCAIRPORTID "2968" DSTAIRPORT "OVB" DSTAIRPORTID "4078" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BDMEKZN" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "DME" SRCAIRPORTID "4029" DSTAIRPORT "KZN" DSTAIRPORTID "2990" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BDMENBC" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "DME" SRCAIRPORTID "4029" DSTAIRPORT "NBC" DSTAIRPORTID "6969" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BDMETGK" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "DME" SRCAIRPORTID "4029" DSTAIRPORT "TGK" DSTAIRPORTID "" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BDMEUUA" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "DME" SRCAIRPORTID "4029" DSTAIRPORT "UUA" DSTAIRPORTID "6160" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BEGOKGD" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "EGO" SRCAIRPORTID "6156" DSTAIRPORT "KGD" DSTAIRPORTID "2952" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
```

### Primary indices

Having data is fine, but I want to wuery the data, and to search
them for a flight or an airport. So, I need some indices. Even
if it would be possible to use the (evil) `key` command to
get all the airport, airlines or route keys, I preferred to
create a primary index, using a simple `set` data type, for each
file. You can notice than Iused `{` and `}` to store all the
indices in the same redis shard. Thus, I'll be able to execute
some commands such as `*DIFF` between indexes. It is a case by
case design choice.

I used the following *sed* scripts:

**airlines_idx.sed**

```sed
# All airlines ID
s/^\([^,]*\).*/SADD "{idx}airlines_Id" "\1"/
```

`sed -f airlines_idx.sed airlines.dat | head` generates:

```
SADD "{idx}airlines_Id" "-1"
SADD "{idx}airlines_Id" "1"
SADD "{idx}airlines_Id" "2"
SADD "{idx}airlines_Id" "3"
SADD "{idx}airlines_Id" "4"
SADD "{idx}airlines_Id" "5"
SADD "{idx}airlines_Id" "6"
SADD "{idx}airlines_Id" "7"
SADD "{idx}airlines_Id" "8"
SADD "{idx}airlines_Id" "9"
```

**airports_idx.sed**

```sed
# All airports ID
s/^\([^,]*\).*/SADD "{idx}airports_Id" "\1"/
```

`sed -f airports_idx.sed airports-extended.dat | head` generates:

```
SADD "{idx}airports_Id" "1"
SADD "{idx}airports_Id" "2"
SADD "{idx}airports_Id" "3"
SADD "{idx}airports_Id" "4"
SADD "{idx}airports_Id" "5"
SADD "{idx}airports_Id" "6"
SADD "{idx}airports_Id" "7"
SADD "{idx}airports_Id" "8"
SADD "{idx}airports_Id" "9"
SADD "{idx}airports_Id" "10"
```

**routes_idx.sed**

```sed
# All routes ID
# Replace NULL values by empty string
s/\\N/""/g
# Remove escaped double quotes from values
s/\\"/'/g
# Remove double quotes from empty strings
s/""//g
# First build a unique route id as the first field
s/\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)/\1\3\5,&/
s/^\([^,]*\).*/SADD "{idx}routes_Id" "\1"/
```

`sed -f routes.sed routes.dat | head` generates:

```
HMSET "routes:2BAERKZN" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "AER" SRCAIRPORTID "2965" DSTAIRPORT "KZN" DSTAIRPORTID "2990" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BASFKZN" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "ASF" SRCAIRPORTID "2966" DSTAIRPORT "KZN" DSTAIRPORTID "2990" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BASFMRV" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "ASF" SRCAIRPORTID "2966" DSTAIRPORT "MRV" DSTAIRPORTID "2962" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BCEKKZN" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "CEK" SRCAIRPORTID "2968" DSTAIRPORT "KZN" DSTAIRPORTID "2990" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BCEKOVB" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "CEK" SRCAIRPORTID "2968" DSTAIRPORT "OVB" DSTAIRPORTID "4078" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BDMEKZN" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "DME" SRCAIRPORTID "4029" DSTAIRPORT "KZN" DSTAIRPORTID "2990" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BDMENBC" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "DME" SRCAIRPORTID "4029" DSTAIRPORT "NBC" DSTAIRPORTID "6969" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BDMETGK" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "DME" SRCAIRPORTID "4029" DSTAIRPORT "TGK" DSTAIRPORTID "" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BDMEUUA" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "DME" SRCAIRPORTID "4029" DSTAIRPORT "UUA" DSTAIRPORTID "6160" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
HMSET "routes:2BEGOKGD" AIRLINE "2B" AIRLINEID "410" SRCAIRPORT "EGO" SRCAIRPORTID "6156" DSTAIRPORT "KGD" DSTAIRPORTID "2952" CODESHARE "" STOPS "0" EQUIPEMENT "CR2"
```

### Secondary indices

Primary indices are perfect to get the list of specific keys,
but it is quite useless. I'd like to find specific values
depending on fun fields. Here come the secondary indices.

Given that the airports have geographic location data, I wanted
to play with these. I don't want to learn and remember the
airport's technical ids, but I am quite used to use IATA and
ICAO (OACI here, in France) codes.

So, I made *sed* scripts to index the IATA codes with their GPS
position and the ICAO codes with their GPS position. I naturally
chose a GeoIndex (which is internally a `set`). Note that the
provided latitude and longitude values are not in the expected
order.

So, I should be able to query the distance between two
airports... Not exactly, I can only run this query if both
airports have an IATA code or if both have an ICAO code, but
some of them have only one and an ICAO-only airport will not be
in the GeoByIATA index. I also created a Geo index by airport
technical ID, which will be a fallback. And I need to create
also two more indices to find technical IDs by IATA or by ICAO
code.

Here are the scripts:

**airports_GeoByIATA.sed**

```sed
# GeoIndexing airports by IATA
# Replace NULL values by empty string
s/\\N/""/g
# Remove escaped double quotes from values
s/\\"/'/g
# Removes lines with incorrect GeoData
s/^.*-90,0.*$//g
s/^\([^,]*\),"\([^"]*\)","\([^"]*\)","\([^"]*\)","\([^"]*\)","\([^"]*\)",\([^,]*\),\([^,]*\),\([^,]*\),.*/GEOADD "{idx}airports_GeoByIATA" "\8" "\7" "\5"/
```

`sed -f airports_GeoByIATA.sed airports-extended.dat | head` generates:

```
GEOADD "{idx}airports_GeoByIATA" "145.391998291" "-6.081689834590001" "GKA"
GEOADD "{idx}airports_GeoByIATA" "145.789001465" "-5.20707988739" "MAG"
GEOADD "{idx}airports_GeoByIATA" "144.29600524902344" "-5.826789855957031" "HGU"
GEOADD "{idx}airports_GeoByIATA" "146.725977" "-6.569803" "LAE"
GEOADD "{idx}airports_GeoByIATA" "147.22000122070312" "-9.443380355834961" "POM"
GEOADD "{idx}airports_GeoByIATA" "143.669006348" "-3.58383011818" "WWK"
GEOADD "{idx}airports_GeoByIATA" "-45.4259986877" "61.1604995728" "UAK"
GEOADD "{idx}airports_GeoByIATA" "-51.6781005859" "64.19090271" "GOH"
GEOADD "{idx}airports_GeoByIATA" "-50.7116031647" "67.0122218992" "SFJ"
GEOADD "{idx}airports_GeoByIATA" "-68.7032012939" "76.5311965942" "THU"
```

**airports_GeoByICAO.sed**

```sed
# GeoIndexing airports by ICAO
# Replace NULL values by empty string
s/\\N/""/g
# Remove escaped double quotes from values
s/\\"/'/g
# Removes lines with incorrect GeoData
s/^.*-90,0.*$//g
s/^\([^,]*\),"\([^"]*\)","\([^"]*\)","\([^"]*\)","\([^"]*\)","\([^"]*\)",\([^,]*\),\([^,]*\),\([^,]*\),.*/GEOADD "{idx}airports_GeoByICAO" "\8" "\7" "\6"/
```

`sed -f airports_GeoByICAO.sed airports-extended.dat | head` generates:

```
GEOADD "{idx}airports_GeoByICAO" "145.391998291" "-6.081689834590001" "AYGA"
GEOADD "{idx}airports_GeoByICAO" "145.789001465" "-5.20707988739" "AYMD"
GEOADD "{idx}airports_GeoByICAO" "144.29600524902344" "-5.826789855957031" "AYMH"
GEOADD "{idx}airports_GeoByICAO" "146.725977" "-6.569803" "AYNZ"
GEOADD "{idx}airports_GeoByICAO" "147.22000122070312" "-9.443380355834961" "AYPY"
GEOADD "{idx}airports_GeoByICAO" "143.669006348" "-3.58383011818" "AYWK"
GEOADD "{idx}airports_GeoByICAO" "-45.4259986877" "61.1604995728" "BGBW"
GEOADD "{idx}airports_GeoByICAO" "-51.6781005859" "64.19090271" "BGGH"
GEOADD "{idx}airports_GeoByICAO" "-50.7116031647" "67.0122218992" "BGSF"
GEOADD "{idx}airports_GeoByICAO" "-68.7032012939" "76.5311965942" "BGTL"
```

**airports_GeoById.sed**

```sed
# GeoIndexing airports by Id (All airports have Id, but not always IATA or ICAO)
# Replace NULL values by empty string
s/\\N/""/g
# Remove escaped double quotes from values
s/\\"/'/g
# Removes lines with incorrect GeoData
s/^.*-90,0.*$//g
s/^\([^,]*\),"\([^"]*\)","\([^"]*\)","\([^"]*\)","\([^"]*\)","\([^"]*\)",\([^,]*\),\([^,]*\),\([^,]*\),.*/GEOADD "{idx}airports_GeoById" "\8" "\7" "\1"/
```

`sed -f airports_GeoById.sed airports-extended.dat | head` generates:

```
GEOADD "{idx}airports_GeoById" "145.391998291" "-6.081689834590001" "1"
GEOADD "{idx}airports_GeoById" "145.789001465" "-5.20707988739" "2"
GEOADD "{idx}airports_GeoById" "144.29600524902344" "-5.826789855957031" "3"
GEOADD "{idx}airports_GeoById" "146.725977" "-6.569803" "4"
GEOADD "{idx}airports_GeoById" "147.22000122070312" "-9.443380355834961" "5"
GEOADD "{idx}airports_GeoById" "143.669006348" "-3.58383011818" "6"
GEOADD "{idx}airports_GeoById" "-45.4259986877" "61.1604995728" "7"
GEOADD "{idx}airports_GeoById" "-51.6781005859" "64.19090271" "8"
GEOADD "{idx}airports_GeoById" "-50.7116031647" "67.0122218992" "9"
GEOADD "{idx}airports_GeoById" "-68.7032012939" "76.5311965942" "10"
```

**airports_IdByIATA.sed**

```sed
# Indexing airports by IATA
# Replace NULL values by empty string
s/\\N/""/g
# Remove escaped double quotes from values
s/\\"/'/g
s/^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),.*/HSET "{idx}airports_IdByIATA" \5 "\1"/
```

`sed -f airports_IdByIATA.sed airports-extended.dat | head` generates:

```
HSET "{idx}airports_IdByIATA" "GKA" "1"
HSET "{idx}airports_IdByIATA" "MAG" "2"
HSET "{idx}airports_IdByIATA" "HGU" "3"
HSET "{idx}airports_IdByIATA" "LAE" "4"
HSET "{idx}airports_IdByIATA" "POM" "5"
HSET "{idx}airports_IdByIATA" "WWK" "6"
HSET "{idx}airports_IdByIATA" "UAK" "7"
HSET "{idx}airports_IdByIATA" "GOH" "8"
HSET "{idx}airports_IdByIATA" "SFJ" "9"
HSET "{idx}airports_IdByIATA" "THU" "10"
```

**airports_IdByICAO.sed**

```sed
# Indexing airports by ICAO
# Replace NULL values by empty string
s/\\N/""/g
# Remove escaped double quotes from values
s/\\"/'/g
s/^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),.*/HSET "{idx}airports_IdByICAO" \6 "\1"/
```

`sed -f airports_IdByICAO.sed airports-extended.dat | head` generates:

```
HSET "{idx}airports_IdByICAO" "AYGA" "1"
HSET "{idx}airports_IdByICAO" "AYMD" "2"
HSET "{idx}airports_IdByICAO" "AYMH" "3"
HSET "{idx}airports_IdByICAO" "AYNZ" "4"
HSET "{idx}airports_IdByICAO" "AYPY" "5"
HSET "{idx}airports_IdByICAO" "AYWK" "6"
HSET "{idx}airports_IdByICAO" "BGBW" "7"
HSET "{idx}airports_IdByICAO" "BGGH" "8"
HSET "{idx}airports_IdByICAO" "BGSF" "9"
HSET "{idx}airports_IdByICAO" "BGTL" "10"
```
## Actual load

I use `redis-cli` to load my data, but I'd like to be more
efficient and to pipeline the data and I use the `--pipe`
argument to do that. I grouped the following commands in a bash
script:

{% highlight bash %}
#!/bin/bash -x

ENDPOINT="redis-13402.demo.francois.demo-rlec.redislabs.com:13402"

DATAFILE="openflights.redis"
LOGFILE="openflights.log"

REDISCLI="redis-cli -h ${ENDPOINT/:/ -p }"

> $DATAFILE
sed -f airlines.sed airlines.dat >> $DATAFILE
sed -f airlines_idx.sed airlines.dat >> $DATAFILE

sed -f airports.sed airports.dat >> $DATAFILE
sed -f airports_idx.sed airports.dat >> $DATAFILE
sed -f airports_IdByICAO.sed airports.dat >> $DATAFILE
sed -f airports_IdByIATA.sed airports.dat >> $DATAFILE
sed -f airports_GeoById.sed airports.dat >> $DATAFILE
sed -f airports_GeoByIATA.sed airports.dat >> $DATAFILE
sed -f airports_GeoByICAO.sed airports.dat >> $DATAFILE

sed -f countries.sed countries.dat >> $DATAFILE
sed -f countries_idx.sed countries.dat >> $DATAFILE

sed -f routes.sed routes.dat >> $DATAFILE
sed -f routes_idx.sed routes.dat >> $DATAFILE

echo "FLUSHDB" | $REDISCLI > $LOGFILE
cat $DATAFILE | unix2dos | $REDISCLI --pipe 2>&1 | grep -v "^OK"  | grep -v '^1' > $LOGFILE
{% endhighlight %}

# Time to play and query

First of all, I'll start `redis-cli` to connect to my Redis database.  As I
use the enterprise edition, I'll use the endpoint provided by it for my
database.

How to get the distance in KM between Paris Charles de Gaulle (IATA:CDG)and
San Francisco International (IATA:SFO) airports ? Given that both are
commercial and internationals, thay have both an IATA code, thus I'll use tha
geo index by IATA :

```
192.168.56.101:12928> GEODIST {idx}airports_GeoByIATA CDG SFO km
"8964.7389"
```
So easy. Now, I would like to distance between my local airport (ICAO:LFFE) and another
local airport near Paris (ICAO:LFPM). Both are non-commercial and have no IATA
code, only an ICAO code. Thus, I'll use the geoindex by ICAO :

```
192.168.56.101:12928> GEODIST {idx}airports_GeoByICAO LFFE LFPM km
"54.3693"
```

Let's ask for the distance between my local airport (ICAO:LFFE) and Paris
Charles de Gaulle (IATA:CDG). Despite Charles de Gaulle has an ICAO code, I
want to use the IATA code. Unfortunately, the first one is only indexed in the
geoindex by ICAO and the second one by an IATA code... Thus, I'll use the Id
index by ICAO and by IATA to find the technical internal airports ids and then
use the geoindex by id:

```
192.168.56.101:12928> HGET {idx}airports_IdByICAO LFFE
"4303"
192.168.56.101:12928> HGET {idx}airports_IdByIATA CDG
"1382"
192.168.56.101:12928> GEODIST {idx}airports_GeoById 4303 1382 km
"14.8405"
```

I would like to flight from my local airport to somewhere else, but I don't
know where. I am limited to 50 km around my takeoff airport. Let's ask Redis:

```
192.168.56.101:12928> GEORADIUSBYMEMBER {idx}airports_GeoById 4303 50 km WITHDIST
 1) 1) "1385"
    2) "37.4001"
 2) 1) "7838"
    2) "33.1194"
 3) 1) "1387"
    2) "23.4280"
 4) 1) "1388"
    2) "32.4964"
 5) 1) "1386"
    2) "35.9849"
 6) 1) "1380"
    2) "10.7180"
 7) 1) "4303"
    2) "0.0000"
 8) 1) "1382"
    2) "14.8405"
 9) 1) "1367"
    2) "48.6181"
10) 1) "1381"
    2) "26.0118"
11) 1) "8622"
    2) "37.5877"
```

Ok, now, I'm searching for vacation place, but I don't like to spend too much
time in a place and I want to limit my search to 300 km, and only commercial
airports (those with an IATA code):

```
192.168.56.101:12928> GEORADIUSBYMEMBER {idx}airports_GeoByIATA CDG 300 km WITHDIST asc
 1) 1) "CDG"
    2) "0.0000"
 2) 1) "LBG"
    2) "9.2808"
 3) 1) "CSF"
    2) "26.8665"
...
    2) "271.6852"
39) 1) "MSE"
    2) "272.9031"
40) 1) "LUX"
    2) "273.4940"
41) 1) "LGG"
    2) "275.1910"
...
    2) "298.1946"
48) 1) "WOE"
    2) "299.4564"
49) 1) "CER"
    2) "299.8636"
```

Ok, I choose to go to Luxembourg (LUX), which is only 273 km far away, now I
need to find a flight and I love to fly with AirFrance (AF). Is there a direct
flight ?

```
192.168.56.101:12928> HGETALL routes:AFCDGLUX
 1) "AIRLINE"
 2) "AF"
 3) "AIRLINEID"
 4) "137"
 5) "SRCAIRPORT"
 6) "CDG"
 7) "SRCAIRPORTID"
 8) "1382"
 9) "DSTAIRPORT"
10) "LUX"
11) "DSTAIRPORTID"
12) "629"
13) "CODESHARE"
14) "Y"
15) "STOPS"
16) "0"
17) "EQUIPEMENT"
18) "ER4 DH4"
```

Sorry, guys, I need to pack my stuff, I'll send you a postcard...

# Footnotes

[OpenFlights]: http://openflights.org/
[Redis community edition]: http://redis.io
[Redis enterprise edition]: http://redislabs.com
