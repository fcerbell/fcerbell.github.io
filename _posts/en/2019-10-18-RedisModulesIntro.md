---
uid: RedisModulesIntro
title: Redis 04 - Redis modules introduction
description:
category: RedisIn5min
tags: [ Redis,  Redislabs, full text search, full text, search engine, graph database, graph, cypher, opencypher, index, indices, modules ]
---

I already listed the native Redis data-structures. Redis can dynamically load
modules to implement any data-structure or any feature inside its core,
leveraging its architecture. Now, I try to give an overview of this infinite
extensibility.

You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/P2d5P8DQFYM" frameborder="0" allowfullscreen></iframe></center>

# A dynamic library

A Redis module is technically a dynamic shared library. It can be implemented in
any programming language as long as it can export an "onload" entrypoint symbol.
It is loaded on-demand by the Redis processes and the "onload" entrypoint is
automatically called with a reference to the Redis core. Then, the module can
register its functions and commands to Redis core.

# Benefits of redis core

Modules can leverage all the underlying Redis core features, such as in-memory
storage, existing data-structure usage, persistency, high-availability,
data-distribution with sharding, and so on.

# Community modules

Anyone can implement a module and Redis community users created a lot of
modules. Some of them are listed on the [Redis web page][RedisIoModules], such
as a neural-network module, an SQL module, an AI module.

![Community modules hub page][RedisIoModuleHub.png]


# Enterprise grade modules

Some modules are also available in the [Redis Enterprise][RedislabsModules]
product by RedisLabs, such as the full-text search, the graph database or the
tensor based AI engines, as well as the JSON or the time-series data-structures.

![Redislabs modules page][RedislabsModules.png]

# Module demos

This is a short overview and I'll publish dedicated content for
some of them, later.

## Module compilation

The sourcecode is usually very small, once we fetch it, compiling is only one
command away : make, and the module is ready to be loaded.

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

## Zoom on neural-network

Before loading the module, neural-network commands are not recognized. As soon
as it is loaded, commands are registered and available.

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

We create a regression network with 2 inputs and 1 output. Let's give him some
2-terms addition exemples.

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

Before training, the network doesn't know what 1+1 result is. Let's train him
with the samples and try again with 1+1 and 3+2.

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

## Zoom on RedisSearch

This small piece of python code opens a connection to Redis. It subscribes to
twitter streaming API and push some fields, screen name, user name and tweeted
text, in Redis search module to index them.

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

Let's query about the "nosql" word. We have one result. RedisSearch also has
aggregation, autocompletion and a lot of other very powerful features.

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

## Zoom on RedisGraph

Once the module is loaded, graph commands are available. We can use OpenCypher,
the graph database query language, to create 2 persons, François and Elton,
colleagues of Georges at RedisLabs.

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

We can also ask the graph about the names of Georges' colleagues.

```
127.0.0.1:6379> GRAPH.QUERY DEMO_GRAPH "MATCH (a:person)-[:colleague]->(b:person {name:\"Georges\"}) RETURN a.name"
1) 1) "a.name"
2) 1) 1) "Fran\xc3\xa7ois"
   2) 1) "Elton"
3) 1) "Query internal execution time: 73.909264 milliseconds"
```

## Zoom on RedisTimeseries

As soon as the module is loaded, timeseries commands are available to create a
timeserie. It contains 10 CPU temperature values, with a 5 seconds interval.

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

Then, we can ask the timeserie about the temperature average by 10, 20 or 60
seconds slices, for exemple. And the timeseries module can do a lot more, with
pre-aggregation rules.

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

## Zoom on RedisJSON

This last one, once loaded, provides new commands to natively manipulate a new
datastructure: JSON. I can create a JSON user document, with age and address,
get it back, increment his age, add a country field in the address sub-document
or get only the address sub-document, without fetching the whole record.

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

# More

I'll focus on module development and on specific modules later.

# Materials and Links

| Link | Description |
|---|---|
| [Video] | Video Presentation with pictures|
| [RedisIoModules] | Community modules hub |
| [RedislabsModules] | Enterprise modules hub |

# Footnotes

[Video]: https://youtu.be/P2d5P8DQFYM "Video presentation with pictures"
[RedisIoModules]: https://redis.io/modules "Community module hub"
[RedisIoModuleHub.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/RedisIoModuleHub.png "Community modules page"
[RedislabsModules]: https://redislabs.com/redis-enterprise/modules/ "Enterprise modules"
[RedislabsModules.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/RedislabsModules.png "Enterprise modules page"

