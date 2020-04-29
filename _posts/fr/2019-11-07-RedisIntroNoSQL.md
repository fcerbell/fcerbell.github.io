---
uid: RedisNoSQLIntro
title: Redis 05 - Origines, buts et défis du NoSQL
author: fcerbell
layout: post
lang: fr
#description:
category: RedisIn5min
tags: [Redis,  Redislabs, index, indices, nosql, scalabilité, haute, disponibilité, haute-disponibilité, cohérence, performances, sql, relationel, normalisation, normaliser, dédupliquer]
#date: 9999-01-01
published: true
---

Cette partie décrit quelques concepts généraux et défis du NoSQL : scalabilité,
haute-disponibilité, cohérence et performances. Elle est nécessaire pour rendre
les prochaines parties plus compréhensibles.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

* TOC
{:toc}

# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/-Nn-G48YdBk" frameborder="0" allowfullscreen></iframe></center>

# Origines du NoSQL

Les bases de données relationnelles ont été conçues dans les années 70, lorsque
les ressources étaient chères. Elles devaient dédupliquer les données en les
normalisant pour économiser les ressources. Le réseau était lent, les clusters
n'apparaissaient même pas dans le film « 2001 l'odyssée de l'espace » de Stanley
Kubrick. Elles ont été conçues pour être génériques et répondre à tous les cas
d'usage, au prix de la normalisation. Les cycles de développement étaient longs,
le schéma n'évoluait pas beaucoup et il était forcé dans la base, par la base.


![aa][relational.png]

Le SQL a été créé pour requêter ce stockage avec une grande flexibilité. Mais
les jointures sont coûteuses et nécessitent des indexs pour améliorer les
performances. Elles ne sont pas vraiment scalable horizontalement par
conception, rendant les évolutions des bases relationnelles particulièrement
pénibles, ce n'était pas les préoccupations de l'époque.

Ces limites ne posaient pas de problème insurmontable tant que des entreprises
comme Google, Facebook ou LinkedIn s'y heurtent avec la taille de leur données
et leurs besoins spécifiques. Heureusement, elles avaient également des moyens
pour implémenter un stockage et un langage spécifique adapté à leurs besoins.

Prenons par exemple les bases orientées colonne pour y enregistrer des clients.
Si le besoin est transactionnel, tel que dans un ERP, la plus petite information
nécessaire est un enregistrement de client complet. Stocker cet enregistrement
en tant que tel dans une base relationnelle est acceptable. 

![aa][table.png]

Par contre, si le besoin est analytique, comme « Combien d'enfants ont mes
clients Français ? »,
nous n'avons besoin d'accéder qu'à 2 champs de chaque client : « NbChildren » et
« Country ». Un stockage orienté enregistrement n'est pas efficace car il faut
commencer par récupérer un enregistrement complet pour ne conserver que deux
champs, et répéter le processus. D'un autre côté, un stockage orienté colonne
est meilleur car sa granularité est le champ, il suffit de parcourir les deux
colonnes. 

![aa][column.png]

En fait, à la place de récupérer beaucoup d'informations depuis le
stockage et de les filtrer ensuite, on peut filtrer d'abord et ne récupérer que
les informations nécessaires. Évidemment, ce ne serait pas efficace si le but
était de reconstruire des enregistrements clients, ce n'est pas un stockage avec
une approche générique, mais un stockage spécifique optimisé pour un besoin
spécifique.

Vous n'avez peut-être pas le même volume de données, mais vous pouvez avoir le
même cas d'usage et bénéficier de ces bases NoSQL.

# Buts et défis du NoSQL

Les bases NoSQL ont été conçues dès le départ pour être redimensionnables
horizontalement sur du matériel classique. Mais, plus on utilise de matériel,
plus les probabilités de défaillance augmentent, ce qui apporte des défis de
disponibilité.

![aa][nodes.png]

La haute-disponibilité doit être inclue dans la conception pour minimiser les
risques de défaillance sur des systèmes mondialisés où la notion de nuit pendant
le week-end n'existe pas. La haute-disponibilité signifie qu'il faut dupliquer
les données, ce qui amène un autre défi : la cohérence entre les copies.

L'information répliquée doit être cohérente avec l'information de référence
lorsqu'une défaillance se produit ou lorsque les opérations de lecture sont
effectuées sur les réplicas. La réplication doit être synchrone lorsqu'une
véritable cohérence forte est nécessaire, mais elle impacte les performances.

![aa][replication.png]


Les opérations de lecture peuvent être extrèmement rapides, si la réplication
des opérations d'écriture était synchrone et lente. Elle peuvent être plus
lentes si la réplication des opérations d'écriture était asynchrone car la
cohérence est vérifiée à la lecture.

# Conclusion

Bien, nous venons de voir pourquoi les bases NoSQL sont apparues et quels sont
leurs principaux défis. Dans la partie suivante, nous plongerons dans le défi de
la scalabilité, comment est-il habituellement géré, particulièrement dans Redis
et Redis Entreprise.

# Supports et liens

| Lien | Description |
|---|---|
| [Video] | Enregistrement vidéo de la démonstration |

# Notes de bas de page

[Video]: https://youtu.be/-Nn-G48YdBk "Enregistrement vidéo de la démonstration"
[relational.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/relational.png "i"
[table.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/table.png "i"
[column.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/column.png "i"
[nodes.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/nodes.png "i"
[replication.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/replication.png "i"
