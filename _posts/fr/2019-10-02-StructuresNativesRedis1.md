---
uid: RedisNativeStructures1
title: Redis 03a - Structures de données natives (1ère partie)
author: fcerbell
layout: post
lang: fr
#description:
category: RedisIn5min
tags: [ Redis, RedisLabs, Data-structures, Data, Structures, key-value, key, value, strings, limits, sets, sorted, list, hash, ttl, time-to-live, expiration, full text search, full text, search engine, graph database, graph, cypher, opencypher, concurrency, atomic counter, atomic, counter, lock, index, indices, stack, queue, joe queue, task queue, task ]
#date: 9999-01-01
published: true
---

Dans cette première partie, je vais faire un court survol des structures de
données natives dans Redis les plus communément utilisées, à quoi elle peuvent
servir, ce qui peut y être enregistré, comment les utiliser. Je décrirai les
autres structures dans les prochaines parties.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

* TOC
{:toc}

# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/ulOnuE8di30" frameborder="0" allowfullscreen></iframe></center>

 
# Petit rappel concernant Redis

Redis est une base de données clé-structure en mémoire. Il peut enregistrer
2^32 clés, dont le nom peut faire jusqu'à 512Mo, avec une valeur associée. La
valeur est une structure de données, Redis dispose de 10 structures natives et
peut être étendu pour supporter n'importe quel type de structure, d'un simple
objet JSON à un moteur complet de base graphe ou de recherche plain-texte.
Chaque clé peut aussi être dotée d'un TTL, durée de vie ou délai d'expiration,
pour la supprimer automatiquement.

Pour chacune des structures supportées, Redis permet de la manipuler
directement en mémoire à l'aide de commandes atomiques, sans avoir à se soucier
de concurrence ou de bande passante et de traffic réseau.

# Les chaînes : Strings

Une chaîne peut enregistrer une suite d'octets, jusqu'à 512Mo, éventuellement
non imprimables, elle est "binary-safe". Vous pouvez stocker des morceaux de
HTML généré, des objets JSON, des fichiers image ou PDF, etc. Redis a une
compréhension basique d'une chaîne et offre des commandes de manipulation. Une
chaîne peut stocker des octets arbitraires ou des valeurs numériques. Redis
peut incrémenter ou décrémenter les valeurs numériques atomiquement, en
mémoire. En ce qui concerne les suites d'octets, Redis peut y concaténer
d'autres octets à la fin ou renvoyer un nombre d'octets arbitraire à partir
d'une position donnée.  

![Strings: contenu][Strings1.png]

Les chaînes peuvent être utilisée pour distribuer du
contenu, pour implémenter des compteurs ou des verrous atomiques, pour stocker
des enregistrements positionnels.  Les chaînes, lorsqu'elles sont combinées à
un TTL et à une politique d'éviction, sont une structure de choix pour
implémenter un tampon ou cache.

![Strings: usage][Strings2.png]

# Les ensembles : Sets

Un set stocke un ensemble d'éléments uniques non ordonnés. Il ppeut contenir
jusqu'à 2^32 différents éléments, chacun étant une chaîne Redis pouvant
atteindre 512Mo, éventuellement binaire. Je n'ai jamais vérifié ces valeurs
maximales, si vous me donnez la machine, je suis prêt à essayer ! ;)

![Sets: contenu][Sets1.png]

Redis peut manipuler un set en mémoire pour vérifier la présence d'un élément
dans l'ensemble, pour y ajouter un élément ou pour en retirer un. De plus,
Redis peut exécuter des commandes inter-ensembles telles que des unions ou des
intersections.

Les ensembles peuvent être utilisés pour implémenter des index. Un ensemble
peut contenir la liste des identifiants des clients, c'est un index primaire.
Il peut y avoir un ensemble par prénom possible contenant la liste des clients
ayant ce prénom, c'est un index secondaire. Redis peut facilement et rapidement
retrouver les identifiants des clients en calculant l'intersection entre ces
ensembles.

![Sets: usage][Sets2.png]

# Les ensembles triés : Sorted sets

Cette structure est un ensemble d'éléments uniques avec un score numérique
attaché à chaque élément. Cet ensemble est trié par score et dispose de
commandes supplémentaires pour retrouver les dix premiers, les dix derniers, ou
tous les éléments dont le score est compris dans une plage de valeurs. Elle
peut être utilisée pour enregistrer des séries temporelles en utilisant un
horodatage comme score. 

![ZSets: contenu][ZSets1.png]

Elle peut être utilisée également pour un tableau de
performances pour afficher les articles de blog les plus populaires. Enfin,
elle est souvent utilisée comme index secondaire pour les requêtes sur des
plages de valeurs, afin de retrouver les clients en croisant l'index de prénom
"François", celui de nom "Cerbelle" et l'index d'age sur une plage de 30 à 50
ans.

![ZSets: usage][ZSets2.png]

# Les listes : Lists

Une liste peut enregistrer jusqu'à 2^32 éléments et en conserve l'ordre. Redis
peut ajouter ou retirer un élément à la fin ou au début de la liste. Les listes
peuvent donc être utilisées comme des listes, des files ou des piles. Elles
supportent aussi quelques commandes bloquantes telles que "récupère le premier
élément s'il existe, sinon attend qu'il y en ait un". Redis peut également
exécuter des commandes inter-liste pour lire et retirer un élément d'une liste
en l'ajoutant dans une autre liste de manière atomique. 

![Listes: contenu][Lists1.png]

Elles peuvent être utilisées pour implémenter des processus de cheminement ou
des listes de tâches à effectuer.

![Listes: usage][Lists2.png]

# Enregistrements : Hashes

Un hash est un enregistrement. Il peut stocker jusqu'à 2^32 champs, chacun avec
un nom et une valeur. Ces derniers ont les caractéristiques des strings. Redis
peut lire ou écrire des champs spécifiques dans un hash, en mémoire. Ça peut
être utile pour incrémenter le champ "âge" du client "XYZ" ou pour mettre
n'importe quel champ texte à jour.

![Hash: contenu][Hashes1.png]

Les hash sont utilisés pour stocker n'importe quel type d'enregistrement, de
client, de produit, de matériel, d'événement, d'opération, de session
utilisateur...

![Hash: usage][Hashes2.png]

# Supports et liens

| Lien | Description |
|---|---|
| [Video] | Vidéo de présentation avec dessins |

# Notes de bas de page

[Video]: https://youtu.be/ulOnuE8di30 "Vidéo de présentation avec dessins"
[Strings1.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/Strings1.png "String contents"
[Strings2.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/Strings2.png "String usecases"
[Sets1.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/Sets1.png "Set contents"
[Sets2.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/Sets2.png "Set usecase"
[ZSets1.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/ZSets1.png "ZSet content"
[ZSets2.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/ZSets2.png "ZSet usecase"
[Lists1.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/Lists1.png "List contents"
[Lists2.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/Lists2.png "List usecase"
[Hashes1.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/Hashes1.png "Hash contents"
[Hashes2.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/Hashes2.png "Hash usecase"
