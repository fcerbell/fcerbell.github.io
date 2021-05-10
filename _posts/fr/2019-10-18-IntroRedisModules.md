---
uid: RedisModulesIntro
title: Redis 04 - Introduction aux modules Redis
description:
category: RedisIn5min
tags: [ Redis,  Redislabs, full text search, full text, search engine, graph database, graph, cypher, opencypher, index, indices, modules ]
---

J'ai déjà listé les structures de données natives de Redis. Redis peut charger
dynamiquement des modules pour implémenter n'importe quelle structure ou
fonctionnalité dans son cœur, bénéficiant de son architecture. Maintenant, je
donne un aperçu de cette extensibilité illimitée.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

* TOC
{:toc}

# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/HTLQ5QorOCs" frameborder="0" allowfullscreen></iframe></center>

# Une bibliothèque dynamique

Techniquement, un module est une bibliothèque partagée dynamique. Il peut être
développé dans d'importe quel langage de programmation tant qu'il peut exporter
un symbole d'entrée « onload ». Il est chargé à la demande par le processus
Redis et le point d'entrée « onload » est automatiquement appelé avec une
référence sur le cœur de Redis. Il peut ensuite enregistrer ses fonctions et
commandes dans Redis.

# Avantages du cœur de Redis

Les modules peuvent bénéficier de toutes les fonctionnalités sous-jacentes du
cœur de Redis, telles que le stockage en mémoire, l'utilisation des structures
existantes, la persistence, la haute-disponibilité, la distribution des données
par « sharding », etc.

# Les modules communautaires

N'importe qui peut implémenter un module et les utilisateurs de la communauté
Redis en ont créé de nombreux. Certains sont listés sur [la page web de
Redis][RedisIoModules], tels que le module de réseau neuronal, un module SQL ou
un module d'IA.

![Page des modules communautaires][RedisIoModuleHub.png]

# Les modules de qualité entreprise

Certains modules sont également disponibles dans le produit [Redis
Entreprise][RedislabsModules] de RedisLabs, tels que les moteurs de recherche
plain-texte, de base graphe ou d'IA basée sur les tensors, mais aussi les
structures de données JSON ou séries temporelles.

![Redislabs modules page][RedislabsModules.png]

# Démonstrations de modules

C'est un aperçu rapide et je publierai plus tard des contenus spécifiques pour
certains d'entre-eux.

## Compilation de modules

Le code source est habituellement très court, une fois récupéré, la compilation
n'est plus qu'à une commande : make, et le module est prêt à être chargé.

```
~/a $ git clone https://github.com/antirez/neural-redis.git
Clonage dans 'neural-redis'...
remote: Enumerating objects: 2838, done.
remote: Total 2838 (delta 0), reused 0 (delta 0), pack-reused 2838
Réception d'objets: 100% (2838/2838), 16.67 MiB | 537.00 KiB/s, fait.
Résolution des deltas: 100% (361/361), fait.
~/a $ cd neural-redis/
~/a/neural-redis $ make

Make neon     -- Faster if you have a modern ARM CPU.
Make sse     -- Faster if you have a modern CPU.
Make avx     -- Even faster if you have a modern CPU.
Make generic -- Works everywhere.

The avx code uses AVX2, it requires Haswell (Q2 2013) or better.
~/a/neural-redis $ make avx
make neuralredis.so CFLAGS=-DUSE_AVX AVX="-mavx2 -mfma"
make[1] : on entre dans le répertoire « /home/francois/a/neural-redis »
cc -I. -DUSE_AVX -Wall -W -O3 -fno-common -g -ggdb -std=c99 -mavx2 -mfma  -fPIC -c neuralredis.c -o neuralredis.xo
[...]
cc -I. -DUSE_AVX -Wall -W -O3 -fno-common -g -ggdb -std=c99 -mavx2 -mfma  -fPIC -c nn.c -o nn.xo
ld -o neuralredis.so neuralredis.xo nn.xo -shared  -lc
make[1] : on quitte le répertoire « /home/francois/a/neural-redis »
~/a/neural-redis $ ls
COPYING   Makefile       neuralredis.so  nn.c  nn.xo      redismodule.h
examples  neuralredis.c  neuralredis.xo  nn.h  README.md  tests
```

## Zoom sur le réseau neuronal

Avant de charger le module, les commandes de réseau-neuronal ne sont pas
reconues. Dès le chargement, les commandes sont enregistrées et disponibles.

```
127.0.0.1:6379> # List modules before loading it
127.0.0.1:6379> MODULE LIST
(empty list or set)
127.0.0.1:6379> #
127.0.0.1:6379> # Try to create a neural network
127.0.0.1:6379> NR.CREATE net REGRESSOR 2 3 -> 1 NORMALIZE DATASET 50 TEST 10
(error) ERR unknown command `NR.CREATE`, with args beginning with: `net`, `REGRESSOR`, `2`, `3`, `->`, `1`, `NORMALIZE`, `DATASET`, `50`, `TEST`, `10`,
127.0.0.1:6379> #
127.0.0.1:6379> # Load the neural network module
127.0.0.1:6379> MODULE LOAD /home/francois/Documents/RedisLabs/Youtube/Redis04-Modules/Demo/neural-redis/neuralredis.so
OK
```

Nous créons un réseau de régression avec 2 entrées et une sortie. Donnons lui
quelques exemples d'additions à 2 termes.

```
127.0.0.1:6379> NR.CREATE net REGRESSOR 2 3 -> 1 NORMALIZE DATASET 50 TEST 10
(integer) 13
127.0.0.1:6379> NR.OBSERVE net 1 2 -> 3
1) (integer) 1
2) (integer) 0
127.0.0.1:6379> NR.OBSERVE net 4 5 -> 9
1) (integer) 1
2) (integer) 1
127.0.0.1:6379> NR.OBSERVE net 3 4 -> 7
1) (integer) 2
2) (integer) 1
127.0.0.1:6379> NR.OBSERVE net 1 1 -> 2
1) (integer) 3
2) (integer) 1
127.0.0.1:6379> NR.OBSERVE net 2 2 -> 4
1) (integer) 4
2) (integer) 1
127.0.0.1:6379> NR.OBSERVE net 0 9 -> 9
1) (integer) 5
2) (integer) 1
127.0.0.1:6379> NR.OBSERVE net 7 5 -> 12
1) (integer) 6
2) (integer) 1
127.0.0.1:6379> NR.OBSERVE net 3 1 -> 4
1) (integer) 6
2) (integer) 2
127.0.0.1:6379> NR.OBSERVE net 5 6 -> 11
1) (integer) 7
2) (integer) 2
```

Avant de l'entraîner, le réseau ne connaît pas le résultat de 1+1. Entraînons-le
avec les échantillons et demandons-lui à nouveau 1+1 et 3+2.

```
127.0.0.1:6379> NR.RUN net 1 1
1) "0.47919058799743652"
127.0.0.1:6379> NR.TRAIN net AUTOSTOP
Training has started
127.0.0.1:6379> NR.RUN net 1 1
1) "2.1302213668823242"
127.0.0.1:6379> NR.RUN net 3 2
1) "5.3787569999694824"
```

## Zoom sur RedisSearch

Ce petit morceau de code python ouvre une connexion vers Redis. Il souscrit à
l'API de flux tweeter et envoie quelques champs, le surnom, le nom d'utilisateur
et le texte, dans le module de recherche pour les indexer.

``` python
[...]
from redisearch import Client, TextField, NumericField, Query

# Creating a client with a given index name
client = Client('myIndex', host='redis-16753.demo.francois.demo-rlec.redislabs.com', port=16753)

# Creating the index definition and schema
client.create_index([TextField('name'), TextField('screenname'), TextField('text')])

[...]

def process_tweets(tweets_queue):
    while True:
        tweet = tweets_queue.get()
        # Do something with the tweet! You can use the global "twitter" variable here.
        # Next line encodes tweet in ASCII so it displays in Windows 10 terminal
        #print(tweet['text'].encode('ascii','ignore'))
        print(tweet['text'])
        try:
            client.add_document(tweet['id_str'], 
                    name = tweet['user']['name'], 
                    screenname = tweet['user']['screen_name'], 
                    text = tweet['text'])
        # Next line prints only the tweet author's info and not the whole tweet
        # print(tweet['user']['id'], tweet['user']['screen_name'])
            tweets_queue.task_done()
        except redis.exceptions.ResponseError:
            process_tweets(tweet_queue)
[...]
```

Tentons de rechercher le mot « nosql ». Nous obtenons 1 résultat. RedisSearch
dispose aussi de fonctionnalités d'agrégation, d'auto-complétion et de bien
d'autres, extrèmement puissantes.

```
~ $ redis-cli -h redis-16753.demo.francois.demo-rlec.redislabs.com -p 16753 ft.search myIndex nosql
1) (integer) 1
2) "1185100822243397632"
3) 1) "text"
   2) "Articles on nosql best practices from the internet https://t.co/mtls2j5vxP  @STOConsortium @NoSQL_Master @coustautc #nosql #bigdata"
   3) "screenname"
   4) "v4vix"
   5) "name"
   6) "Vikram Sharma"
```

## Zoom sur RedisGraph

Une fois le module chargé, les commandes de graphe sont disponibles. On peut
utiliser OpenCypher, le langage de requêtes pour les bases graphes, pour créer 2
personnes, François et Elton, collègues de Georges à RedisLabs.

```
127.0.0.1:6379> GRAPH.QUERY DEMO_GRAPH "CREATE (a:people{f:1,g:\"i\"})-[:b]->(c)-[:d]->(e)"
1) 1) "Labels added: 1"
   2) "Nodes created: 3"
   3) "Properties set: 2"
   4) "Relationships created: 2"
   5) "Query internal execution time: 223.972204 milliseconds"
127.0.0.1:6379> GRAPH.QUERY DEMO_GRAPH "CREATE (f:person{name:\"François\",children:2})-[:colleague]->(g:person{name:\"Georges\",children:3})-[:works]->(r:employer{name:\"RedisLabs\"})"
1) 1) "Labels added: 2"
   2) "Nodes created: 3"
   3) "Properties set: 5"
   4) "Relationships created: 2"
   5) "Query internal execution time: 27.117751 milliseconds"
127.0.0.1:6379> GRAPH.QUERY DEMO_GRAPH "CREATE (f:person{name:\"Elton\",children:0})-[:colleague]->(g:person{name:\"Georges\",children:3})-[:works]->(:employer{name:\"RedisLabs\"})"
1) 1) "Nodes created: 3"
   2) "Properties set: 5"
   3) "Relationships created: 2"
   4) "Query internal execution time: 0.441413 milliseconds"
```

On peut aussi demander au graphe les noms des collègues de Georges.

```
127.0.0.1:6379> GRAPH.QUERY DEMO_GRAPH "MATCH (a:person)-[:colleague]->(b:person {name:\"Georges\"}) RETURN a.name"
1) 1) "a.name"
2) 1) 1) "Fran\xc3\xa7ois"
   2) 1) "Elton"
3) 1) "Query internal execution time: 73.909264 milliseconds"
```

## Zoom sur RedisTimeseries

Dès que le module est chargé, les commandes de série temporelles sont
disponibles pour créer une série. Elle comporte 10 valeurs de température
espacées de 5 secondes.

```
127.0.0.1:6379> TS.CREATE temperature RETENTION 60
OK
127.0.0.1:6379> TS.ADD temperature 1571044309 47000
(integer) 1571044309
127.0.0.1:6379> TS.ADD temperature 1571044314 46000
(integer) 1571044314
127.0.0.1:6379> TS.ADD temperature 1571044319 47000
(integer) 1571044319
127.0.0.1:6379> TS.ADD temperature 1571044324 47000
(integer) 1571044324
127.0.0.1:6379> TS.ADD temperature 1571044330 47000
(integer) 1571044330
127.0.0.1:6379> TS.ADD temperature 1571044335 47000
(integer) 1571044335
127.0.0.1:6379> TS.ADD temperature 1571044340 47000
(integer) 1571044340
127.0.0.1:6379> TS.ADD temperature 1571044345 49000
(integer) 1571044345
127.0.0.1:6379> TS.ADD temperature 1571044350 47000
(integer) 1571044350
127.0.0.1:6379> TS.ADD temperature 1571044355 47000
(integer) 1571044355
```

Ensuite, on peut demander à la série la moyenne de température par tranche de
10, 20 ou 60 secondes, par exemple. Et ce module peut faire beaucoup plus avec
des règles de pré-agrégation.

```
127.0.0.1:6379> TS.RANGE temperature 1571044319 1571044350 AGGREGATION avg 10
1) 1) (integer) 1571044310
   2) "47000"
2) 1) (integer) 1571044320
   2) "47000"
3) 1) (integer) 1571044330
   2) "47000"
4) 1) (integer) 1571044340
   2) "48000"
5) 1) (integer) 1571044350
   2) "47000"
127.0.0.1:6379> TS.RANGE temperature 1571044319 1571044350 AGGREGATION avg 20
1) 1) (integer) 1571044300
   2) "47000"
2) 1) (integer) 1571044320
   2) "47000"
3) 1) (integer) 1571044340
   2) "47666.666666666664"
127.0.0.1:6379> TS.RANGE temperature 1571044319 1571044350 AGGREGATION avg 60
1) 1) (integer) 1571044260
   2) "47000"
2) 1) (integer) 1571044320
   2) "47333.333333333336"

```

## Zoom sur RedisJSON

Ce dernier, une fois chargé, offre de nouvelles commandes pour manipuler
nativement une nouvelle structure : JSON. On peut créer un document «
utilisateur » avec un age et une adresse, le récupérer, mais aussi incrémenter
son age, ajouter un pays à son adresse ou récupérer un sous-objet sans devoir
récupérer l'objet complet.

```
127.0.0.1:6379> JSON.SET cust1 .  '\{"name":"Francois","age":1,"address":\{"city":"Paris"\}\}' 
OK
127.0.0.1:6379> JSON.GET cust1
"{\"name\":\"Francois\",\"age\":1,\"address\":{\"city\":\"Paris\"}}"
127.0.0.1:6379> JSON.NUMINCRBY cust1 .age 1
"2"
127.0.0.1:6379> JSON.GET cust1
"{\"name\":\"Francois\",\"age\":2,\"address\":{\"city\":\"Paris\"}}"
127.0.0.1:6379> JSON.SET cust1 .address.country '"FR"'
OK
127.0.0.1:6379> JSON.GET cust1 .address
"{\"city\":\"Paris\",\"country\":\"FR\"}"
```

# Plus encore...

Je dédierai des épisodes au développement de modules et à certains modules
spécifiques, plus tard.

# Supports et liens

| Lien | Description |
|---|---|
| [Video] | Enregistrement vidéo de la démonstration |
| [RedisIoModules] | Hub des modules communautaires |
| [RedislabsModules] | Hub des modules entreprise |

# Notes de bas de page
[Video]: https://youtu.be/HTLQ5QorOCs "Enregistrement vidéo de la démonstration"
[RedisIoModules]: https://redis.io/modules "Hub desmodules communautaires"
[RedisIoModuleHub.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/RedisIoModuleHub.png "Page des modules communautaires"
[RedislabsModules]: https://redislabs.com/redis-enterprise/modules/ "Hub des modules entreprise"
[RedislabsModules.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/RedislabsModules.png "Page des modules entreprise"
