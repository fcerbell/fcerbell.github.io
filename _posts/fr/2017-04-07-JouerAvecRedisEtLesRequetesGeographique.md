---
uid: PlayingWithRedisAndGeoQueries
title: Jouer avec Redis et les requêtes géographiques
description:
category: Tutos
tags: []
---

Alors que je recherchair un jeu de données pour jouer avec Redis, j'ai non-seulement découvert un bon jeu de données mais aussi une
fonctionnalité ludique. Le jeu de données comtient des valeurs de latitude, longitude et altitude et Redis dispose d'opérations
géographiques puissantes et intéressantes. Cet article décrit un moyen de charger massivement les données des aéroports, des lignes
aériennes et des routes avec des indexes dans Redis^e Pack (édition pour les entreprises anciennement connue sous le nom de RLEC)
et comment les requêter par distance.

* TOC
{:toc}

# Pré-requis

Il vous faut un serveur Redis fonctionnel, cela peut-être soit [Redis community edition] soit [Redis enterprise edition].

# Récupérer le jeu de données

Je recherchais un gros jeu de données. Il devait concerner plus d'un seul pays (J'en ai déjà plusieurs concernant la France), et
plus que l'Europe, si possible. Des données géographiques seraient intéressantes et les données doivent être facilement
compréhensibles par tout le monde (les résultats d'une étude sur la sexualité des papillons au Guatemala ne m'intéresse pas).

J'ai trouvé le site [OpenFlights] avec une lite des lignes aériennes, des aéroports et des routes. Chaque aéroport dispose
également de ses données de localisation géographique. Malheureusement, il n'y a pas les horaires et le jeu de données n'est pas
énorge. Peu importe, il reste tout de même très intéressant.

Il vous faut donc télécharger au moins trois fichiers depuis
[GitHub/jpatokal/openflights](https://github.com/jpatokal/openflights):

* airlines.dat
* airports-extended.dat
* routes.dat


# Chargement massif

Ces fichiers sont des fichiers CSV propres. Il existe de nombreux moyens de les
charger, mais j'ai choisi de les convertir en commandes Redis grâce à un de mes
outils favoris, *sed*. Il serait aussi possible d'écrire une petite application
qui lise les fichiers et les charge. Pour être efficace, un chargement massif
doit placer les commandes dans un *pipeline* et doit soumettre de pipeline
(traitement par lots) de manière asynchrone. Dans notre cas, la taille des
fichiers étant petite je ne m'inquiète pas de cela ; peut-être plus tard dans un
autre article, avec plus de données à charger.

## Conversion des données

**Je pourrais être beaucoup plus efficace en ne parcourant les fichiers qu'une
seule fois et en générant les commandes d'index en même temps que les commandes
de données, mais j'ai privilégié la lisibilité à la performance**

### Données

En premier lieu, pour chaque fichier, je crée un petit script *sed* pour
convertir le fichier en opérations Redis. Ces trois scripts remplacent la valeur
`null` par une chaîne vide, retirent les double apostrophes protégées. Le script
pour les routes crée aussi un identifiant unique pour chaque route
(*airline/departure/destination*).

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

`sed -f airlines.sed airlines.dat  | head` genère:

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

`sed -f airports.sed airports-extended.dat | head` genère:

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

`sed -f routes.sed routes.dat | head` genère:

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

### Index primaires

Disposer des données, c'est bien, mais j'aimerai pouvoir les requêter et y
chercher un vol ou un aéroport. J'ai donc besoin d'index. Même s'il est possible
d'utiliser la commande `key` (diabolique et interdite en production) pour
récupérer la liste des aéroports, des lignes ou des routes, je préfère créer un
index primaire en utilisant un ensemble Redis (`set`) pour chaque fichier. Vous
pouvez remarquer que j'ai utilisé `{` et `}` pour enregistrer tous les index
dans la même instance Redis. Ainsi, je serai en mesure d'exécuter certaines
commandes telles que la famille des `*DIFF` entre les index. C'est une
conception propre à mon cas d'utilisation.

J'ai utilisé les scripts *sed* suivants :

**airlines_idx.sed**

```sed
# All airlines ID
s/^\([^,]*\).*/SADD "{idx}airlines_Id" "\1"/
```

`sed -f airlines_idx.sed airlines.dat | head` produit :

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

`sed -f airports_idx.sed airports-extended.dat | head` produit :

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

`sed -f routes.sed routes.dat | head` génère :

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

### Index secondaires

Les index primaires sont parfait pour obtenir la liste de certaines clés, mais
c'est relativement inutile. J'aimerais pouvoir trouver des valeurs spécifiques
en fonction de certain champs. D'où les index secondaires.

Étant donné que les aéroports disposent de données de localisation
géographiques, j'ai voulu jouer avec. Je ne souhaite pas apprendre et retenir
les identifiants techniques des aéroports, mais je suis relativement habitué aux
codes IATA et OACI.

J'ai donc écrit un script *sed* pour indexer les codes IATA avec leur position
GPS et les codes OACI avec leur position GPS. J'ai naturellement choisi la
structure `GeoIndex` (qui est un `set` en interne). Remarquez que la latitude et
la longitude ne sont pas dans l'ordre attendu.

Je devrais être capable de requêter la distance entre deux aéroports... Pas
exactement, je ne peux exécuter cette requête qu'entre deux aéroports avec un
code IATA ou entre deux aéroports avec un code OACI, mais certains n'en ont
qu'un seul et un aéroport avec uniquement un code OACI ne se trouvera pas dans
l'index GeoByIATA. J'ai créé un index par identifiant technique des aéroports,
ce qui sera une solution de repli. J'ai aussi besoin de créer deux index
supplémentaires pour trouver les identifiants techniques par IATA et par OACI.

Voici les scripts :

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

`sed -f airports_GeoByIATA.sed airports-extended.dat | head` génère :

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

`sed -f airports_GeoByICAO.sed airports-extended.dat | head` génère :

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

`sed -f airports_GeoById.sed airports-extended.dat | head` génère :

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

`sed -f airports_IdByIATA.sed airports-extended.dat | head` génère :

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

`sed -f airports_IdByICAO.sed airports-extended.dat | head` génère :

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

## Chargement réel

J'utilise l'outil en ligne de commande `redis-cli` pour charger mes données,
mais j'aimerais être plus performant et les traiter par lot, j'utilise donc
l'option `--pipe` pour cela. J'ai regroupé les commandes dans un script *bash* :

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

# L'heure de jouer et de requêter

En premier lieu, je lance la commande `redis-cli` pour me connecter à
la base Redis. Comme j'utilise l'édition entreprise, j'utilise le
point d'entrée fourni pour ma base de données.

Comment obtenir la distance en kilomètres entre Paris Charles de
Gaulle (IATA:CDG) et San Francisco International (IATA:SFO) ? Comme
tous les deux sont commerciaux et internationaux, ils disposent tous
les deux d'un code IATA, j'utilise donc l'index par IATA :

```
192.168.56.101:12928> GEODIST {idx}airports_GeoByIATA CDG SFO km
"8964.7389"
```

Tellement simple. Maintenant, j'aimerais la distance entre mon
aéroport local (OACI:LFFE) et un autre aéroport local proche de Paris
(OACI:LFPM). Tous les deux sont non-commerciaux et ne disposent pas de
code IATA, seulement de code OACI. J'utilise donc l'index par code
OACI :

```
192.168.56.101:12928> GEODIST {idx}airports_GeoByICAO LFFE LFPM km
"54.3693"
```

Maintenant, demandons la distance entre mon aéroport local (OACI:LFFE)
et Paris Charles de Gaulles (IATA:CDG). Malgré que Charles de Gaulle
dispose d'un code OACI également, je souhaite utiliser le code IATA.
Malheureusement, le premier aéroport n'est indexé que par son code
OACI et le second par son code IATA... Je vais donc utiliser une
requête pour retrouver les identifiants techniques des deux aéroports
par leur code OACI et IATA, puis requêter l'index géographique par
identifiant technique :

```
192.168.56.101:12928> HGET {idx}airports_IdByICAO LFFE
"4303"
192.168.56.101:12928> HGET {idx}airports_IdByIATA CDG
"1382"
192.168.56.101:12928> GEODIST {idx}airports_GeoById 4303 1382 km
"14.8405"
```

J'aimerais prendre un vol depuis mon aéroport local pour partir
ailleurs, mais je ne sais pas où. Je limite la recherche à 50 km
autour de mon aéroport de départ. Demandons à Redis :

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

Ok, maintenant, je recherche un lieu de vacances, mais je n'aime pas
perdre trop de temps dans l'avion et je limite ma recherche à 300 km,
et uniquement dans les aéroports commerciaux (ceux disposant d'un code
IATA) :

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

Ok, j'ai choisi d'aller à Luxembourg (LUX), qui se trouve uniquement à
273 km de distance. Maintenant, je dois trouver un vol et j'aime voler
avec Air France (AF). Y-a-t-il un vol direct ? Une fois de plus, Redis
est mon ami...

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

Désolé les gars, maintenant, je dois préparer ma valise, je vous
enverrai une carte postale...

[OpenFlights]: http://openflights.org/
[Redis community edition]: http://redis.io
[Redis enterprise edition]: http://redislabs.com
