---
uid: RedisIntro
title: Redis 01 - Introduction
description:
category: Redis en 5 minutes
tags: [ redis, introduction, key-value, data-structures ]
---

J'essaye de présenter un aperçu de Redis, son histoire, ce qu'il peut faire,
comment il travaille, au cours d'une introduction rapide. J'en présente
brièvement les performances, optimisations et les avantages.

Vous pouvez retrouver le lien de l'enregistrement vidéo et des autres supports à la
 <a href="#materials-and-links">fin de cet article</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/H6AV3OdFvHg" frameborder="0" allowfullscreen></iframe></center>


# Origines

[Redis][redisio] signifie Remote Dictionnary Server (Serveur de dictionaire
distant).

C'est un projet opensource démarré en 2009 par Salvatore Sanfilippo, aussi connu
sous le pseudonyme Antirez, en Sicile.

![Redis page][redisio_home.png]

Son but est de stocker les variables des applications à l'extérieur des
applications.

Ainsi, l'application peut être redémarrée et peut reprendre son activité à
partir de son dernier état connu ; plusieurs applications peuvent manipuler les
mêmes variables partagées.

Depuis le tout début, la lisibilité du code, la simplicité d'utilisation et la
qualité de la documentation étaient une priorité.

![Redis documentation][redisio_documentation.png]

# En mémoire et persistante

Pour atteindre un tel objectif, Redis a besoin d'être extrèmement performant.
C'est une base de données en mémoire, ce qui signifie qu'il stocke et sert les
données dans et depuis la mémoire. Il pourrait fonctionner sans disque attaché.
Un disque peut y être ajouté pour persister les données, à des fins de
durabilité, et ce disque n'a pas besoin d'être un disque rapide.

Redis est tellement rapide qu'il ne nécessite jamais d'avoir un cache. Il est
souvent utilisé et connu comme un cache pour les autres bases de données
relationnelles et NoSQL, pour les accélérer.

C'est très important, contrairement aux autres bases de données, Redis ne
stocke ni ne sert les données depuis le disque en utilisant la mémoire comme un
cache. Au lieu de cela, il stocke et sert les données depuis la mémoire et
utilise éventuellement un disque si la persistence est nécessaire.

# Hautement optimisé

La mémoire est chère et personne ne peut se permettre de la gâcher. Ainsi, les
données sont enregistrées dans Redis en utilisant des structures de données
internes performantes afin de minimiser la surcharge à l'échelle de l'octet,
voire même du bit.

La plupart des commandes ont une complexité O(1), ce qui signifie que le temps
d'exécution sera constant et prévisible, quelque soit la taille du jeu de
données actuel ou à venir.

![Redis complexity][redisio_complexity.png]

Chaque commande est implémentée pour minimiser le nombre de cycles CPU. Une
unique instance Redis peut habituellement exécuter 25 000 opérations par
secondes sur 25 Go de données, avec une latence inférieure à la milliseconde en
n'utilisant... Qu'un seul cœur.

# Stockage clé-structure et multi-model

Redis est une base clé-valeur. Une seule instance Redis peut stocker jusqu'à
2^31 clés. Les valeurs enregistrées dans les clés sont des structures de
données. Elles peuvent être aussi simples qu'une chaîne de caractères ou aussi
complexes qu'un objet JSON ou un modèle d'intelligence artificielle. Redis
supporte nativement 10 structures différentes et peut facilement être étendu
pour supporter n'importe quelle structure ou fonctionnalité par le chargement
d'un module.

![Redis structures][redisio_structures.png]

![Redis modules][redisio_modules.png]

Redis embarque également un système de communication simple et puissant pour
permettre le traitement de données en temps-réel et les communications
inter-processus.

![Redis pubsub][redisio_pubsub.png]

Lorsque le développeur manipule une liste dans son application, il n'a pas
besoin de la normaliser ou de la sérialiser avant de l'enregistrer. Cela rend le
code source plus simple et robuste, mais également plus rapide à éxécuter et
à écrire.

# Transactions et verrous

Redis supporte aussi les transactions et la cohérence, bien sûr.
Plus de 40 langages supportent Redis. Pas uniquement les langages des
développeurs tels que le C, C++, NodeJS ou JAVA, mais également les langages des
analystes comme R, Python ou Scala.

![Redis transactions][redisio_transactions.png]

# Une des plus importantes réelle communauté active

Redis est tellement populaire que sa communauté est riche de nombreux profils
utilisateurs. Il est facile de trouver la réponse à une question à propos de
Redis sur Internet ou de recruter des experts Redis. Redis a une des plus
grosses communautés à travers le monde, comportant de nombreux contributeurs.

![google_redis][google_redis.png]

![linkedin_redis][linkedin_redis.png]

Redis est dans les 100 projets les plus appréciés sur Github, dans les 10 bases
de données les plus populaires sur DB-engines.

![dbengines_ranking][dbengines_ranking.png]

Redis est un des containers Docker les plus lancés, et la base de données
préférés des membres de StackOverflow depuis 3 ans.

![stackoverflow_ranking][stackoverflow_ranking.png]

# Scalabilité linéraire et haute-disponibilité

Redis peut sécuriser l'accès aux données grâce à sa haute-disponibilité en
configurant des instances en tant que réplica d'autres instances.

Redis peut également être redimensionné linéairement sans interruption de
service en répartissant les données dans plusieurs instances sur plusieurs
serveurs.

Redis est utilisé partout, dans presque toutes les entreprises, des plus petites
aux plus grandes. Il est utilisé comme base de données primaire pour faire
fonctionner le cœur de métier, pour traiter les données critiques et pour
stocker des informations critiques.

# Conclusion : les avantages de Redis

Redis réduit habituellement les coûts de possession, à la fois sur
l'infrastructure matérielle, en en optimisant l'utilisation, et sur le temps
d'administration et de maintenance. Il améliore grandement les performances des
application, la cohérence et la sécurité des données.


# Supports et liens

| Liens | Description |
|---|---|
| [Video] | Présentation vidéoo |
| [google] | Recherche Redis dans Google |
| [linkedin] | Recherche de profils Redis dans LinkedIn[^1] |
| [github] | Classement des projets dans GitHub |
| [stackoverflow] | Sondage/étude des technologies préférées sur Stackoverflow |
| [dbengines] | Classement des bases de données sur DB-engines |
| [datastructures] | Liste des structures Redis |
| [pubsub] | Présentation de la transmission de messages dans Redis |
| [transactions] | Présentation des transactions dans Redis |
| [modules] | Présentation des modules Redis |
| [moduleshub] | Dépôt des modules Redis communautaires |
| [http://redis.io][redisio] | Page principale du projet |

# Notes de bas de page

[Video]: https://youtu.be/H6AV3OdFvHg "Related youtube video"
[redisio_home.png]: {{ "/assets/posts/" | append: page.uid | append:"/redisio_home.png" | relative_url }} "Redis home page"
[redisio]: http://redis.io "Redis project page"
[redisio_documentation.png]: {{ "/assets/posts/" | append: page.uid | append:"/redisio_documentation.png" | relative_url }} "Redis home page"
[redisio_complexity.png]: {{ "/assets/posts/" | append: page.uid | append:"/redisio_complexity.png" | relative_url }} "Redis home page"
[redisio_structures.png]: {{ "/assets/posts/" | append: page.uid | append:"/redisio_structures.png" | relative_url }} "Redis home page"
[redisio_modules.png]: {{ "/assets/posts/" | append: page.uid | append:"/redisio_modules.png" | relative_url }} "Redis home page"
[redisio_pubsub.png]: {{ "/assets/posts/" | append: page.uid | append:"/redisio_pubsub.png" | relative_url }} "Redis home page"
[redisio_transactions.png]: {{ "/assets/posts/" | append: page.uid | append:"/redisio_transactions.png" | relative_url }} "Redis home page"
[google_redis.png]: {{ "/assets/posts/" | append: page.uid | append:"/google_redis.png" | relative_url }} "Redis home page"
[linkedin_redis.png]: {{ "/assets/posts/" | append: page.uid | append:"/linkedin_redis.png" | relative_url }} "Redis home page"
[dbengines_ranking.png]: {{ "/assets/posts/" | append: page.uid | append:"/dbengines_ranking.png" | relative_url }} "Redis home page"
[stackoverflow_ranking.png]: {{ "/assets/posts/" | append: page.uid | append:"/stackoverflow_ranking.png" | relative_url }} "Redis home page"

[google]: http://google.com/search?q=redis "Google results for Redis"
[linkedin]: https://www.linkedin.com/search/results/people/?keywords=redis&origin=SWITCH_SEARCH_VERTICAL "Linkedin results for Redis skills"
[github]: https://github.com/search?q=stars%3A%3E38700 "Github redis project ranking"
[stackoverflow]: https://insights.stackoverflow.com/survey/2019#technology-most-loved-dreaded-and-wanted-loved4 "Stackoverflow survey"
[dbengines]: https://db-engines.com/en/ranking "DB-engines ranking"
[datastructures]: https://redis.io/topics/data-types "Redis datastructures list"
[pubsub]: https://redis.io/topics/pubsub "Redis messaging presentation"
[transactions]: https://redis.io/topics/transactions "Redis transactions presentation"
[modules]: https://redis.io/topics/modules-intro "Redis modules presentation"
[moduleshub]: https://redis.io/modules "Redis community modules list"

[^1]: You need to login on LinkedIn to see the page
