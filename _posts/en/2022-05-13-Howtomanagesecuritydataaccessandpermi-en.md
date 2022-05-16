---
uid: 09Howtomanagesecuritydataaccessandpermi
title: Redis 09 - How to manage security, data-access and permissions with Redis ACL
description: How to secure Redis with accounts and passwords for authentication and with access control lists for commands and data permissions. Introduction, explanation and demonstration of what are ACLs in Redis.
category: Redis in 5 minutes
tags: [ Redis, Database, Data-access, Access control, Authentication, Authorizations, Permissions, ACL, Access Control Lists, Security, Administration ]
date: 2022-05-13 16:59:00 +02:00
---

You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/DxhRIlrj660" frameborder="0" allowfullscreen></iframe></center>


# Introduction
Do you know that Redis can be secured with accounts and passwords for
authentication and with access control lists for commands and data permissions ?
You will learn how do ACL work, how to implement it.

# The security problem
Until version 6, Redis only had a single anonymous default user, potentially
with a single password, to grant full privileges. This security weakness is not
a real concern for developers who love Redis for its flexibility, performances
and other data manipulation and storage capabilities. They use it everywhere in
nearly every company. This is a problem for ops and for the company's security
team, but they got used to it. They, you, might not know that Redis has named
accounts with personal passwords for a real authentication and access control
lists (ACL) for authorization and permission management. Redis can be secured,
let's see how it works and how to implement it with a sample project.

# Limits of the existing solution
We have a single database to store orders and two microservices, one to update
an order, another one to generate the invoice. This is a project, so we have one
developer for each microservice, David and Denis, a project manager, Paul, and
an administrator, Angelina. The microservices and the people are all using the
same anonymous account, with the same single shared password. This password
grants them  full access to the whole dataset and to every Redis command.
Everyone with this potential password can execute any command, with read-write
permissions on the whole dataset. When a microservice needs read-write access to
update a database and another one only needs read-only access, if the second one
has a bug, is corrupted or compromised, it can corrupt the data of the first one
or even delete the data. If a contractor or an intern work on the project, they
have full access and the global simple shared password will probably not be
changed when they leave, the microservices configuration would have to be
changed, too. It makes it also impossible to track and audit who made what.
Let's see how Redis 6 and later can address this data-access security concern.

![Capture d’écran_2022-05-11_16-59-12.png](../{{ "/assets/posts/en/Howtomanagesecuritydataaccessandpermi/57eff1ee469c4c33b1672d5bfa0220e9.png" | relative_url }})

# Implemented solution and results
First, I assume that all connections to the Redis database are encrypted with
TLS, otherwise, the passwords can be intercepted.

## What is a Redis ACL
An ACL, for access control list, is an ordered list of rules or ACE, for access
control entries. Each rule can grant or revoke permissions on Redis commands,
Redis key patterns or Redis channels to a named account, potentially protected
by a password. Let's see how to define ACLs.  ```

acl setuser <account> [rulelist]
```
![Capture d’écran_2022-05-11_16-59-29.png](../{{ "/assets/posts/en/Howtomanagesecuritydataaccessandpermi/663e944fc6b0482ca4000a55e5242b31.png" | relative_url }})

![Capture d’écran_2022-05-11_16-59-47.png](../{{ "/assets/posts/en/Howtomanagesecuritydataaccessandpermi/682363d73c9b4f018161ed40284a812d.png" | relative_url }})

## Account initialization
An account can be reinitialized with the `reset` rule to its initial state :
with password enforced but not defined, without limiting rules, no command is
allowed, no key is available, and disabled.

```bash
# Init the account and allow passwordless authentication
redis-cli acl setuser francois reset nopass
# The account is disabled
redis-cli --user francois --pass 'anything' quit
```

## Disabling an account
An account can be temporarily disabled with the `off` rule or enabled with the
`on` rule.

```bash
# Enable the account
redis-cli acl setuser francois on
# The connection succeed
redis-cli --user francois --pass 'anything' quit
# Disable the account
redis-cli acl setuser francois off
# No more connection possible
redis-cli --user francois --pass 'anything' quit
# Renable the account
redis-cli acl setuser francois on
```

## Multiple passwords per account
The ACL can set one or several passwords to authenticate an account, with the
`>` sign for a cleartext password or with the `#` sign for a hashed password. It
can also invalidate one of the previously assigned password respectively with
the `<` or `!` sign. All passwords can be invalidated at once with the `nopass`
rule, also allowing passwordless connections.

```bash
# Add a password to the account
redis-cli acl setuser francois '>mypassword'
# No more passwordless connection possible
redis-cli --user francois --pass 'anything' quit
redis-cli --user francois --pass mypassword quit
# Add a second password to the account
redis-cli acl setuser francois '>mysecondpassword'
# The first password still works
redis-cli --user francois --pass mypassword quit
# The second password also works
redis-cli --user francois --pass mysecondpassword quit
# Remove the first password
redis-cli acl setuser francois '<mypassword'
# The first password does not work anymore
redis-cli --user francois --pass mypassword quit
# The second password still works
redis-cli --user francois --pass mysecondpassword quit
```

## Command categories
Rules can grant or revoke execution privileges on common command-categories,
respectively with the `+` or `-` sign, followed by the `@` sign and the
category.

`nocommands` and `allcommands` are special keywords for `-@all` and `+@all`

![Capture d’écran_2022-05-11_16-59-41.png](../{{ "/assets/posts/en/Howtomanagesecuritydataaccessandpermi/d41f9e12a4cb44c6b6bed51956714bcf.png" | relative_url }})

```bash
# Reset the account with all keys access
redis-cli acl setuser francois reset on '>mypassword' ~*
# String commands are disabled
redis-cli --user francois --pass mypassword set strkey value1
# Limit the account to string related commands only
redis-cli acl setuser francois reset on '>mypassword' +@string ~*
# String keys write and read are allowed
redis-cli --user francois --pass mypassword set strkey value1
redis-cli --user francois --pass mypassword get strkey
# But not the other datatypes commands
redis-cli --user francois --pass mypassword sadd setkey value
# And not the general commands
redis-cli --user francois --pass mypassword info
# Grant a read-only access to string values only
redis-cli acl setuser francois reset on '>mypassword' +@string -@write ~*
# The account can not write
redis-cli --user francois --pass mypassword set strkey value1
# But the account can read
redis-cli --user francois --pass mypassword get strkey
```

## Data-access restrictions
Rules can limit the available keyspace to glob patterns prefixed with the `~`
sign.

```bash
# Access to all keys
redis-cli acl setuser francois reset on '>mypassword' +@all ~*
redis-cli --user francois --pass mypassword set mykey value1
redis-cli --user francois --pass mypassword set yourkey valuer2
redis-cli --user francois --pass mypassword set hiskey valuer3
# Access to my keys and your keys only
redis-cli acl setuser francois reset on '>mypassword' +@all ~my* ~your*
redis-cli --user francois --pass mypassword set mykey value1
redis-cli --user francois --pass mypassword set yourkey valuer2
redis-cli --user francois --pass mypassword set hiskey valuer3
```

## Specific command restrictions
A rule can also grant or revoke execution privileges on specific commands with
the `+` or `-` sign, respectively, and the command itself.

```bash
# Grant read-only access to string values, and to expiry information
redis-cli acl setuser francois reset on '>mypassword' -@all +get -set +ttl -expire -del +exists ~*
# The account can not write
redis-cli --user francois --pass mypassword set strkey value1
# The account can not change the key's TTL
redis-cli --user francois --pass mypassword expire strkey 60
# But it can read the value
redis-cli --user francois --pass mypassword get strkey
# And get the remaining TTL
redis-cli --user francois --pass mypassword ttl strkey
```

## Importance of rules ordering
The rule order is important, rules are evaluated from left to right. A rule list
can grant execution on hash commands only, but revoke execution on all the write
commands.

```bash
# Grant read-only access to hash keys
redis-cli acl setuser francois reset on '>mypassword' -@all +@hash -@write ~*
# A write attempt fails
redis-cli --user francois --pass mypassword hset hashkey field1 value1 field2 value2
# Revoke write commands, but grant them afterwards
redis-cli acl setuser francois reset on '>mypassword' -@all -@write +@hash ~*
# The revocation is useless and writes are possible !
redis-cli --user francois --pass mypassword hset hashkey field1 value1 field2 value2
```

# What about our example

## Create accounts
We need to create six password protected accounts with different permissions

- orders-update : read-write access on hashes and lists starting with *order:*''
- orders-invoice : same, but read-only
- david : same as orders-invoice
- denis : same as orders-invoice
- paul : same as orders-update, to manually fix data
- angelina : admin access to potentially flush the database, but access to the
  data

![11.png](../{{ "/assets/posts/en/Howtomanagesecuritydataaccessandpermi/0f8f8094c5804dfc999377e3da6fe002.png" | relative_url }})

So, our *orders* Redis database can revoke permissions on all commands, but
grant permissions on all of the hash and list manipulation commands, excluding
the dangerous commands, on keys begining with `order:*`to a named account
*order-update*, identified by a secret password. The first microservice can
connect with his own credentials, is limited to the needed commands on the
needed keys.

```bash
redis-cli acl setuser order-update reset on '>order-update' -@all +@hash +@list -@dangerous ~order:*
```

The *order-invoice* microservice needs the exact same permissions, without any
write command, the ACL would be :

```bash
redis-cli acl setuser order-invoice reset on '>order-invoice' -@all +@hash +@list -@dangerous -@write ~order:*
```
Now, David and Denis need to have the same read-only permissions

```bash
redis-cli acl setuser david reset on '>david' -@all +@hash +@list -@dangerous -@write ~order:*
redis-cli acl setuser denis reset on '>denis' -@all +@hash +@list -@dangerous -@write ~order:*
```
Paul, as a project manager, needs to be able to change values

```bash
redis-cli acl setuser paul reset on '>paul' -@all +@hash +@list -@dangerous ~order:*
```
Finally, Angelina needs full admin access, to potentially flush the database

```bash
redis-cli acl setuser angelina reset on '>angelina' +@admin +@dangerous
```

![Capture d’écran_2022-05-11_17-08-37.png](../{{ "/assets/posts/en/Howtomanagesecuritydataaccessandpermi/911065dd753643a6816304bf4faffe0c.png" | relative_url }})

## Disable or limit the default account
The default anonymous account is a fallback to grant permissions when no
authentication occured or succeed. This account has to be limited. The second
execution should fail.

```bash
redis-cli acl setuser default reset +info
redis-cli acl setuser default reset +info
```
It can also be completely disabled. It is still enabled, but can only execute
the `AUTH` command to authenticate as another account. The second execution
should fail.

```bash
redis-cli acl setuser default off
redis-cli acl setuser default off
```

From that point, the only admin still available to change the permissions is... *Angélina*

## Tests
The easiest way to test is to execute the following set of commands with each
account. We first test that the account can read and write string keys, then
hash keys, then list keys. Finally, we check that the info command can be
executed and how many keys are in the database before trying to flush the whole
database and check if it worked.

```bash
redis-cli --user angelina --pass angelina << EOF
set key value
get key
hset order:key field1name field1value field2name field2value
hgetall order:key
lpush order:key:sub value1
lpush order:key:sub value2
llen order:key:sub
lpop order:key:sub
info keyspace
flushall
info keyspace
EOF
```
### Anonymous account
This account should not be able to execute any of these commands, with one
exception, the INFO command, if you chose to leave it to this user.

### order-update microservice
This account should not be able to read and write the string keys, because he is
not allowed to execute string commands and because the key does not match the
allowed pattern. He should be able to read and write the hash and list keys, he
is allowed to use these commands and to access the keys. But it should not be
allowed to flush the database.

### order-invoice microservice
This account has the same permissions, but not on the write commands, thus the
HSET will fail, as expected. But the LPOP also because this command not only
read a value, but also remove it from the list, this is a read-write combined
command.

### David developer
David and Denis have the exact same permissions as `order-invoice`.

### Paul Project manager
Paul has the exact same permissions as `order-update` and should be able to
write the allowed hasn and list keys.

### Angelina adminstrator
Angélina is not allowed to read or write any key, SET, GET, HSET, HGET, LPUSH
and LPOP commands will fail, but she can execute the INFO command to get the
number of keys on the database and to FLUSHALL the data.

## Security management at scale
Applications, developers, project managers and admins are uniquely identified
with their own credentials and have specific permissions on the database and on
the data. But what happens when microservices are added with their own
databases, with developers moving from a project to another, with new hired
people, leaving people, with another Redis database used as a message bus to
communicate with PubSub between all microservices... It is a pain to maintain
and Redis can also manage such situations with a role based access control
explained in my next content.

![25.png](../{{ "/assets/posts/en/Howtomanagesecuritydataaccessandpermi/83deb6b770204890a5a980121e3a3dfe.png" | relative_url }})

# Materials and Links

| Link | Description |
|---|---|
| [Video] | Demonstration screencast recording |

[Video]: https://youtu.be/DxhRIlrj660 "Demonstration video recording"

