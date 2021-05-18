---
uid: RedisNativeStructures2
title: Redis 03b - Structures de données natives (2nde partie)
description:
category: Redis en 5 minutes
tags: [ Redis, RedisLabs, Structures de données, Donnée, Structures, Clé-valeur, strings, limits, sets, sorted, list, hash, TTL, time-to-live, expiration, Recherche, full text, Moteur de recherche, Base graphe, Graphe, Cypher, OpenCypher, Concurrence, Compteur atomiquer, Atomic, Compteur, Verrou, Index, Pile, File, Queue, Traitements, Tâches ]
---

Bienvenue dans cette série « 5 minutes pour apprendre Redis » Je vais faire un
survol des structures de données natives de Redis, ce à quoi elles peuvent
servir, ce que l'on peut y stocker, comment les utiliser. Dans la précédente
partie, je décrivais les structures basiques.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

* TOC
{:toc}

# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/Ikz8eXF1XVc" frameborder="0" allowfullscreen></iframe></center>

# Index geo-spatiaux : Geo-index

En interne, cette structure utilise un ensemble trié, un sorted set, pour
enregistrer les éléments et utilise un geo-hash calculé à partir des coordonnées
comme score. La différence entre deux geo-hash est proporionelle à la distance
physique entre les coordonnées utilisées pour les calculer. Ce n'est donc pas
une nouvelle structure native à proprement parler, mais une structure dérivée.
Elle dispose des mêmes caractéristiques que les ensembles triés avec des
commandes supplémentaires pour calculer des distances entre les points ou pour
retrouver les éléments par éloignement. Redis comprend le système métric
international ainsi que le système bizarre impérial.

Les geo-index peuvent être utilisés pour des recherches de proximité, pour
calculer des distances ou des itinéraires.

# Bitmaps

Cette structure est dérivée des chaînes (strings). Ce n'est pas réellement une
structure de données mais un jeu de commandes pour manipuler une chaîne à la
granularité du bit. Elle peut adresser chaque bit individuellement dans une
chaîne de 512 Mo, pour le consulter, l'initialiser ou le supprimer. Elle peut
compter le nombre de bits initialisés et dispose aussi de commandes pour
effectuer des opérations bit à bit, comme AND, OR, XOR, entre plusieurs bitmaps.

Cette structure est pratique pour implémenter des filtres rapides, des compteurs
par catégorie ou des analyses. Elle peut facilement retrouver ls liste des
clients hommes, mariés, sans enfants, acceptant les courriels qui se sont
intéressés à un produit particulier, par exemple.

# Bitfields

Celle-ci est aussi constituée d'un jeu de commandes pour manipuler des champs
numériques, de longueur arbitraire, concaténés à des positions fixes dans une
structure string. Si on doit mémoriser des valeurs entre 0 et 8, Redis n'aura
besoin que de 3 bits par valeur.

Elle peut servir à enregistrer des séries temporelles, des choses séquentielles,
des configurations et des réglages, par exemple.

# Hyperloglogs

Cette structure est un compteur de valeurs uniques. Lorsque l'on souhaite
compter des milliers de valeurs distinctes, on a généralement besoin de retenir
ces valeurs pour ne les compter qu'une seule fois. Un hyperloglog n'enregistre
que le compteur dans un bloc de 12 Ko maximum. En contrepartie, il renvoie une
valeur avec une précision de l'ordre de 1%.

Imaginons que l'on souhaite compter le nombre de visiteurs uniques sur un site
web, en utilisant les adresses IP sources. L'hyperloglog sera capable de dire
qu'il a vu passer 1 million d'adresses IP uniques, plus ou moins 1%, mais il
n'aura utilisé que 12 Ko de RAM au lieu de 4 Mo pour stocker & million d'adresse
IP.

# Streams

Cette structure peut être connsidérée comme un journal. Il est possible d'y
ajouter des entrées, elles seront horodatées et enregistrées mais on ne peut pas
les supprimer ou les modifier. Par contre, on peut limiter la taille de la
stream. Une entrée comporte des champs avec un nom et une valeur chacun. Ok,
donc, on a un journal.

Ensuite, on peut exécuter des requêtes sur des plages temporelles telles que «
je veux tous les enregistrements entre hier et aujourd'hui ». On peut aussi
souscrire à une stream pour recevoir les nouvelles entrées en temps réel. Il est
possible de reprendre une souscription dans le passé pour recevoir les entrées
manquées, un stream peut aussi distribuer les enregistrements aux consommateurs
d'un groupe de consommateurs, avec un accusé de réception. Chaque entrée n'a pas
besoin de stocker les noms des champs lorsqu'ils sont identiques à
l'enregistrement précédent.

Cette structure est particulièrement utile pour implémenter une synchronisation
à travers un lien non-fiable, de l'ingestion de données à partir de
périphériques IoT, de l'historisation d'événements ou une salle de discussion
multi-utilisateurs.

# Infinité d'autres : Modules

Ensuite, on peut étendre Redis et y ajouter n'importe quelle structure de
données ou fonctionnalité, en utilisant les modules, mais je présenterai les
modules dans un autre épisode.

# Supports et liens

| Lien | Description |
|---|---|
| [Video] | Vidéo de présentation avec dessins |

# Notes de bas de page

[Video]: https://youtu.be/Ikz8eXF1XVc "Vidéo de présentation avec dessins"
