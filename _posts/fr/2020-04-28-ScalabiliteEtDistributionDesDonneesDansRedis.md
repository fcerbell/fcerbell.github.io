---
uid: redisdatascalabilityanddistribution
title: Redis 06 - Distribution et flexibilité du stockage des données
description:
category: RedisIn5min
tags: [ Redis,  Redislabs, scalabilité, données, cluster, distribution, sharding, resharding, shard, reshard, performances, linéaire, performances linéaires, prédictible, performances prédictibles, requêtes, hash, hashslots, hashtags, hash-slot, hash-tags, entreprise, redis entreprise, communautaire, redis communautaire, redimmensionnement, redimensionner ]
---

Cette partie décrit comment distribuer les données pour obtenir un
redimensionnement horizontal avec des performances linéaires et comment ce
redimensionnement est implémenté dans Redis et Redis Entreprise. La distribution
des requêtes sera traitée dans la partie suivante.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

* TOC
{:toc}

# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/mIvcBKI9DmU" frameborder="0" allowfullscreen></iframe></center>

# Implémentation habituelle

Certains moteurs appellent cette distribution des partitions, d'autres parlent
de sharding.

Pour faire simple, l'idée sous-jacente est de définir des objets atomiques tels
que des enregistrements, des champs, ou n'importe quel autre concept en fonction
de la granularité souhaitée, puis de choisir une règle pour distribuer ces
objets équitablement dans des groupes, des buckets, des collections, des
partitions, des slots, ... peu importe comment on les appelle. Pour obtenir une
distribution homogène, le nombre de groupes doit être fixé. Il est plus facile
de redistribuer un nombre fini de groupes plutôt qu'un nombre arbitraire
d'enregistrements, dans le cas d'un redimensionnement.

Ces groupes d'objets doivent être physiquement enregistrés dans des unités de
stockage, il peut s'agir de disques, de fichiers ou de RAM... Chacun peut
disposer de son propre stockage ou ils peuvent être regroupés dans une unité de
stockage partagée. Plusieurs unités de stockage peuvent se trouver sur un même
ordinateur ou elles peuvent être distribuées sur plusieurs machines.

Finallement, il est facile et rapide de savoir où exécuter une commande sur une
donnée. Appliquer la règle sur la clé pour connaître le slot, trouver l'unité de
stockage et sa machine à partir du slot dans la table des slots, exécuter la
commande. 

# À la mode de Redis

## Distribution des clés

Une base Redis stocke des clés et des valeurs. Un hash est calculé à partir du
nom de la clé pour déterminer le « hashslot », le tiroir, où enregistrer la clé
et sa valeur. Il y a un nombre limité de hashslots : 16384. La fonction est très
simple : CRC12 modulo 16384. Le CRC12 donne une bonne entropie, distribuant les
clé de manière homogène et équilibrant les hashslots, et il a une complexité de
calcul inférieur à un CRC32, le rendant plus rapide en termes de cycles CPU.

Puis Redis va distribuer les hashslots équitablement entre les instances Redis.


## Redimensionnement transparent

Une unique instance Redis, un shard, est l'unité de stockage et comporte des
limites physiques. Il s'agit d'un processus stockant les structures de données
en RAM, avec uniquement un seul thread pour exécuter les commandes. Il est
sans-verrou et bien plus efficace, mais ne peut utiliser qu'un seul cœur maximum
pour exécuter les commandes. Un cœur peut habituellement gérer jusqu'à 25 Go de
données et 25 K opérations par seconde en conservant une latence inférieure à la
milliseconde. Tôt ou tard, vous voudrez redistribuer vos données et utiliser
plus d'un cœur, que ce soit pour exploiter tous les cœurs disponibles ou pour
accompagner votre croissance.

Avec un seul hashslot par shard, une base de données Redis pourrait
théoriquement utiliser jusqu'à 16384 cœurs et enregistrer jusqu'à 400 To ou
effectuer jusqu'à 400 millions d'opérations par secondes avec une latence
inférieure à la milliseconde. Donnez-moi les machines pour tester.

[Test à 200 millions d'opérations par seconde][200MBenchmark] [^1]

### Redis communautaire

Pour commencer, si votre base Redis n'est pas configurée en mode «
[redis-cluster][RedisClusterSpec] »[^2], il faut [changer la
configuration][RedisClusterTut] [^3] et redémarrer la base.

Il faut ensuite trouver des machines avec des ressources disponibles, déterminer
des ports réseau disponibles pour éviter les conflits, configurer et démarrer de
nouvelles instances Redis. Ensuite, il faut calculer le nombre de hashslots à
déplacer, depuis quelles instances, vers quelles instances et démarrer la
migration. Il est facile d'oublier une étape ou de se retrouver avec des
instances déséquilibrées.

Les bibliothèques clientes utilisées par les applications doivent être «
cluster-aware » pour pouvoir router les requêtes vers l'instance appropriée et
pour mettre à jour dynamiquement leur copie locale de la table des hashslots, la
cartographie. Toutes les bibliothèques clientes ne peuvent pas le faire.

### Redis entreprise

Le gestionnaire de cluster crée au moins une nouvelle instance Redis pour chaque
instance existante. Ensuite, il connecte au moins une des nouvelles instances à
chaque ancienne et démarre une synchronisation des hashslots. Puis, il divise le
nombre de hashslots des anciennes instances par le nombre de nouvelles instances
plus un. Toutes les requêtes qui ne concernent pas la première fraction des
hashslots ne sont plus routées vers l'instance d'origine mais vers une des
copies, la synchronisation est arrêtée, les hashslots inutiles sont supprimés de
tous les shards. Au final, chaque shard existant a été découpé en plusieurs
shards équilibrés. Redis entreprise automatise et industrialise le processus
complet, retirant les risques liés à une possible erreur. C'est le résultat
d'une expérience d'automatisation de 8 ans et de plusieurs années.homme de
développement.

Toute la logique cliente de gestion du cluster est gérée par les proxies,
n'importe quelle bibliothèque cliente peut être utilisée dans les applications.
Du point de vue des applications, il n'y a qu'une seule instance Redis
hébergeant la totalité du jeu de données. Plus d'exception à gérer du côté
applicatif par le développeur, ce qui signifie des développement plus rapides et
des applications plus fiables.

# Conclusion

Il est très intéressant de noter que le redimmensionnement implémenté dans Redis
bénéficie de performances linéaires. Les hautes-performances sont très
intéressantes, elles le sont encore plus lorsqu'elles sont prévisibles !

Maintenant, vous savez comment le dimensionnement dynamique est habituellement
traité et plus particulièrement dans Redis. La partie suivante expliquera
comment les requêtes sont également distribuées dans la version communautaire et
dans la version entreprise.

# Supports et liens

| Lien | Description |
|---|---|
| [Video] | Enregistrement vidéo de la démonstration |

# Notes de bas de page

[^1]: [https://redislabs.com/blog/redis-enterprise-extends-linear-scalability-200m-ops-sec/](https://redislabs.com/blog/redis-enterprise-extends-linear-scalability-200m-ops-sec/)

[^2]: [https://redis.io/topics/cluster-tutorial](https://redis.io/topics/cluster-tutorial)

[^3]: [https://redis.io/topics/cluster-spec](https://redis.io/topics/cluster-spec)

[200MBenchmark]: https://redislabs.com/blog/redis-enterprise-extends-linear-scalability-200m-ops-sec/

[RedisClusterTut]: https://redis.io/topics/cluster-tutorial

[RedisClusterSpec]: https://redis.io/topics/cluster-spec

[Video]: https://youtu.be/mIvcBKI9DmU "Enregistrement vidéo de la démonstration"
