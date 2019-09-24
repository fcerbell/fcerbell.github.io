---
uid: RedisKeyValue
title: Redis a key-structure store
author: fcerbell
layout: post
lang: en
#description:
category: Redis
tags: [ redis, introduction, key-value, data-structures ]
#date: 9999-01-01
#published: false
---

In this content, I explain the differences between relational schema, a key-value schema and a key-datastructure schema. 

You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/6uzBC39dvAs" frameborder="0" allowfullscreen></iframe></center>

# Key-value store

Redis was originally designed as a NoSQL database in the key-value family. This means that you can store any value behind a unique identifier and that you can get the value back from the identifier.

# Automatic key expiration

Redis can attach a timer, known as time-to-live or TTL, to each key and will update it. This timer will countdown to 0 then it will expire the key and its value automatically. This can be useful for temporary values or caching.

# Example dataset

Let's take a very simple usecase with a list of customers, a list of products and a list of orders made by customers. To keep things simple, an order only reference one single item. This could be a data model to address analytical needs and to have sales statistics or marketing statistics.

![Example dataset relational schema][RelationalSchema.png]

#  Data access pattern

In a key-value datastore, despite there are technical options to browse and query the key dictionnary, this is an anti-pattern. If you store customers, orders and products, this would mean a full table scan on three tables, only to filter some identifiers. Thus, either the application knows the identifier to get the value from or it cannot get the value. Either the identifier is known (a fixed value, for example), or it can be calculated/guessed from already known information or it can be fetched from another known key's value such as a customer identifier list stored in a key.

As an example, if the application stores "customers" using the customer id as the key, it can create one key-value pair per customer and one special key "customers" with the list of the identifiers. Thus either the application knows the identifier of the wanted customer to get the details or the application can get the list of all the customer identifiers from the "customer" key and go through the customers (and only the customers, not the other records). This is a primary key index implementation.

![Example dataset key-value schema][KeyvalueSchema.png]

This might seem more complex because the application has to execute 2 queries. When your application executes only one query on any other indexed database, the database engine would execute these two queries for you, too. To achieve that, they have a generic "fit-all-need" implementation which is not optimized for your specific need. With Redis, you can implement the exact desired level of optimization for your needs.

If you are interested in this topic, you can subscribe because I planned to talk more about key-value data model design in another video.

# Structured data storage

In our example, we used customer details records with firstname, civility, and so on..., product details records with description, price, ...  and orders with the order date. We also stored the list of customer identifiers, list of orders and list of products in three keys. Basically, we stored records and lists of unique identifiers.

It would be possible to store these information in a block using serialization. But some queries would not be efficient. If the application wants to know "does the reference XXX exist in the catalog ?", it would have to download the whole catalog, ie the list of product identifiers, unserialize it, parse it. This can be network, memory and CPU consumming...

This is why Redis understand datastructures such as a list of unique values, stores it as such and can manipulate it as such. The application can directly ask Redis "Does the reference XXX belong to the 'products' key ?". 

![Example dataset key-datastructure schema][KeystructureSchema.png]

Thus, the application does not need to download a potentially huge record through the network, to deserialize it and parse it. Furthermore, it does not have neither to manage any kind of concurrency protection, such as locks, when updating records.

Redis has the advantages of a key-value store, simplicity and efficiency, but not the drawbacks.

You got the idea.

I'll tell you more about available datastructures in the next video and about data model design in another video.






# Materials and Links

| Link | Description |
|---|---|
| [Video] | Video presentation |

# Footnotes

[Video]: https://youtu.be/6uzBC39dvAs "Related youtube video"
[RelationalSchema.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/RelationalSchema.png "Sample dataset relational schema"
[KeyvalueSchema.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/KeyvalueSchema.png "Sample dataset key-value schema"
[KeystructureSchema.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/KeystructureSchema.png "Sample dataset key-structure schema"
