---
uid: 09Howtomanagesecuritydataaccessandpermi
title: Redis 09 - Comment gérer sécurité, accès aux données et permissions avec les ACL de Redis
description: Comment sécuriser Redis avec des identifiants et mots de passe pour l'authentification et avec des ACL pour l'accès aux commandes et aux données. Introduction, explication et démo des ACL de Redis.
category: Redis en 5 minutes
tags: [ Redis, Base de données, Accès aux données, Contrôle d'accès, Authentication, Authorisations, Permissions, ACL, Access Control Lists, Sécurité, Administration ]
date: 2022-05-13 16:58:06 +02:00
---

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

* TOC
{:toc}

# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/dyskQGkgdEY" frameborder="0" allowfullscreen></iframe></center>

# Introduction
Savez-vous que Redis peut être sécurisé par des comptes avec mots de passe pour
l'authentification et par des listes de controle d'accès pour les commandes et
l'accès aux données ? Voyons comment fonctionnent les ACL et comment les
utiliser.

# Un problème de sécurité
Jusqu'à la version 6, Redis n'avait qu'un unique utilisateur anonyme par défaut,
éventuellement avec un mot de passe, pour accorder les pleins pouvoirs. Cette
faiblesse de sécurité n'est pas un vrai problème pour les développeurs qui
aiment Redis pour sa flexibilité, ses performances et ses possibilités de
manipulation et de stockage des données. Ils l'utilisent partout, dans presque
toutes les entreprises. C'est un problème pour les ops et les équipes de
sécurité, mais ils s'y sont habitués. Ils, vous, ne savez peut-être pas que
Redis dispose de comptes nominatifs, avec des mots de passe individuels, pour
l'authentification et de listes de contrôles d'accès (ACL), pour la gestion des
autorisations et permissions. Redis peut être sécurisé, voyons comment cela
fonctionne et comment l'implémenter avec un exemple de projet.

# Limites de la solution existante
Nous disposons d'une unique base pour enregistrer les commandes et de deux
microservices, un pour modifier une commande, l'autre pour générer la facture.
C'est un projet, nous avons donc un développeur par microservice, David et
Denis, un chef de projet, Paul, et un administrateur, Angélina. Les
microservices et les personnes utilisent toutes le même compte anonyme avec son
unique mot de passe. Ce simple mot de passe leur donne un accès complet aux
données et aux commandes Redis. Chacun peut exécuter n'importe quelle commande,
avec le droit d'écriture, sur le jeu de données.

Lorsqu'un microservice a besoin de lire et d'écrire, alors que le second n'a
besoin que de lire, si le second a un bug, est corrompu ou compromis, il peut
corrompre les données du premier. Si un prestataire ou un stagiaire arrive, il
aura un accès complet aux données et l'unique mot de passe partagé ne sera
probablement pas changé à leur départ, il faudrait aussi modifier la
configuration des applications. Aucun audit n'est possible, pour vérifier qui a
fait quoi. Voyons comment Redis 6 permet de gérer ce problème de sécurité.

![Capture d’écran_2022-05-11_16-59-12.png](../{{ "/assets/posts/en/Howtomanagesecuritydataaccessandpermi/57eff1ee469c4c33b1672d5bfa0220e9.png" | relative_url }})

# Solution implémentée et résultats
Je suppose que les connexions à la base Redis sont chiffrées par TLS, sinon, les
mots de passe circulent en clair sur le réseau.

## Qu'est-ce qu'une ACL Redis
Une ACL, pour Access Control List, est une liste ordonée de règles ou ACE, pour
Access Control Entries. Chaque règle accorde ou retire des privilèges à un
compte nommé, sur des commandes Redis, des clés ou des channels. Le compte peut
être protégé par son propre mot de passe. Comment définir des ACL ?

```
acl setuser <account> [rulelist]
```

![Capture d’écran_2022-05-11_16-59-29.png](../{{ "/assets/posts/en/Howtomanagesecuritydataaccessandpermi/663e944fc6b0482ca4000a55e5242b31.png" | relative_url }})

![Capture d’écran_2022-05-11_16-59-47.png](../{{ "/assets/posts/en/Howtomanagesecuritydataaccessandpermi/682363d73c9b4f018161ed40284a812d.png" | relative_url }})

## Initialiser un compte
Un compte peut être initialisé, par la règle `reset`, avec un mot de passe
obligatoire mais non défini, sans règles, et désactivé.

```bash
# Initialise le compte sans obligation de mot de passe
redis-cli acl setuser francois reset nopass
# Connexion impossible, le compte est désactivé
redis-cli --user francois --pass 'nimportequoi' quit
```

## Désactiver un compte
Un compte peut être temporairement désactivé avec la règle `off` ou activé avec
`on`.

```bash
# Activation du compte
redis-cli acl setuser francois on
# La connexion est possible
redis-cli --user francois --pass 'nimportequoi' quit
# Désactivation
redis-cli acl setuser francois off
# Plus de connexion
redis-cli --user francois --pass 'nimportequoi' quit
# Réactivation pour la suite
redis-cli acl setuser francois on
```

## Plusieurs mots de passe par compte
Les ACL peuvent affecter un ou plusieurs mots de passe pour authentifier un
compte, avec le signe `>` pour un mot de passe en clair ou le signe `#` pour un
mot de passe chiffré. Elles peuvent aussi invalider un des mots de passe
respectivement avec les signes `<` et `!`. Tous les mots de passe sont invalidés
par la règle `nopass`.

```bash
# Ajout d'un mot de passe à un compte
redis-cli acl setuser francois '>mypassword'
# Plus de connexion possible sans mot de passe
redis-cli --user francois --pass 'nimportequoi' quit
redis-cli --user francois --pass mypassword quit
# Ajout d'un second mot de passe
redis-cli acl setuser francois '>mysecondpassword'
# Le premier fonctionne toujours
redis-cli --user francois --pass mypassword quit
# Le second fonctionne aussi
redis-cli --user francois --pass mysecondpassword quit
# Invalidation du premier
redis-cli acl setuser francois '<mypassword'
# Il ne fonctionne plus
redis-cli --user francois --pass mypassword quit
# Le second fonctionne toujours
redis-cli --user francois --pass mysecondpassword quit
```

## Catégories de commandes
Les règles peuvent accorder ou révoquer des privilèges sur des catégories de
commandes, respectivement avec les signes `+` et `-` suivis de `@` et du nom de
la catégorie.

`nocommands` et `allcommands` sont des synonymes de `-@all` et `+@all`

![Capture d’écran_2022-05-11_16-59-41.png](../{{ "/assets/posts/en/Howtomanagesecuritydataaccessandpermi/d41f9e12a4cb44c6b6bed51956714bcf.png" | relative_url }})

```bash
# Réinitialiser le compte avec accès aux données
redis-cli acl setuser francois reset on '>mypassword' ~*
# La manipulation des strings est désactivée
redis-cli --user francois --pass mypassword set strkey value1
# Accorde le droit de manipuler les strings
redis-cli acl setuser francois reset on '>mypassword' +@string ~*
# Commandes de lecture et écriture sur les strings sont autorisées
redis-cli --user francois --pass mypassword set strkey value1
redis-cli --user francois --pass mypassword get strkey
# Mais pas les autres
redis-cli --user francois --pass mypassword sadd setkey value
# Ni les commandes générales
redis-cli --user francois --pass mypassword info
# Interdiction des commandes d'écriture
redis-cli acl setuser francois reset on '>mypassword' +@string -@write ~*
# Le compte ne peut plus exécuter de commandes d'écriture
redis-cli --user francois --pass mypassword set strkey value1
# Mais peut toujours lire les strings
redis-cli --user francois --pass mypassword get strkey
```

## Restrictions d'accès aux données
Les règles peuvent limiter les données accessibles par des masques, préfixés par
le signe `~`.

```bash
# Accorder un accès global
redis-cli acl setuser francois reset on '>mypassword' +@all ~*
redis-cli --user francois --pass mypassword set mykey value1
redis-cli --user francois --pass mypassword set yourkey valuer2
redis-cli --user francois --pass mypassword set hiskey valuer3
# Limiter l'accès à mes clés et à tes clés
redis-cli acl setuser francois reset on '>mypassword' +@all ~my* ~your*
redis-cli --user francois --pass mypassword set mykey value1
redis-cli --user francois --pass mypassword set yourkey valuer2
redis-cli --user francois --pass mypassword set hiskey valuer3
```

## Restrictions sur les commandes
Une règle peut aussi accorder ou retirer des droits sur des commandes
spécifiques avec les signes `+` et `-` suivis du nom de la commande.

```bash
# Accorde un droit de lecture seule sur les strings et les TTL
redis-cli acl setuser francois reset on '>mypassword' -@all +get -set +ttl -expire -del +exists ~*
# Le compte ne peut pas écrire
redis-cli --user francois --pass mypassword set strkey value1
# Ni changer les TTL
redis-cli --user francois --pass mypassword expire strkey 60
# Mais il peut consulter les valeurs
redis-cli --user francois --pass mypassword get strkey
# Et les TTL
redis-cli --user francois --pass mypassword ttl strkey
```

## Importance de l'ordre des règles
L'ordre des règles est important. Elles sont évaluées de gauche à droite. Par
exemple, une liste peut accorder les droits pour toutes les commandes sur les
hash puis retirer celles qui modifient les données.

```bash
# Accès total sur les hash, en retirant les écritures
redis-cli acl setuser francois reset on '>mypassword' -@all +@hash -@write ~*
# Une écriture échoue
redis-cli --user francois --pass mypassword hset hashkey field1 value1 field2 value2
# Interdictions des écriture, puis ajout d'un accès total sur les hash
redis-cli acl setuser francois reset on '>mypassword' -@all -@write +@hash ~*
# La révocation est inutile
redis-cli --user francois --pass mypassword hset hashkey field1 value1 field2 value2
```

# Revenons à notre exemple

## Création des comptes
Nous avons besoin de six comptes protégés par mot de passe avec différentes permissions.

- orders-update : droit complet de manipuler les hash et list, limité aux clés
  commençant par *order*
- orders-invoice : accès identique, mais en lecture seule
- david : comme pour le microservice orders-invoice
- denis : comme pour david
- paul : identique au microservice *orders-update* pour pouvoir corriger les
  données
- angelina : accès aux commandes d'administration, mais pas de manipulation des
  donées, ni aux clés

Notre base "orders" peut révoquer les permissions sur toutes les commandes, puis
accorder les permissions sur les commandes manipulant les hash et les lists,
exclure les commandes dangereuses à un utilisateur "order-update" identifié par
un mot de passe. Et ce, sur toutes les clés commençant par "order:". Ce
microservice pourra se connecter avec son propre identifiant et sera limité aux
commandes et clé dont il a besoin.

```bash
redis-cli acl setuser order-update reset on '>order-update' -@all +@hash +@list -@dangerous ~order:*
```

Le microservice "order-invoice" a besoin des mêmes permissions, auxquelles on
retire l'accès aux commandes d'écriture.

```bash
redis-cli acl setuser order-invoice reset on '>order-invoice' -@all +@hash +@list -@dangerous -@write ~order:*
```

David et Denis ont besoin des mêmes permissions en lecture seule.

```bash
redis-cli acl setuser david reset on '>david' -@all +@hash +@list -@dangerous -@write ~order:*
redis-cli acl setuser denis reset on '>denis' -@all +@hash +@list -@dangerous -@write ~order:*
```

Paul, comme chef de projet, doit pouvoir modifier les valeurs.

```bash
redis-cli acl setuser paul reset on '>paul' -@all +@hash +@list -@dangerous ~order:*
```

Enfin, Angélina a besoin d'accéder aux commandes d'administration uniquement
pour éventuellement vider la base.

```bash
redis-cli acl setuser angelina reset on '>angelina' +@admin +@dangerous
```

![Capture d’écran_2022-05-11_17-08-37.png](../{{ "/assets/posts/en/Howtomanagesecuritydataaccessandpermi/911065dd753643a6816304bf4faffe0c.png" | relative_url }})

## Désactivation du compte anonyme par défaut
Ce compte est un compte de repli pour attribuer des permissions par défaut
lorsqu'aucune authentification ne s'est produite ou a réussi. Ce compte doit
être limité. La seconde exécution devrait échouer.

```bash
redis-cli acl setuser default reset +info
redis-cli acl setuser default reset +info
```

Il peut aussi être désactivé. Il pourra uniquement exécuter la commande `AUTH`
pour s'authentifier. La seconde exécution devrait échouer.

```bash
redis-cli acl setuser default off
redis-cli acl setuser default off
```

À partir de maintenant, le seul administrateur disponible pour changer les
permissions est... *Angélina*.


## Tests des privilèges
Le moyen le plus simple pour tester est d'exécuter le jeu de commandes suivant
avec chacun des comptes. Nous testons d'abord que l' compte peut lire et écrire
des clé de type string, de type hash et de type list. Enfin, nous testons la
disponibilité de la commande INFO pour connaître le nombre de clés dans la base
et la commande FLUSHALL pour vider la base.

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
### Compte anonyme
Ce compte ne devrait pouvoir exécuter aucune de ces commandes, sauf
éventuellement la commande INFO si vous avez décidé de la lui laisser.

### Microservice order-update
Ce compte ne devrait pas pouvoir accéder aux clés de type STRING, can les
commandes ne lui sont pas accordées et car le nom de la clé ne correspond pas à
ceux autorisés. Il devrait pouvoir lire et écrire les HASH et les LIST, car il a
accès à ces commandes et à ces clés. En revanche, il ne doit pas pouvoir vider
la base.

### Microservice order-invoice
Ce compte dispose exactement des mêmes permissions, sauf en ce qui concerne les
commandes d'écriture qui doivent donc échouer. On note que la commande LPOP est
une commande combinant à la fois une lecture et une écriture, pour retirer
l'élément lu, et qu'elle échoue.

### Développeur David
David et Denis ont les mêmes permissions que `order-invoice`.

### Chef de projet Paul
Paul dispose des mêmes permissions que `order-update`.

### Administrateur Angelina
Angélina n'a aucun droit d'exécution sur les commandes de manipulation des clés,
SET, GET, HSET, HGET, LPUSH, LPOP, qui échoueront. Mais elle peut consulter le
nombre d'enregistrements de la base et vider la base.


## Gestion de la sécurité à l'échelle
Les applications, développeurs, chefs de projets et admins sont identifiés par
leurs propre identifiants et disposent de permissions spécifiques sur les
commandes et les données. Mais que se passe-t-il lorsque des microservices sont
ajoutés, avec leurs bases de données, lorsque des développeurs changent de
projet, lorsque les équipes recrutent, que des employés s'en vont, qu'une base
Redis est ajoutée pour servir de bus de message PubSub entre tous les
microservices.... Un cauchemard à maintenir, mais Redis peut aussi gérer ce type
de situation avec une gestion par role (RBAC) décrite dans le prochain épisode.

![25.png](../{{ "/assets/posts/en/Howtomanagesecuritydataaccessandpermi/1b7c88cad8e84c62957c4d4573fe66df.png" | relative_url }})

# Supports et liens

| Lien | Description |
|---|---|
| [Video] | Enregistrement vidéo de la démonstration |

[Video]: https://youtu.be/dyskQGkgdEY"Enregistrement vidéo de la démonstration"
