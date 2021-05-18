---
uid: RedisNativeStructures1
title: Redis 03a - Native datastructures (part 1)
description:
category: Redis in 5 minutes
tags: [ Redis, RedisLabs, Data-structures, Data, Structures, key-value, key, value, strings, limits, sets, sorted, list, hash, ttl, time-to-live, expiration, full text search, full text, search engine, graph database, graph, cypher, opencypher, concurrency, atomic counter, atomic, counter, lock, index, indices, stack, queue, joe queue, task queue, task ]
---

In this first part, I give a short overview of the most commonly used Redis
native datastructures, what can they be used for, what can be stored inside, how
to use it. In the next parts, I'll describe the remaining native datastructures.

You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/O6w6ovg1Ch0" frameborder="0" allowfullscreen></iframe></center>

# Short reminder about Redis

Redis is an in-memory key-structure database. It can store 2^32 keys, each key
can be 512MB long and contains a value. The value is a datastructure. Redis has
10 native datastructures and can be extended to support any kind of
datastructure from JSON to graph database or full-text search engine. Each key
can also have a TTL, time-to-live or expiration to delete it automatically.

For each of the supported data-structures, Redis enables you to manipulate the
structured data directly in-place with atomic commands, without worrying about
concurrency, or network traffic and bandwidth.

# Strings

A string can store a serie of bytes, up to 512MB, eventually non-printables, it
is binary-safe. You can store HTML generated snippets, serialized JSON objects,
images or PDF files, and so on. Redis has a basic understanding of a string and
some manipulation commands. It can store arbitrary bytes or numeric values.
Redis can atomically increment or decrement numeric values in-place. Regarding
text values, Redis can append a string at the end or return a specified number
of bytes from a specified position.  

![Strings: contents][Strings1.png]

Strings can be used to distribute content, to implement atomic counters or
locks, to store positional records.  Strings combined with TTL and eviction
policy are the prefered structure when implementing a cache.

![Strings: usecases][Strings2.png]

# Sets

A set stores an unordered set of unique items. it can store up to 2^32 different
items, each of them is a Redis string and can store up to 512MB, binary-safe. I
never tested this max values, if you give me the machine, I am kind to try ! ;) 

![Sets: contents][Sets1.png]

Redis can manipulate a set in place to check the existance of on item in the
set, to add an item to the set, to remove an item from the set. Furthermore,
Redis can execute cross-sets commands such as union, or intersections.  Sets can
be used to implement indices. A set can contain the list of customers keys, this
is a primary index. There can be one set per possible firstname, with the list
of customers having this firstname, this is a secondary index. Redis can easily
and quickly retrieve customer identifiers by intersecting the sets.

![Sets: usecase][Sets2.png]

# Sorted sets

A sorted set is a set with a numeric score attached to each item. This set is
sorted by score and has more available commands to retrieve the top 10, the last
10 or the items with a score within a specified range.  They can be used to
store timeseries, using a timestamp as a score. 

![ZSets: contents][ZSets1.png]

They can be used for leaderboards to get the top blog posts by vote. They are
also often used as secondary indices for range queries, to get all the customers
with firstname "François" and lastname "Cerbelle" and age between 30 and 50.

![ZSets: usecase][ZSets2.png]

# Lists

A list can store up to 2^32 items and keep the item rank. Redis can add or
remove an item at the bottom or at the top of a list. Lists can be used as
lists, as stacks or as queues. They also support some blocking commands such as
"get next item if there is one, or wait until there is one". Redis can also
execute cross-lists commands to get and remove an item from a list and add it to
another list. 

![Lists: contents][Lists1.png]

This can be used to implement some kind of workflows.  They are very useful to
implement job queues with several consumers. 

![Lists: usecase][Lists2.png]

# Hashes

A hash is a record, it can store up to 2^32 fields, each with a field name and a
field value. The field names and field values are Redis strings. Redis can read
or write selected fields of a hash in-place. This can be used to increment the
field "age" of customer "XYZ", or to update any text field.  

![Hashes: contents][Hashes1.png]

Hashes are used to store any record, customer, product, asset, event, operation,
user session... 

![Hashes: usecase][Hashes2.png]

# Materials and Links

| Link | Description |
|---|---|
| [Video] | Video Presentation with pictures|

# Footnotes

[Video]: https://youtu.be/O6w6ovg1Ch0 "Video presentation with pictures"
[Strings1.png]: {{ "/assets/posts/" | append: page.uid | append:"/Strings1.png" | relative_url }} "String contents"
[Strings2.png]: {{ "/assets/posts/" | append: page.uid | append:"/Strings2.png" | relative_url }} "String usecases"
[Sets1.png]: {{ "/assets/posts/" | append: page.uid | append:"/Sets1.png" | relative_url }} "Set contents"
[Sets2.png]: {{ "/assets/posts/" | append: page.uid | append:"/Sets2.png" | relative_url }} "Set usecase"
[ZSets1.png]: {{ "/assets/posts/" | append: page.uid | append:"/ZSets1.png" | relative_url }} "ZSet content"
[ZSets2.png]: {{ "/assets/posts/" | append: page.uid | append:"/ZSets2.png" | relative_url }} "ZSet usecase"
[Lists1.png]: {{ "/assets/posts/" | append: page.uid | append:"/Lists1.png" | relative_url }} "List contents"
[Lists2.png]: {{ "/assets/posts/" | append: page.uid | append:"/Lists2.png" | relative_url }} "List usecase"
[Hashes1.png]: {{ "/assets/posts/" | append: page.uid | append:"/Hashes1.png" | relative_url }} "Hash contents"
[Hashes2.png]: {{ "/assets/posts/" | append: page.uid | append:"/Hashes2.png" | relative_url }} "Hash usecase"
