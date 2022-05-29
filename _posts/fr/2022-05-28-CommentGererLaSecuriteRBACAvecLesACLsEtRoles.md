---
uid: HowtomanageRBACsecuritywithACLandRole
title: Redis 10 - Comment gérer la sécurité RBAC avec les ACLs et rôles
description: 
category: Redis en 5 minutes
tags: [ Redis, Authentification, Autorisations, Permissions, Rôles, ACL, RBAC, Contrôle d'accès, Accès, Sécurité, Administration, Groupes de sécurité, REST, API REST ]
date: 2022-05-28 16:07:52 +02:00
published: false
---

Les ACL Redis peuvent authentifier un compte et accorder des permissions sur les données et les commandes dans une base Redis. Comment utiliser le contrôle d'accès basé sur les roles (RBAC) pour gérer des groupes avec des permissions similaires sur différentes bases. Démo incluse.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

* TOC
{:toc}

# Vidéo d'explication et de démo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/hFKZHZrpusM" frameborder="0" allowfullscreen></iframe></center>

# Préparation de l'environnement

```bash 
# Démarrage de Redis Enterprise
docker run -d --cap-add sys_resource --name redisenterprise -p 8443:8443 -p 9443:9443 -p 12000:12000 -p 12001:12001 -p 12002:12002 redislabs/redis
sleep 20

# Initialisation du cluster
docker exec -d --privileged redisenterprise "/opt/redislabs/bin/rladmin" cluster create name cluster.local username francois@redislabs.com password password
sleep 15
```

# Prérequis
Ce contenu suppose que vous connaissez déjà les ACLs Redis. Si vous ne l'avez pas déjà vu, je vous recommende de regarder le contenu sur [Comment gérer sécurité, accès aux données et permissions avec les ACL de Redis][RedisACLs] avant celui-ci. Si vous voulez reproduire la démonstration, vous aurez besoin de *docker*, *curl* et *jq*. Les commandes ne sont pas en pur shell POSIX mais font aussi appel à des extensions *bash*.
![2022-05-28_20-23.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/2022-05-28_20-23.png" | relative_url }})

# Un problème de sécurité et de conformité
Redis est utilisé dans presque toutes les entreprises dans le monde. Le contrôle d'accès aux données est critique pour assurer la sécurité des données et pour respecter la conformité aux règles comme RGPD (GDPR). Chaque connexion entrante doit être authentifiée et doit potentiellement reçevoir des permissions ou privilèges sur les bases disponibles, les commandes à exécuter et les données.

Imaginons que nous disposions de trois bases :
- une base *orders* pour y enregistrer les commandes et les lignes de commandes ;
- une base *products* pour enregistrer le catalogue des produits et leur
  quantité restante en stocks ;
- une base *messaging* servant de bus de communication entre les microservices à
  l'aide des fonctionalités PubSub de Redis.

Ajoutons à cela deux microservices, chacun ayant deux points de connexion
(endpoints) :
- un microservice pour gérer les commandes dans la base *orders*, avec deux
  points de connexion : *orders-update* pour créer et modifier les commandes,
  nécessitant des permissions de lecture et d'écriture, et *orders-invoice*,
  pour générer les factures, avec des permissions en lecture seule. Ils doivent
  aussi accéder à la base servant de bus de communication respectivement en
  lecture-écriture et en lecture-seule ;
- l'autre microservice se charge de la gestion du catalogue produit et des
  stocks, avec deux points de connexion : *products-update* pour mettre le
  catalogue et les quantités à jour, et *products-stocks* pour vérifier la
  disponibilité d'un produit. Ils doivent aussi accéder à la base servant de bus
  de communication respectivement en lecture-écriture et en lecture-seule.

Puis, il y a les personnes :
- un administrateur, *Angélina*, qui n'a pas besoin d'accéder aux données ;
- deux chefs de projet, *Paul* pour le projet *orders* et *Pierre*, pour le
  projet *products*. Ils doivent pouvoir accéder aux données de leur projet en
  lecture et écriture pour les modifier, ainsi qu'au bus de messages. Ils
  doivent accéder aux journaux, à la configuration des bases et à la supervision
  ;
- deux développeurs, *David*, travaillant sur le projet *orders* avec un accès
  en lecture seule sur les données, et *Denis*, travaillant sur le projet
  *products*.  Ils doivent aussi avoir un accès en lecture seule sur le bus de
  communication PubSub Redis. Ils doivent avoir accès à la supervision des
  bases.

C'est un exemple relativement simple, comparé aux besoins des entreprises dans
la vraie vie. Les permissions sont simples à mettre en place, mais pas à
maintenir ou à faire passer à l'échelle si vous avez plusieurs projets, profiles
(développeurs, managers, chefs de projets, architectes, administrateurs) et
bases de données. L'administration de la sécurité avec les ACL Redis peut
rapidement devenir un cauchemard et doit être industrialisée et automatisée.
Voyons comment Redis Entreprise peut gérer cet exemple.

# Limites des ACL Redis
Bien que Redis soit largement connu et utilisé par les développeurs comme base
de données, la gestion de la sécurité dépend des ops qui ne sont pas toujours au
courant des fonctionnalités de sécurité de Redis. Depuis la version 6, Redis
inclut l'authentification par identifiant et la gestion des autorisations 
d'accès aux données par des ACL, Access Control Lists, listes de contrôle
d'accès.

Regardons quelles sont les permissions nécessaires, tant sur le cluster que sur
les bases. Il faudra potentiellement créer manuellement les utilisateurs dans
chaque base de données.

| Compte          | Cluster  | Base "orders"                              | Base "products"                            | Base "messaging"                           |
|:----------------|:---------|:-------------------------------------------|:-------------------------------------------|:-------------------------------------------|
| orders-update   | Aucune   | -@all +@hash +@list -@dangerous ~*         | Aucune                                     | -@all +@publish +@subscribe -@dangerous ~* |
| orders-invoice  | Aucune   | -@all +@hash +@list -@dangerous -@write ~* | Aucune                                     | -@all +@subscribe -@dangerous ~*           |
| products-update | Aucune   | Aucune                                     | -@all +@hash +@list -@dangerous ~*         | -@all +@publish +@subscribe -@dangerous ~* |
| products-stocks | Aucune   | Aucune                                     | -@all +@hash +@list -@dangerous -@write ~* | -@all +@subscribe -@dangerous ~*           |
| Angélina        | Totale   | -@all +@admin +@dangerous                  | -@all +@admin +@dangerous                  | -@all +@admin +@dangerous                  |
| Paul            | Base     | -@all +@hash +@list -@dangerous ~*         | Aucune                                     | -@all +@publish +@subscribe -@dangerous ~* |
| Pierre          | Base     | Aucune                                     | -@all +@hash +@list -@dangerous ~*         | -@all +@publish +@subscribe -@dangerous ~* |
| David           | Superv.  | -@all +@hash +@list -@dangerous -@write ~* | Aucune                                     | -@all +@subscribe -@dangerous ~*           |
| Denis           | Superv.  | Aucune                                     | -@all +@hash +@list -@dangerous -@write ~* | -@all +@subscribe -@dangerous ~*           |

![Slides - 11.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/fc3c0eaa42084fcb8a56b7ff628e3cc0.png" | relative_url }})

Avec les ACL Redis, sans les rôles, il faut créer chaque compte dans chaque base
de donnée, avec un mot de passe, puis créer les ACLs individuellement. Si un
projet doit changer de permissions, elles doivent être mises à jour
individuellement dans chaque compte de chaque base. Quelle complexité lorsque
les les projets changent les structures de données auxquelles ils doivent
accéder. Essayons de factoriser tout cela.

# Mise en place
Au-delà des ACLs, Redis Enterprise implémente une authentification mutuelle par
TLS et un contrôle d'accès par role (RBAC) pour rendre la gestion des ACLs plus
efficace et plus scalable au moment de gérer plusieurs projets avec de
nombreuses personnes et plusieurs bases. Quelles sont les meilleurs pratiques
pour implémenter l'authentification, les ACLs et les rôles dans Redis Enterprise
? Que peut on attendre de Redis Enterprise ?

Les rôles de Redis Enterprise peuvent être comparés à des groupes ou des
profiles. Un rôle accorde des permissions globalement sur le cluster Redis
Enterprise et des ACLs ciblées sur chacune des bases. Il créée et configure des
comptes et des ACLs automatiquement dans chaque base.

Dans chaque base, on peut définir les ACLs à appliquer aux comptes en fonction
de leur rôle.

## Création des bases
On peut créer des bases manuellement dans l'interface web
![63fda6e9a28eb76aa3b8e2cb10ee20cf.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/99399910140d46b9967ec98f07929790.png" | relative_url }})

ou automatiquement, par script, grâce à l'API REST.

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

## Création des comptes

![Slides - 21.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/c4ccd935d0e34c77ba1a1724acb7da67.png" | relative_url }})

Encore une fois, les comptes peuvent être créés manuellement dans l'interface
web d'administration :

![042a8e64dd6614bb6e49cda533d47d3c.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/bf77c709def54075893f98fac7c9cb93.png" | relative_url }})

ou de manière automatisée, grâce à l'API REST de gestion du cluster.

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


# Comptes
for u in orders-update orders-invoice products-update products-stocks Angelina Paul Pierre David Denis; do
  UserCreate "${u}" "${u}@example.org" "${u}"
done
```

![35fd63152d9c443af3f9feea097d8774.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/7f38a122aff04a848a4968501a6daf64.png" | relative_url }})

Au final, le résultat est identique :

![7c54e3641f547d765a48d8a78c43132f.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/67e9b5f97c254476bdb0e756e082aa8c.png" | relative_url }})

## Création des ACLs
On peut facilement identifier cinq ACLs distinctes :
- Accès en lecture-écriture sur les données ;
- Accès en lecture seule sur les données ;
- Accès en consultation-publication sur des channels de communication ;
- Accès en consultation seule sur les channels de communication ;
- Accès aux commandes d'administration de la base.

![Slides - 27.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/81babc2465fb48d1b9377b28380a471a.png" | relative_url }})

| Nom ACL  | Définition ACL                             |
|:---------|:-------------------------------------------|
| DataRW   | -@all +@hash +@list -@dangerous ~*         |
| DataRO   | -@all +@hash +@list -@dangerous -@write ~* |
| MsgRW    | -@all +@publish +@subscribe -@dangerous ~* |
| MsgRO    | -@all +@subscribe -@dangerous ~*           |
| DBAdmin  | -@all +@admin +@dangerous                  |

Ces ACLs peuvent être créées manuellement depuis l'interface web
d'administration :

![39a89571a7e5ffc26f5ada0a2930b723.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/2e098537cbe0497e8477cb2f33feb662.png" | relative_url }})

Ou depuis l'API REST pour automatiser et industrialiser leur gestion :

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

Dans les deux cas, le résultat est le même et les ACLs sont créées :

![809e29ae93fb9b653e80015672449324.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/42d10acfbf124e06951f4d51d4e8f1ce.png" | relative_url }})

## Création des rôles
Il faut maintenant disposer de rôles pour choisir quelle ACL appliquer à quel
compte sur quelle base. On peut facilement identifier des motifs :

| Comptes         | Cluster  | Orders    | Products    | Messaging    |
|:----------------|:---------|:----------|:------------|:-------------|
| orders-update   | Aucune   | DataRW    | Aucune      | MsgRW        |
| orders-invoice  | Aucune   | DataRO    | Aucune      | MsgRO        |
| products-update | Aucune   | Aucune    | DataRW      | MsgRW        |
| products-stocks | Aucune   | Aucune    | DataRO      | MsgRO        |
| Angélina        | Totale   | DBAdmin   | DBAdmin     | DBAdmin      |
| Paul            | Base     | DataRW    | Aucune      | MsgRW        |
| Pierre          | Base     | Aucune    | DataRW      | MsgRW        |
| David           | Superv.  | DataRO    | Aucune      | MsgRO        |
| Denis           | Superv.  | Aucune    | DataRO      | MsgRO        |

Le cluster Redis Enterprise peut accorder des privilèges d'administration aux
rôles et chaque base du cluster peut accorder les permissions spécifiques d'ACL
prédéfinies à chaque rôle. L'idée est donc de créer un rôle distinct par jeu de
permission (cluster+bases) unique, par ligne distincte dans le tableau. Ainsi,
dans notre simple cas d'exemple, nous avons besoin de neuf rôles, un pour chaque
combinaison possible. Un rôle est un profile de compte ou un groupe de comptes
ayant les mêmes permissions et privilèges sur l'administration du cluster, sur
les bases, sur les commandes exécutables et sur les données accessibles.

| Roles        | Cluster admin. | Orders    | Products    | Messaging    |
|:-------------|:---------------|:----------|:------------|:-------------|
| Orders-RW    | Aucune         | DataRW    | Aucune      | MsgRW        |
| Orders-RO    | Aucune         | DataRO    | Aucune      | MsgRO        |
| Products-RW  | Aucune         | Aucune    | DataRW      | MsgRW        |
| Products-RO  | Aucune         | Aucune    | DataRO      | MsgRO        |
| Global-ADM   | Admin          | DBAdmin   | DBAdmin     | DBAdmin      |
| Orders-PM    | DB-Member      | DataRW    | Aucune      | MsgRW        |
| Products-PM  | DB-Member      | Aucune    | DataRW      | MsgRW        |
| Orders-DEV   | DB Viewer      | DataRO    | Aucune      | MsgRO        |
| Products-DEV | DB-Viewer      | Aucune    | DataRO      | MsgRO        |

Les droits d'administration du cluster étant attachés globalement aux rôles, il
faut donc les y inclure lors de la conception des droits d'accès et lors de la
création des rôles.

![Slides - 37.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/c8fcce7107544143aabe8961df5d81f2.png" | relative_url }})

Créons donc les rôles, soit dans l'interface web d'administration du cluster
Redis Enterprise...

![8a955640a7a961d3711421362b961106.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/4bf886dcade44b0690827960315ed156.png" | relative_url }})

Soit grâce à des appels d'API REST pour automatiser leur création...

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

On aboutit finalement au même résultat :

![f6d0f8606349c0d0dae28e813f326d53.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/f8712f703f364c818d541bc2085b738d.png" | relative_url }})

## Relations Rôle-ACL dans les bases

Chaque base de données peut accorder les permissions correspondantes à une ACL
prédéfinie à chaque compte en fonction de son rôle. Un compte membre du groupe
*Products-DEV* se verra accorder l'ACL *Msg-RO* sur la base *messaging* et l'ACL
*Data-RO* sur la base *products*, mais aucune ACL, et donc pas de compte, sur la
base *orders* :

![Slides - 46.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/c803f2fbde2048a4bf8580475bb6d083.png" | relative_url }})

L'interface d'administration web effectue une abstration de confort pour
associer les ACL à des rôles dans chaque base, à partir de la page d'édition des
rôles :

![a45c4d53a879039697f0c106217e962a.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/7a0ab21853824a3aa94ac1fc5379a3eb.png" | relative_url }})

Cependant, l'API REST donne accès au véritable modèle de données interne, sans
abstraction, et manipule directement les associations Rôle-ACL dans la
définition des bases. Créons ces associations Rôle-ACL pour la base *orders* :

| Roles        | Orders ACL |
|:-------------|:-----------|
| Orders-RW    | DataRW     |
| Orders-RO    | DataRO     |
| Global-ADM   | DBAdmin    |
| Orders-PM    | DataRW     |
| Orders-DEV   | DataRO     |

Un premier appel d'API REST permet de trouver l'identifiant interne d'un rôle,
un autre permet de trouver l'identifiant de l'ACL à y associer, pour construire
une association au format JSON. Ces associations sont concaténées dans un
tableau JSON et envoyées dans la configuration de la base par un ultime appel
d'API.

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

On peut le constater dans l'interface web d'administration.

![0a05afe4012f0d9b0fdcfcdf1da7ff95.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/c19061884ba64f80a2f5ac1e71762578.png" | relative_url }})

Configurons les associations Role-ACL pour la base *products* :

| Roles        | Products ACL |
|:-------------|:-------------|
| Products-RW  | DataRW       |
| Products-RO  | DataRO       |
| Global-ADM   | DBAdmin      |
| Products-PM  | DataRW       |
| Products-DEV | DataRO       |

```bash
mapping="`RoleACLMap Products-RW DataRW`"
mapping="${mapping},`RoleACLMap Products-RO DataRO`"
mapping="${mapping},`RoleACLMap Global-ADM DBAdmin`"
mapping="${mapping},`RoleACLMap Products-PM DataRW`"
mapping="${mapping},`RoleACLMap Products-DEV DataRO`"
DBUpdate "products" '"roles_permissions":['"$mapping"']'
```

![9d9fb4315c0981f9e33f0f499c3ed6db.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/f6da6dc537a449ad805d3bcefcf60214.png" | relative_url }})

Et finalement pour la base *messaging* :

| Roles        | Messaging ACL  |
|:-------------|:--------------|
| Orders-RW    | MsgRW         |
| Orders-RO    | MsgRO         |
| Products-RW  | MsgRW         |
| Products-RO  | MsgRO         |
| Global-ADM   | DBAdmin       |
| Orders-PM    | MsgRW         |
| Products-PM  | MsgRW         |
| Orders-DEV   | MsgRO         |
| Products-DEV | MsgRO         |

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

## Invalidation du compte anonyme par défaut
Ok, nous avons défini les ACLs et les rôles, nous avons accordé des permissions
(ACL) aux différents rôles dans chaque base, il faut éviter qu'un compte
n'appartenant pas à un rôle déclaré dans une base, un compte non créé dans la
base par le cluster Redis Enterprise, se voit accordé les permissions du compte
anonyme par défaut. Il faut donc désactiver ce compte anonyme dans chaque base,
soit à travers l'interface web :

![395f482c6dcde00f8a59558589dea532.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/6ed55c8bb42e47029c419b3979889745.png" | relative_url }})

Soit par des appels d'API REST :

```bash
DBUpdate "orders" '"default_user": false'
DBUpdate "products" '"default_user": false'
DBUpdate "messaging" '"default_user": false'
```

## Affectation des rôles aux comptes
Nous avons donc défini des ACL, des rôles, les ACLs accordées aux comptes
appartenant aux rôles dans les bases, pour chaque cas d'utilisation possible.

Il nous reste à assigner un rôle à chaque compte, pour qu'il bénéficie des ACLs
accordées à son rôle dans chaque base :

| Compte          | Role         |
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

Par exemple, le compte *Denis* dispose du rôle *Products-DEV* et aura donc l'ACL
*DataRO* sur la base *products* et l'ACL *Msg-RO* sur la base *messaging*, ce
qui correspond au besoin exprimé initialement.

![Slides - 55.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/1c8e390d70884e1fb797ba3da16d5b34.png" | relative_url }})

On peut faire cette association compte-rôle dans l'interface web, bien sûr :

![077ef01dcf688381e38dafbb78d57c96.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/d92d6d91f6ee430bbdc64741e5741064.png" | relative_url }})

Ou grâce à l'API REST, si on souhaite automatiser :

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

Au final, le résultat sera identique :

![92f044d3fd65d8913a40db2ef937c635.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/91b2ee3c797d4955ae1fea2d7a90fa32.png" | relative_url }})

Et les bases seront configurées correctement :

![6e3439daadf1b1b4888ce041d164ca9d.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/6ba50c6b5e4541689ecc0222c03c887b.png" | relative_url }})

# Test des permissions
J'ai écrit rapidement un script pour tester automatiquement les principales
commandes autorisables et celles supposées interdites, par chaque compte dans
chaque base.

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

Le résultat pour le compte *orders-update* sur les différentes bases est :
![66ed1a36882f850e4769c9c66f1e54b8.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/6c237af6bc414f9fae13cea181372a4e.png" | relative_url }})

puis pour *orders-invoice* :
![b16b1b38b04b311c2a79eb3b385181e8.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/66581cbe080044fda397887dc1e5ecd9.png" | relative_url }})

Et ainsi de suite. On constate que les permissions initialement définies sont
bien implémentées et appliquées aux différents comptes sur les différentes
bases.


# Maintenance des permissions
Après la phase de mise en place et d'initialisation des projets, les choses
peuvent changer.

## Arrivée d'un développeur
Un nouveau développeur, Didier, rejoint l'équipe de développement du projet
*orders*. 

![Slides - 56.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/702e407f3f71433a8ecaf303049c4c0a.png" | relative_url }})

Il n'y a pas besoin de créer son compte dans les bases *orders* et *messaging*,
puis de lui accorder des permissions spécifiques... Il suffit de lui attribuer
le rôle *Orders-DEV* et le cluster Redis Enterprise se chargera du reste.

```bash
UserCreate "Didier" "Didier@example.org" "Didier"
UserSetRole "Didier" "Orders-DEV"
```

## Changement de projet
Un développeur existant, David, est retiré du projet *orders* pour se trouver
affecter au projet *products*. 

![Slides - 57.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/e7d208a5788c450eb16255d53b9b8cab.png" | relative_url }})

Encore une fois, il est inutile de parcourir les différentes bases pour l'en
retirer, puis d'ajouter son compte et les permissions du projet *products* dans
les bases *products* et *messaging*. Il suffit de changer son rattachement pour
lui affecter le rôle *Products-DEV* :

```bash
UserSetRole "David" "Products-DEV"
```

## Départ d'un développeur
Un développeur, Denis, quitte le projet ou l'entreprise, que ce soit parce qu'il
démissionne ou qu'il était consultant externe ou stagiaire.

![Slides - 58.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/33de59415b6c47fabb3f57644c4eea0b.png" | relative_url }})

Il suffit de désactiver ou de supprimer son compte, le cluster Redis Enterprise
s'occupera de supprimer son compte, mot de passe et ACL de toutes les bases où
il avait été déclaré grâce à son rôle *Products-DEV*. Aucun risque d'erreur ou
de permissions fantômes.

```bash
UserDelete "Denis"
```

## Modification d'un projet
Désormais, les fonctionalités de bus de communication entre les microservices
nécessite l'utilisation des structures de données Streams de Redis. Il faut donc
autoriser l'utilisation des commandes liées aux Streams.

![Slides - 59.png](../{{ "/assets/posts/en/BlogVlogApprendreRedisAvecFrançois5minutes10HowtomanageRBACsecuritywithACLandRole/3bf90d9456944ecf9bb8c69ff939eabc.png" | relative_url }})

Pour cela, il suffit de mettre à jour les deux ACLs reflétant les permission de
lecture-seule *Msg-RO* et de lecture-écriture *Msg-RW* pour l'usage des
messages. Ces ACL sont accordées par les rôles à qui en a besoin, sur la base
*messaging*.

```bash
ACLUpdate "MsgRW"   '-@all +publish +subscribe +@stream -@dangerous ~*'
ACLUpdate "MsgRO"   '-@all +subscribe +@stream -@write -@dangerous ~*'
```

Les comptes ayant des rôles accordant ces ACLs seront automatiquement mis à jour
dans la base *messaging*, sans en oublier aucun et sans erreur.

# Conclusion et LDAP

Désormais, les applications, les développeurs, les chefs de projet et les
administrateurs sont authentifié par un identifiant et un mot de passe personnel
dans les bases auxquelles ils doivent avoir accès. Par ailleurs, il ne disposent
que des permissions nécessaires selon leur rôle dans ces bases et dans le
cluster. Mon prochain article traitera de l'association automatique entre LDAP
et les rôles. En effet, même si les rôles facilitent et industrialisent la
gestion des permissions pour éviter les oublis et les erreurs, ils dupliquent
des informations se trouvant déjà dans l'annuaire LDAP de l'entreprise. Autant
en bénéficier et refléter les informations du LDAP dans les rôles,
automatiquement et en temps réel.

# Supports et liens

| Liens | Description |
|---|---|
| [Video] | Vidéo d'explication et de démonstration |

# Notes de bas de page

[Video]: https://youtu.be/hFKZHZrpusM "Vidéo d'explication et de démonstration"
[RedisACLs]: {% post_url 2022-05-13-CommentGererSecuriteAccesAuxDonneesEtPermissionsAvecLesACLRedis-fr %} "ACL avec Redis"
