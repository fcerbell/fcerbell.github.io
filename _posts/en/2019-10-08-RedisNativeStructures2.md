---
uid: RedisNativeStructures2
title: Redis 03b - Native datastructures (part 2)
author: fcerbell
layout: post
lang: en
#description:
#category: Test
tags: [ Redis, RedisLabs, Data-structures, Data, Structures, key-value, key, value, strings, limits, sets, sorted, sorted sets, list, hash, geo, geo index, bitmap, bitfield, hyperloglog, usecase, stream, ttl, time-to-live, expiration, full text search, full text, search engine, graph database, graph, cypher, opencypher, concurrency, atomic counter, atomic, counter, lock, index, indices, stack, queue, joe queue, task queue, task ]
#date: 9999-01-01
published: true
---

I'll give a short overview of Redis native datastructures, what can they be
used for, what can be stored inside, how to use it. In the previous part, I
described the basic native datastructures.

You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/LfVPXQ3gkzo" frameborder="0" allowfullscreen></iframe></center>


# Geo-indices

Internally, this structure uses a sorted set to store the items and uses a
geo-hash calculated from the coordinates as a score. The difference between two
geo-hashes is proportional to the physical distance between the coordinates used
to compute these geo-hashes. So, this is not really a new native basic
datastructure, but a derivated datastructure. It has the same properties as the
sorted set with additionnal commands to calculate distances between points or
retrieving items by distance. Redis unnderstands the international metric system
and the weird imperial system.

Geo-indices can be used to retrieve proximity items, to compute distances,
routes. 

# Bitmaps

This data structure is derived from strings. It is not really a new
datastructure, but a set of commands to manipulate a string at the bit level. It
can address every individual bit of a 512MB string, to get, set or clear it. It
can count the number of set bits.  It also has commands to execute bit
operations between several bitmaps such as AND, OR, XOR.

This structure is convenient to implement quick filters, categorized counters or
analytic. It is easy to get the list of male customers, maried, without
children, accepting emails that were interested in a specified product, for
example.

# Bitfields

This one is also a set of commands to manipulate numeric fields of any arbitrary
length stored at fixed positions in a string structure. This is a huge storage
saver. If you need to store values in the 0-8 range, you will need only 3 bits
per value.

It can be used to store timeseries, sequential things, configuration and
settings, for example.

# Hyperloglogs

This structure is a counter of unique values. When you need to count thousands
of unique values, you usually need to also store the counted values to count
them only once. Hyperloglog only stores the counter in a 12KB record. It will
never use more than 12KB. The tradeoff is that it will return a counter with a
1% accuracy.

If you want to count unique visitors on your web site, using the source IP
addresses. Hyperloglog will be able to tell you that you had 1000000 unique IP
addresses with a 1% accuracy, but it will only use 12KB of RAM instead of 4MB to
store 1M IP addresses.

# Streams

This one can be seen as a log. You can add new entries, they will be timestamped
and stored, but you can not delete or alter an existing entry. You can limit the
size of the log. An entry contains fields with field name and field values. Ok,
so, you've got a log.

Then, you can execute a range query such as "get all records between yesterday
and today". You can subscribe to a stream to receive each new record in
real-time, you can subscribe to a stream in the past to resume a lost connection
and you can ask the stream to distribute the records to a consumer group to
distribute the load, with acknowledgments. Each entries do not need to store
field names if they are the same as the previous entry.

It can be quite convenient to implement data synchronization on a weak link,
data ingestion from IoT devices, event logging, or a multi-user chat channel.

# Infinity of others : Modules

Then, you can extend Redis and add any kind of datastructure or feature, using
modules, but I'll talk about modules later.

# Materials and Links

| Link | Description |
|---|---|
| [Video] | Video Presentation with pictures|

# Footnotes

[Video]: https://youtu.be/LfVPXQ3gkzo "Video presentation with pictures"
