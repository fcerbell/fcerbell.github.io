---
uid: RedisNoSQLIntro
title: Redis 05 - NoSQL Origins, goals and challenges
description:
category: Redis in 5 minutes
tags: [Redis,  Redislabs, index, indices, nosql, scalability, high, availability, high-availability, consistency, performances, sql, relational, normalization, normalize, deduplicate]
---

This part will describe some general concepts and challenges in NoSQL :
Scalability, High-Availability, Consistency and Performances. It is needed to
make the next parts easier to understand.

You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/OG0TZ0n_0nc" frameborder="0" allowfullscreen></iframe></center>

# NoSQL origins

Relational databases were designed in the 70s, when resources were expensive. It
was designed to deduplicate the data, by normalizing it, and save resources.
Networking was slow, clustering even did not appear in Stanley Kubrick's "2001 A
space odyssey" movie. It was designed to be generic and to fit all the usecases,
at the price of normalization. It was designed with slow development cycles
where the data schema was not changing too much and was enforced in the
database, by the database. 

![aa][relational.png]

SQL was created to query this storage with an excellent flexibility. But joins
are costly and need indexes to improve performances. They are not very scalable
horizontaly by design, making scalability of relational databases a real pain,
this was not the main goal at this time.

These limitations were fine until companies such as Google, Facebook or LinkedIn
hit them with their dataset size and their specific needs. Fortunately, they
also had the human resources to implement a specific datastorage and a query
language to fit their need.

Lets take an exemple with a columnar database, when we store customers in a
database. If the need is a transactional need such as an ERP, the smaller needed
information is a whole customer record and storing this customer record as such
in a relational database is fine. 

![aa][table.png]

But if the need is analytical such as "what is
the number of children of my French customers", we only need to access 2 fields
of each customer, "nb children" and "country". A record oriented storage is not
efficient because we need to fetch a whole record, get only 2 fields from it and
repeat this process. On the other hand, a columnar storage is better because the
granularity of the storage is the field, thus we have to scan 2 columns.

![aa][column.png]

Basically, instead of fetching a lot of information from the storage and
filtering them afterward, we filter before and fetch only the required
information from the storage. Of course, it would not be efficient if we had to
rebuild customer records, this is not a storage for a generic approach but a
specific storage optimized for a specific need.

You might not have the same dataset size, but you might have the same specific
usecase, and you can leverage these NoSQL databases.

# NoSQL goals and challenges

NoSQL databases were designed from the very begining to be scalable using
horizontal scalability on commodity hardware. But the more hardware we use, the
higher failure probabilities are, coming with availability challenges.

![aa][nodes.png]

High-availability has to be included in the design to mitigate this higher
failure risk in worldwide systems were the weekend-night concept doesn't exist.
High-availability means to duplicate the data. This comes with another challenge
: the consistency between copies.

The replicated data needs to be consistent with the original data when a failure
occurs or when the read operations are executed from the replicas. The
replication needs to be synchronous when real strong consistency is needed.
Synchronous replication comes with another issue : performances.

![aa][replication.png]

Read operations can be very fast, if the replication of the write operations
were synchronous and slow, or read operations can be slow if write operations
replication was asynchronous because the consistency has to be checked at read
time.

# Conclusion

Ok, so we have seen why NoSQL appeared and what are the main challenges. In the
next part, we'll dive into the scalability challenge, how it is usually
addressed, specifically in Redis and Redis enterprise.

# Materials and Links

| Link | Description |
|---|---|
| [Video] | Video Presentation with pictures|

# Footnotes

[Video]: https://youtu.be/OG0TZ0n_0nc "Video presentation with pictures"
[relational.png]: {{ "/assets/posts/" | append: page.uid | append:"/relational.png" | relative_url }} "i"
[table.png]: {{ "/assets/posts/" | append: page.uid | append:"/table.png" | relative_url }} "i"
[column.png]: {{ "/assets/posts/" | append: page.uid | append:"/column.png" | relative_url }} "i"
[nodes.png]: {{ "/assets/posts/" | append: page.uid | append:"/nodes.png" | relative_url }} "i"
[replication.png]: {{ "/assets/posts/" | append: page.uid | append:"/replication.png" | relative_url }} "i"
