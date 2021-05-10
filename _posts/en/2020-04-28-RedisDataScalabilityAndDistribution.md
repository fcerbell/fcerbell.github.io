---
uid: redisdatascalabilityanddistribution
title: Redis 06 - Data scalability and distribution
description:
category: RedisIn5min
tags: [ Redis,  Redislabs, scalability, data, cluster, distribution, sharding, resharding, shard, reshard, performances, linear, linear performances, predictable, predictable performances, query, querie, hash, hashslots, hashtags, hash-slot, hash-tags, enterprise, redis enterprise, community, redis community ]
---

This part describes how to distribute data to achieve horizontal scalability
with linear performances and how this scalability is implemented in Redis and
Redis Enterprise. The query execution distribution will be explained in the next
part.


You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/V1u3ceRdkQY" frameborder="0" allowfullscreen></iframe></center>

# Usual scalability implementation

Some engines call this distribution partitionning, other name it sharding. 

Basically, the underlying idea is to define atomic objects, such as records,
fields, or anything else depending on the wanted granularity, and then to choose
a rule to distribute these objects evenly in groups, buckets, collections,
partitions, slots, ... or whatever you call it. To achieve an even distribution,
the number of groups has to be fixed. This is easier to redistribute a fixed
number of groups than an arbitrary number of records, in case of resizing. 

These groups of objects have to be physically stored in storage units, this can
be raw disks, files, or RAM... Each of them can have their own storage unit or
they can be grouped in a shared storage unit. Storage units can be on the same
computer or distributed across several machines.

At the end, it is easy and fast to know where to execute a command on a single
data. Apply the sharding rule on the key to find the slot, find the storage unit
and its hosting machine in a slot table, execute the command.

# The Redis way

## Key distribution

A Redis database stores keys and values. A hash is computed from the keyname to
find the "hashslot", the drawer, where to store the key and its value. There is
a fixed number of hashslots : 16384. The hash function is very simple : CRC12
modulo 16384. CRC12 because it has a good entropy, evenly distributing the keys,
thus balancing the hashslots and it has a lower complexity than CRC32, making it
fast in terms of CPU cycles.

Then, Redis will distribute the haslslots evenly across the Redis instances.

## Seamless resharding

A single Redis shard is the storage unit and has physical limitations. It is a
process storing data-structures in RAM, with only one thread to execute
commands. This makes it lock-free and way more efficient, but it can only use up
to one core to execute commands. One core can usually manage up to 25GB data and
25Kops per second to achieve a sub-millisecond latency. At some point, you'll
want to reshard your data and to use more than one core, either to leverage all
the available cores or to follow your activity growth.

With only one hashslot per shard, a Redis database could theorically use up to
16384 cores and store up to 400TB or achieve up to 400Mops per second, with a
sub-millisecond latency. Give me the machines to test... 

[200Mops Benchmark][200MBenchmark] [^1]

### In Redis Community

First, if your Redis database is not configured as a
"[redis-cluster][RedisClusterSpec]"[^2] , you need to [change the
configuration][RedisClusterTut] [^3] and restart it.


Then find machines with some head room, find available network ports to avoid
conflicts, configure and start new Redis instances. Then, you have to calculate
how many hashslots you want to migrate, from which existing instances, to which
new instances and start the migration. It is quite easy to miss a step or to end
with unbalanced instances.

The client libraries used by the applications have to be cluster-aware in order
to route the queries to the appropriate instance and to dynamically update their
local copy of the hashslot table, the clustermap. Not all client libraries can
do that.

### In Redis Enterprise

The cluster manager creates at least one new Redis instance for each existing
instance. Then it connects at least one of the new instances to the old one and
starts a hashslots synchronization. Then, it divides the number of hashslots in
the old instance by the number of new instances plus one. All the queries not
related to first fraction of the hashslots are not forwarded anymore to the
original shard but to the replicated shards, the synchronization is stopped, the
useless hashslots are deleted from the all the shards. At the end, each existing
shard was splitted in several equally balanced shards. Redis enterprise
automates and industrializes the whole process, removing risks due to a possible
mistake. This is the result of 8 years of automation experience and several
man.year of development.

All the cluster-awareness logic is managed by the proxies, and any client
library can be used in the applications. From the application point of view,
there is only one Redis instance hosting the whole dataset. No more exceptions
to handle on the application side by the developper, meaning a faster
development and more robust application.

# Conclusion

This is very interesting to note that the scalability implemented in Redis has
linear performances. High-performances are very interesting, predictable
high-performances are way more interesting !

Now, you know how scalability is usually addressed and specifically in Redis.
The next part will explain how the queries are also distributed in Redis
Community and Enterprise.

# Materials and Links

| Link | Description |
|---|---|
| [Video] | Demonstration screencast recording |

# Footnotes

[^1]: [https://redislabs.com/blog/redis-enterprise-extends-linear-scalability-200m-ops-sec/](https://redislabs.com/blog/redis-enterprise-extends-linear-scalability-200m-ops-sec/)

[^2]: [https://redis.io/topics/cluster-tutorial](https://redis.io/topics/cluster-tutorial)

[^3]: [https://redis.io/topics/cluster-spec](https://redis.io/topics/cluster-spec)

[200MBenchmark]: https://redislabs.com/blog/redis-enterprise-extends-linear-scalability-200m-ops-sec/

[RedisClusterTut]: https://redis.io/topics/cluster-tutorial

[RedisClusterSpec]: https://redis.io/topics/cluster-spec

[Video]: https://youtu.be/V1u3ceRdkQY "Demonstration video recording"
