---
uid: HowtomanageRBACsecuritywithACLandRole
title: Redis 10 - How to manage RBAC security with ACL and Role
description: How Redis Enterprise's role based access control (RBAC) works and can be used to improve the security and industrialize Redis ACL for authentication and authorizations on data and commands at scale ?
category: Redis in 5 minutes
tags: [ Redis, Authentication, Authorizations, Permissions, Roles, ACL, RBAC, Access Control, Security, Administration, Security groups, Groups, REST API, REST, API ]
date: 2022-05-28 16:07:52 +02:00
published: false
---

How Redis Enterprise's role based access control (RBAC) works and can be used to improve the security and industrialize Redis ACL for authentication and authorizations on data and commands at scale ?

You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video with explanation and demo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/eeJu15azF2Y" frameborder="0" allowfullscreen></iframe></center>

# Prepare the environment

```bash 
# Start Redis Enterprise
docker run -d --cap-add sys_resource --name redisenterprise -p 8443:8443 -p 9443:9443 -p 12000:12000 -p 12001:12001 -p 12002:12002 redislabs/redis
sleep 20

# Initialize the Cluster
docker exec -d --privileged redisenterprise "/opt/redislabs/bin/rladmin" cluster create name cluster.local username francois@redislabs.com password password
sleep 15
```

# Prerequisites
This contents assume that you already know what are Redis ACL. If you did you watch it previously, I recommend that you watch the Redis ACL contents before this one. If you want to reproduce the following steps by yourself, you need to install *docker*, *curl* and *jq*. The commands are not purely POSIX shell compliant and need some *bash* extensions.
![8a37ebdcb286aa6ce72cc6da0b92a6e3.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/2a2fa48640b942fe9774a5134706509b.png" | relative_url }})

# What's the problem
Redis is used in nearly every company in the world. The data access control is critical to ensure the data security and to respect the compliance rules such as GDPR. Each incoming connection needs to be authenticated and potentially granted permissions on available databases, commands and data.

Lets imagine that you have three databases :
- an orders database to store orders and order lines ;
- a products database to store the product catalog and the product availability in stocks ;
- a messaging database used as a message bus to communicate between all microservices with PubSub.

Lets imagine that you have two microservices :
- One microservice to manage orders in the orders database, with two endpoints : *orders-update* to create and update orders, and *orders-invoice* to generate invoices.
- The other microservice to manage the product catalog with two endpoints, *products-update* to update products and *products-stocks* to check a product availability. 

There are also people :
- one administrator, *Angélina* who should not access the data
- two project managers, *Paul* for the orders management, and *Pierre* for the product catalog. They need to access the logs, the database configuration, the monitoring and to change their projects data.
- one developer *David*, working both on the *orders* project microservice and on the *products* microservice, and one developer *Denis*, working on the *products* project microservice only. Each of them need a limited access to the monitoring and to read data from the database, and they both need to see the messages in the *messaging* database.

This is a fairly simple example compared to real enterprise needs. The permissions are easy to implement, but not to scale if you have several projects, several profiles such as developers, managers, architects, administrators, and several databases. Security with ACL administration quickly becomes a nightmare and needs to be industrialized and automated. Lets see how Redis Enterprise manage this example.

# Simple Redis ACLs limits
Despite Redis is widely known and used by developers as a database, the security belongs to Ops who are not always aware of the security features. Since version 6, Redis includes authentication by username and data access authorizations with Access Control Lists (ACL). 

Ok, lets have a look at their needed permissions, on the cluster and databases. We potentially need to create the users in each database.

| Account         | Cluster  | Orders DB                                  | Products DB                                | Messaging DB                               |
|:----------------|:---------|:-------------------------------------------|:-------------------------------------------|:-------------------------------------------|
| orders-update   | None     | -@all +@hash +@list -@dangerous ~*         | None                                       | -@all +@publish +@subscribe -@dangerous ~* |
| orders-invoice  | None     | -@all +@hash +@list -@dangerous -@write ~* | None                                       | -@all +@subscribe -@dangerous ~*           |
| products-update | None     | None                                       | -@all +@hash +@list -@dangerous ~*         | -@all +@publish +@subscribe -@dangerous ~* |
| products-stocks | None     | None                                       | -@all +@hash +@list -@dangerous -@write ~* | -@all +@subscribe -@dangerous ~*           |
| Angélina        | Full     | -@all +@admin +@dangerous                  | -@all +@admin +@dangerous                  | -@all +@admin +@dangerous                  |
| Paul            | Database | -@all +@hash +@list -@dangerous ~*         | None                                       | -@all +@publish +@subscribe -@dangerous ~* |
| Pierre          | Database | None                                       | -@all +@hash +@list -@dangerous ~*         | -@all +@publish +@subscribe -@dangerous ~* |
| David           | Monitor  | -@all +@hash +@list -@dangerous -@write ~* | None                                       | -@all +@subscribe -@dangerous ~*           |
| Denis           | Monitor  | None                                       | -@all +@hash +@list -@dangerous -@write ~* | -@all +@subscribe -@dangerous ~*           |

![Slides - 11.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/fc3c0eaa42084fcb8a56b7ff628e3cc0.png" | relative_url }})

You would have to connect to each database, create all the accounts with a password, then to create the ACLs individually. a project needs to change the ACL, it needs to be changed for all the relevant users in each database, individually. What a pain to maintain when a new developer join or leave one or several projects, when new projects are created, when projects need access to different datastructures ... Let's try to factorize these. 

# Implementing roles with Redis Enterprise
On top of ACLs, Redis Enterprise implemented TLS mutual authentication and Roles Based Access Control (RBAC) to make the ACL management more efficient and more scalable with multiple databases. What are the best practices on how to implement authentication, ACLs and roles in Redis Enterprise, and what can be easily achieved with them ?

Redis Enterprise Roles can be compared to groups or profiles. A role grants permissions globally on the Redis enterprise cluster and apply specific ACLs on each database. It creates the accounts and configure the ACL automatically in each relevant database.

## Create databases
You can create them with the web admin interface
![63fda6e9a28eb76aa3b8e2cb10ee20cf.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/99399910140d46b9967ec98f07929790.png" | relative_url }})

or with the REST API

```bash
function DBCreate {
  dbname='"name":"'"$1"'",'
  dbsize='"memory_size":'"${2:-102400}"','
  dbcfg="$3"
  curl -k -u "francois@redislabs.com:password" --request POST --url "https://localhost:9443/v1/bdbs" --header 'content-type: application/json' --data '{
    '${dbname}'
    '${dbsize}'
    '${dbcfg}'
  }';
}
function DBFindUidByName {
  dbname="$1"
  # Find the DB UID by name
  dbid=`curl -s -k -u "francois@redislabs.com:password" --request GET --url "https://localhost:9443/v1/bdbs" --header 'content-type: application/json' | jq '.[]|select(.name=="'${dbname}'").uid'`
  echo $dbid
}

function DBUpdate {
  dbname="$1"
  config="$2"
  dbid=`DBFindUidByName "${dbname}"`
  # Update the DB configuration
  curl -k -u "francois@redislabs.com:password" --request PUT --url "https://localhost:9443/v1/bdbs/${dbid}" --header 'content-type: application/json' --data '{
    '"${config}"'
  }';
}

function DBDelete {
  dbname="$1"
  dbid=`DBFindUidByName "${dbname}"`
  # Delete the database
  curl -k -u "francois@redislabs.com:password" --request DELETE --url "https://localhost:9443/v1/bdbs/${dbid}" --header 'content-type: application/json'
}

DBCreate orders 102400 '"port":12000'
DBCreate products 102400 '"port":12001'
DBCreate messaging 102400 '"port":12002'
```
![0105ea156ea70f059d4b5fa1cdd1c09f.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/699b2f4706a441f283e20a3acda0cc77.png" | relative_url }})

![4a40e838816d27249fe710aafb86a5eb.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/deee53833c1e495298fc5b2f2573cc8d.png" | relative_url }})

## Create the accounts

![Slides - 21.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/c4ccd935d0e34c77ba1a1724acb7da67.png" | relative_url }})

The accounts can be created with the web interface
![042a8e64dd6614bb6e49cda533d47d3c.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/bf77c709def54075893f98fac7c9cb93.png" | relative_url }})

```bash
function UserCreate {
  username='"name":"'$1'",'
  useremail='"email":"'$2'",'
  userpass='"password":"'${3:-$1}'",'
  curl -k -u "francois@redislabs.com:password" --request POST --url "https://localhost:9443/v1/users" --header 'content-type: application/json' --data '{
     '${username}'
     '${useremail}'
     '${userpass}'
     "role": "none"
  }'
}

function UserFindUidByName {
  username="$1"
  # Find Account UID by name
  uuid=`curl -s -k -u "francois@redislabs.com:password" --request GET --url "https://localhost:9443/v1/users" --header 'content-type: application/json' | jq '.[]|select(.name=="'${username}'").uid'`
  echo ${uuid}
}

function UserUpdate {
  username="$1"
  usercfg="$2"
  uuid=`UserFindUidByName "${username}"`
  curl -k -u "francois@redislabs.com:password" --request PUT --url "https://localhost:9443/v1/users/${uuid}" --header 'content-type: application/json' --data '{'"${usercfg}"'}'
}

function UserDelete {
  username="$1"
  uuid=`UserFindUidByName "${username}"`
  curl -k -u "francois@redislabs.com:password" --request DELETE --url "https://localhost:9443/v1/users/${uuid}" --header 'content-type: application/json'
}


# Users
for u in orders-update orders-invoice products-update products-stocks Angelina Paul Pierre David Denis; do
  UserCreate "${u}" "${u}@example.org" "${u}"
done
```

![35fd63152d9c443af3f9feea097d8774.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/7f38a122aff04a848a4968501a6daf64.png" | relative_url }})

![7c54e3641f547d765a48d8a78c43132f.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/67e9b5f97c254476bdb0e756e082aa8c.png" | relative_url }})

## Create the ACL
We can easily identify five distinct ACL : read-write access or read-only access to data, publish-subscribe or subscribe-only access to channels, and database administration.

| ACL Name | ACL definition                             |
|:---------|:-------------------------------------------|
| DataRW   | -@all +@hash +@list -@dangerous ~*         |
| DataRO   | -@all +@hash +@list -@dangerous -@write ~* |
| MsgRW    | -@all +@publish +@subscribe -@dangerous ~* |
| MsgRO    | -@all +@subscribe -@dangerous ~*           |
| DBAdmin  | -@all +@admin +@dangerous                  |

![Slides - 27.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/81babc2465fb48d1b9377b28380a471a.png" | relative_url }})

The ACLs can be created with the web administration interface

![39a89571a7e5ffc26f5ada0a2930b723.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/2e098537cbe0497e8477cb2f33feb662.png" | relative_url }})

or with REST API calls. I wrote a bash function helper to make them more friendly.

```bash
function ACLCreate {
  aclname="$1"
  acltext="$2"
  curl -k -u "francois@redislabs.com:password" --request POST --url "https://localhost:9443/v1/redis_acls" --header 'content-type: application/json' --data '{"name": "'"${aclname}"'", "acl": "'"${acltext}"'" }' 
}

function ACLFindUidByName {
  aclname="$1"
  # Find ACL UID by name
  uuid=`curl -s -k -u "francois@redislabs.com:password" --request GET --url "https://localhost:9443/v1/redis_acls" --header 'content-type: application/json' | jq '.[]|select(.name=="'"${aclname}"'").uid'`
  echo ${uuid}
}

function ACLUpdate {
  aclname="$1"
  acltext="$2"
  acluid=`ACLFindUidByName "${aclname}"`
  curl -k -u "francois@redislabs.com:password" --request PUT --url "https://localhost:9443/v1/redis_acls/${acluid}" --header 'content-type: application/json' --data '{"acl":"'"${acltext}"'"}'
}

function ACLDelete {
  aclname="$1"
  acluid=`ACLFindUidByName "${aclname}"`
  curl -k -u "francois@redislabs.com:password" --request DELETE --url "https://localhost:9443/v1/redis_acls/${acluid}" --header 'content-type: application/json'
}

ACLCreate "DataRW"  '-@all +@hash +@list -@dangerous ~*'
ACLCreate "DataRO"  '-@all +@hash +@list -@dangerous -@write ~*'
ACLCreate "MsgRW"   '-@all +publish +subscribe -@dangerous ~*'
ACLCreate "MsgRO"   '-@all +subscribe -@dangerous ~*'
ACLCreate "DBAdmin" '-@all +@admin +@dangerous'
```

![809e29ae93fb9b653e80015672449324.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/42d10acfbf124e06951f4d51d4e8f1ce.png" | relative_url }})

## Create the roles
With these definitions, we can more easily see patterns :

| Account         | Cluster  | Orders DB | Products DB | Messaging DB |
|:----------------|:---------|:----------|:------------|:-------------|
| orders-update   | None     | DataRW    | None        | MsgRW        |
| orders-invoice  | None     | DataRO    | None        | MsgRO        |
| products-update | None     | None      | DataRW      | MsgRW        |
| products-stocks | None     | None      | DataRO      | MsgRO        |
| Angélina        | Full     | DBAdmin   | DBAdmin     | DBAdmin      |
| Paul            | Database | DataRW    | None        | MsgRW        |
| Pierre          | Database | None      | DataRW      | MsgRW        |
| David           | Monitor  | DataRO    | None        | MsgRO        |
| Denis           | Monitor  | None      | DataRO      | MsgRO        |

The Redis Enterprise cluster can grant cluster permissions to roles and each Redis Enterprise database can grant specific ACLs to a role. The idea is to create a distinct role per unique permission set, each unique line in the table. Thus, for our simple case, we need to create nine roles, one for each possible combination. A role is an account profile or an account group with the same permissions on the cluster and on the databases.

| Roles        | Cluster admin. | Orders DB | Products DB | Messaging DB |
|:-------------|:---------------|:----------|:------------|:-------------|
| Orders-RW    | None           | DataRW    | None        | MsgRW        |
| Orders-RO    | None           | DataRO    | None        | MsgRO        |
| Products-RW  | None           | None      | DataRW      | MsgRW        |
| Products-RO  | None           | None      | DataRO      | MsgRO        |
| Global-ADM   | Admin          | DBAdmin   | DBAdmin     | DBAdmin      |
| Orders-PM    | DB-Member      | DataRW    | None        | MsgRW        |
| Products-PM  | DB-Member      | None      | DataRW      | MsgRW        |
| Orders-DEV   | DB Viewer      | DataRO    | None        | MsgRO        |
| Products-DEV | DB-Viewer      | None      | DataRO      | MsgRO        |

![Slides - 37.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/c8fcce7107544143aabe8961df5d81f2.png" | relative_url }})



The cluster permissions are directly and globally assigned to the role, let's create them with the web administration interface first

![8a955640a7a961d3711421362b961106.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/4bf886dcade44b0690827960315ed156.png" | relative_url }})

And then with the REST API and an helper function

```bash
function RoleCreate {
  rolename="$1"
  roleperm="$2"
  curl -k -u "francois@redislabs.com:password" --request POST --url "https://localhost:9443/v1/roles" --header 'content-type: application/json' --data '{"name": "'"${rolename}"'", "management": "'"${roleperm}"'" }'  
}

function RoleFindUidByName {
  rolename="$1"
  # Find Role UID by name
  ruid=`curl -s -k -u "francois@redislabs.com:password" --request GET --url "https://localhost:9443/v1/roles" --header 'content-type: application/json' | jq '.[]|select(.name=="'"${rolename}"'").uid'`
  echo ${ruid}
}

function RoleUpdate {
  rolename="$1"
  roleperm="$2"
  roleuid=`RoleFindUidByName "${rolename}"`
  curl -k -u "francois@redislabs.com:password" --request PUT --url "https://localhost:9443/v1/roles/${roleuid}" --header 'content-type: application/json' --data '{"management":"'"${roleperm}"'"}'
}

function RoleDelete {
  rolename="$1"
  roleuid=`RoleFindUidByName "${rolename}"`
  curl -k -u "francois@redislabs.com:password" --request DELETE --url "https://localhost:9443/v1/roles/${roleuid}" --header 'content-type: application/json'
}

RoleCreate "Orders-RW"    "none"
RoleCreate "Orders-RO"    "none"
RoleCreate "Products-RW"  "none"
RoleCreate "Products-RO"  "none"
RoleCreate "Global-ADM"   "admin"
RoleCreate "Orders-PM"    "db_member"
RoleCreate "Products-PM"  "db_member"
RoleCreate "Orders-DEV"   "db_viewer"
RoleCreate "Products-DEV" "db_viewer"
```

![f6d0f8606349c0d0dae28e813f326d53.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/f8712f703f364c818d541bc2085b738d.png" | relative_url }})

## Map ACLs to roles in each database

![Slides - 46.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/c803f2fbde2048a4bf8580475bb6d083.png" | relative_url }})



The Web administration interface makes some convenience abstractions to map ACLs to Roles for each database under the unified *roles* page. 

![a45c4d53a879039697f0c106217e962a.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/7a0ab21853824a3aa94ac1fc5379a3eb.png" | relative_url }})

The REST API is operating at a lower level, directly manipulating the role-acl mapping in the database definitions. Let's create the mapping for the *orders* database and remove the default anonymous account access.

| Roles        |  Orders DB |
|:-------------|:-----------|
| Orders-RW    | DataRW     |
| Orders-RO    | DataRO     |
| Global-ADM   | DBAdmin    |
| Orders-PM    | DataRW     |
| Orders-DEV   | DataRO     |

I define a first bash helper function, to lookup roles and ACLs uid and build the mapping JSON objects, and a second one to apply a configuration change to a database.

```bash
function RoleACLMap {
  rolename=$1
  aclname=$2
  roleuid=`RoleFindUidByName "${rolename}"`
  acluid=`ACLFindUidByName "${aclname}"`
  # Build the JSON object to map the ACL to the role
  echo '{"redis_acl_uid": '${acluid}',"role_uid": '${roleuid}'}'
}

mapping="`RoleACLMap Orders-RW DataRW`"
mapping="${mapping},`RoleACLMap Orders-RO DataRO`"
mapping="${mapping},`RoleACLMap Global-ADM DBAdmin`"
mapping="${mapping},`RoleACLMap Orders-PM DataRW`"
mapping="${mapping},`RoleACLMap Orders-DEV DataRO`"
DBUpdate "orders" '"roles_permissions":['"$mapping"']'
```

![0a05afe4012f0d9b0fdcfcdf1da7ff95.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/c19061884ba64f80a2f5ac1e71762578.png" | relative_url }})

Let's create the mapping for the *products* database.

| Roles        | Products DB |
|:-------------|:------------|
| Products-RW  | DataRW      |
| Products-RO  | DataRO      |
| Global-ADM   | DBAdmin     |
| Products-PM  | DataRW      |
| Products-DEV | DataRO      |

```bash
mapping="`RoleACLMap Products-RW DataRW`"
mapping="${mapping},`RoleACLMap Products-RO DataRO`"
mapping="${mapping},`RoleACLMap Global-ADM DBAdmin`"
mapping="${mapping},`RoleACLMap Products-PM DataRW`"
mapping="${mapping},`RoleACLMap Products-DEV DataRO`"
DBUpdate "products" '"roles_permissions":['"$mapping"']'
```

![9d9fb4315c0981f9e33f0f499c3ed6db.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/f6da6dc537a449ad805d3bcefcf60214.png" | relative_url }})

And finally, define the mappings for the messaging database.

| Roles        | Messaging DB |
|:-------------|:-------------|
| Orders-RW    | MsgRW        |
| Orders-RO    | MsgRO        |
| Products-RW  | MsgRW        |
| Products-RO  | MsgRO        |
| Global-ADM   | DBAdmin      |
| Orders-PM    | MsgRW        |
| Products-PM  | MsgRW        |
| Orders-DEV   | MsgRO        |
| Products-DEV | MsgRO        |

```bash
mapping="`RoleACLMap Orders-RW MsgRW`"
mapping="${mapping},`RoleACLMap Orders-RO MsgRO`"
mapping="${mapping},`RoleACLMap Products-RW MsgRW`"
mapping="${mapping},`RoleACLMap Products-RO MsgRO`"
mapping="${mapping},`RoleACLMap Global-ADM DBAdmin`"
mapping="${mapping},`RoleACLMap Orders-PM MsgRW`"
mapping="${mapping},`RoleACLMap Products-PM MsgRW`"
mapping="${mapping},`RoleACLMap Orders-DEV MsgRO`"
mapping="${mapping},`RoleACLMap Products-DEV MsgRO`"
DBUpdate "messaging" '"roles_permissions":['"$mapping"']'
```

![5f0c5224dd81579a23eac4c0e52d7622.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/6fb6ef7283ba425d9a763c942b97fbc0.png" | relative_url }})

## Disable default anonymous account
Ok, now that we defined restricted permissions, we need to disable the default anonymous account in each database.

![395f482c6dcde00f8a59558589dea532.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/6ed55c8bb42e47029c419b3979889745.png" | relative_url }})

```bash
DBUpdate "orders" '"default_user": false'
DBUpdate "products" '"default_user": false'
DBUpdate "messaging" '"default_user": false'
```

## Assign a roles to each account
So, we defined 
- a read-only application role,
- a read-write application role,
- a read-ony with limited admin permission developer role,
- a read-write product manager role
on the needed database for each microservice and a global administrator only role.

Lets assign roles to the accounts :

| Account         | Role         |
|:----------------|:-------------|
| orders-update   | Orders-RW    |
| orders-invoice  | Orders-RO    |
| products-update | Products-RW  |
| products-stocks | Products-RO  |
| Angélina        | Global-ADM   |
| Paul            | Orders-PM    |
| Pierre          | Products-PM  |
| David           | Orders-DEV   |
| Denis           | Products-DEV |

![Slides - 55.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/1c8e390d70884e1fb797ba3da16d5b34.png" | relative_url }})

![077ef01dcf688381e38dafbb78d57c96.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/d92d6d91f6ee430bbdc64741e5741064.png" | relative_url }})

```bash
function UserSetRole {
  username=$1
  rolename=$2
  roleuid=`RoleFindUidByName "${rolename}"`
  UserUpdate "${username}" '"role_uids":['${roleuid}']'
}
UserSetRole "orders-update" "Orders-RW"
UserSetRole "orders-update" "Orders-RW"
UserSetRole "orders-invoice" "Orders-RO"
UserSetRole "products-update" "Products-RW"
UserSetRole "products-stocks" "Products-RO"
UserSetRole "Angelina" "Global-ADM"
UserSetRole "Paul" "Orders-PM"
UserSetRole "Pierre" "Products-PM"
UserSetRole "David" "Orders-DEV"
UserSetRole "Denis" "Products-DEV"
```

![92f044d3fd65d8913a40db2ef937c635.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/91b2ee3c797d4955ae1fea2d7a90fa32.png" | relative_url }})
![6e3439daadf1b1b4888ce041d164ca9d.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/6ba50c6b5e4541689ecc0222c03c887b.png" | relative_url }})

# Permissions tests
I wrote a script to test a set of meaningful commands with each account on each database. 

```bash
cat << "EOF" > RBAC-tests.sh
#!/bin/bash
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
B='\033[1;36m'
P='\033[1;35m'
LG='\033[0;37m'
N='\033[0m'

function CmdTest {
DBPORT=$1
DBUSER=$2
DBPASS=$3
DESC=$4
CMD="$5"
ERR=$6
echo -en " - ${DESC} (${P}${CMD}${N}): "
RES=`echo "${CMD}" | timeout 1 redis-cli --user ${DBUSER} --pass ${DBPASS} -p ${DBPORT} 2> /dev/null | tr '\r' ','`
echo "${RES}" | grep "${ERR}" > /dev/null 2>&1
[ $? -eq 0 ] && echo -en ${R} || echo -en ${G}
echo -e ${RES}${N}
}

function BatchTest {
DBUSER=$1
DBPASS=$2
DBNAME=$3
DBPORT=$4
echo
echo -e ${LG}Database${N}: ${Y}${DBNAME}${N}\(${Y}${DBPORT}${N}\), ${LG}User${N}: ${B}${DBUSER}${N}, ${LG}Password${N}: ${B}${DBPASS}${N}
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "STRING Write            " "SET key value" '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "STRING Read             " "GET key" '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "HASH Write              " "HSET order:key field1 value1 field2 value2" '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "HASH Read               " "HGETALL order:key" '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "LIST Write              " "LPUSH order:key:sub value1" '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "LIST Write              " "LPUSH order:key:sub value2" '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "LIST Read               " "LLEN order:key:sub" '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "LIST Read+Write         " "LPOP order:key:sub" '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "PUBSUB Write            " "PUBLISH channel msg" '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "PUBSUB Read             " "SUBSCRIBE channel" '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "STREAM Write            " 'XADD mystream * item 1' '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "STREAM Read             " "XLEN mystream" '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "Generic commands        " "INFO KEYSPACE" '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
CmdTest ${DBPORT} ${DBUSER} ${DBPASS} "DANGEROUS ADMIN commands" "FLUSHALL" '\(ERR\|WRONGPASS\|(error)\|NOAUTH\|NOPERM\)'
}

for account in orders-update orders-invoice products-update products-stocks Angelina Paul Pierre David Denis Didier; do
clear
BatchTest ${account} ${account} orders 12000
BatchTest ${account} ${account} products 12001
BatchTest ${account} ${account} messaging 12002
read
done
EOF
chmod +x RBAC-tests.sh
./RBAC-tests.sh
```

For *orders-update*
![66ed1a36882f850e4769c9c66f1e54b8.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/6c237af6bc414f9fae13cea181372a4e.png" | relative_url }})

For *orders-invoice*
![b16b1b38b04b311c2a79eb3b385181e8.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/66581cbe080044fda397887dc1e5ecd9.png" | relative_url }})

and so on, you can execute it yourself with the code available in my blog or zoom on my results.

# Permissions maintenance
We initialized the projects, but things can change.

## A new employee joins
A new developer, Didier, joins the orders team.

![Slides - 56.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/702e407f3f71433a8ecaf303049c4c0a.png" | relative_url }})

We only have to give him the *Orders-DEV* role and he will have the appropriate permissions on the cluster and the data.

```bash
UserCreate "Didier" "Didier@example.org" "Didier"
UserSetRole "Didier" "Orders-DEV"
```

## A developer switches to another team
The existing developer, David, moves to the products team.

![Slides - 57.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/e7d208a5788c450eb16255d53b9b8cab.png" | relative_url }})


We only have to change his role, and he will no longer have his previous permissions, but only the new permissions.

```bash
UserSetRole "David" "Products-DEV"
```

## An employee leaves
A developer, Denis, leaves the company.

![Slides - 58.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/33de59415b6c47fabb3f57644c4eea0b.png" | relative_url }})

We only have to delete or disable this accounts.
```bash
UserDelete "Denis"
```

## Access to new structures
Streams usage needed in messaging DB.

![Slides - 59.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/3bf90d9456944ecf9bb8c69ff939eabc.png" | relative_url }})

The messaging features need to use *streams* commands, from now, we only have to update the *Msg-RO* and *Msg-RW* ACLs.

```bash
ACLUpdate "MsgRW"   '-@all +publish +subscribe +@stream -@dangerous ~*'
ACLUpdate "MsgRO"   '-@all +subscribe +@stream -@write -@dangerous ~*'
```

# Wrap-up and LDAP

Applications, developers, project managers and admins are uniquely identified with their own authentication and have specific permissions on the cluster and on the data. My next contents will talk about LDAP to roles mapping, because it is a pain to maintain when new people are hired, when people leave, when people move from one project to another, when people work on several projects...  whereas all these information are already available and maintained up-to-date in the Enterprise LDAP.

# Materials and Links

| Link | Description |
|---|---|
| [Video] | Video with explanation and demo |

# Footnotes

[Video]: https://youtu.be/eeJu15azF2Y "Video with explanation and demo"
