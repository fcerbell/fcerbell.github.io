---
uid: RedisKeyValue
title: Redis, un entrepôt clé-structure
author: fcerbell
layout: post
lang: fr
#description:
category: Redis
tags: [ redis, introduction, key-value, data-structures ]
#date: 9999-01-01
#published: false
---

J'essaye de présenter un aperçu de Redis, son histoire, ce qu'il peut faire,
comment il travaille, au cours d'une introduction rapide. J'en présente
brièvement les performances, optimisations et les avantages.

Vous pouvez retrouver le lien de l'enregistrement vidéo et des autres supports à la
 <a href="#materials-and-links">fin de cet article</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/5STePF4dc2U" frameborder="0" allowfullscreen></iframe></center>

# Entrepôt clé-valeur

Redis a été conçu dès le début comme une base NoSQL dans la famille clé-valeur. Cela signifie que vous pouvez enregistrer n'importe quelle valeur derrière un identifiant unique et que vous pouvez récupérer la valeur à partir de l'identifiant.

# Expiration automatique des clés

Redis peut attacher un minuteur, connu sous le nom de time-to-live ou TTL, à chaque clé et va le mettre à jour. Ce compte à rebours va être décrémenté jusqu'à 0 puis il fera automatiquement expirer la clé et sa valeur. Cela peut être utile pour des valeurs temporaires ou pour ue mémoire tampon.

# Jeu de données d'exemple

Prenons un cas d'usage simple avec une liste de clients, une liste de produits et une liste de commandes. Pour garder les choses simples,  une commande ne fait référence qu'à un seul article. Il pourrait s'agir d'un modèle de données pour un besoin d'analyse afin d'avoir des statistiques de ventes ou pour le marketing.

![Schéma relationel][RelationalSchema.png]

# Modèle d'accès aux données

Dans un entrepôt clé-valeur, même s'il existe des possibilités techniques pour parcourir et requêter le dictionnaire des clés, cela est contraire à son but. Si vous enregistrez des clients, commandes et produits, cela signifierait effectuer un parcours complet des trois tables,juste pour retenir quelques identifiants. Ainsi, soit l'application connait l'identifiant dont elle veut la valeur, soit elle ne peut pas récupérer la valeur. Soit l'idenntifiant et connu, un valeur constante par exemple, soit il peut être calculé/deviné à partir d'informations déjà connues, soit il peut être retrouvé à partir de la valeur d'une autre clé connue,tel que les identifiants clients à partir de la liste des identifiants stockée dans une clé.

Par exemple, si l'application enregistre des clients en utilisant un identifiant client comme clé, elle peut créer un enregistrement par client et une clé spéciale "clients" contenant la liste des identifiants. Ainsi, soit l'application connait l'identifiant du client souhaité pour en obtenir les informations, soit elle peut lire la liste de tous les identifiants clients depuis la clé "clients" et parcourir les enregistrement clients, uniquement ceux-là, en ignorant les autres. Cela correspond à l'implémentation d'un index primaire.

![Schéma clé-valeur][KeyvalueSchema.png]

Cette approche peut sembler plus complexe car l'application doit exécuter deux requêtes. Lorsque cette application exécute une seule requête dans une base de données indexée, le moteur de cette base exécute ces deux requêtes pour vous également. Il a ce comportement car il implémente une logique génériquee qui n'est pas optimisée pour votre besoin spécifique. Avec Redis, vous pouvez implémenter le niveau exact d'optimisation souhaité.

Si ce sujet vous intéresse, vous pouvez souscriree car j'ai prévu de détailler la conception de modèle de données clé-valeur dans une autre vidéo.

# Stockage de données structurées

Dans notre exemple, nous utilisons des enregistrements clients avec un prénom, une civilité, ... des fiches produits avec une description, un prix, ... et des commandes avec une date. Nous avons également enregistré la liste des iddentifiants clients, la liste des commandes et la liste des produits dans trois clés. Plus simplement, nous avons besoin de stocker des enregistrements et des listes d'identifiants uniques.

Il serait possible de stocker toutes ces informations dans un bloc sérialisé. Mais certaines requêtes ne seraient pas très efficaces. Si l'application souhaite savoir "la référence XXX existe-t-elle dans le catalogue ?", elle aurait à télécharger l'intégralité du catalogue, la liste des identifiants produits, la désérialiser et la parcourir. Cela peut être très consommateur en bande passante réseau, charge CPU et mémoire.

C'est pourqoi Redis comprend les structures de données telles que les listes de valeurs uniques, les stocke en tant que telles et peut les manipuler. L'application peut directement demander à Redis "Est-ce que la référence XXX appartient à la clé 'produits' ?"

![Schéma clé-structure][KeystructureSchema.png]

Ainsi, les applications n'ont pas besoin de télécharger un enregistrement potentiellement volumineux à travers le réseau, de le désérialiser et de le parcourir. En plus, elles n'ont pas à se soucier de gérer une protection contre les accès concurrents, comme des verrous, lors des modifications.

Redis a les avantages d'un entrepôt clé-valeur, la simplicité et l'efficacité, sans en avoir les inconvénients.

Vous avez compris le principe.

Je parlerai plus en détail des structures de données disponibles dans la prochaine vidéo et à de la conception de modèles de données dans une autre.





# Supports et liens

| Liens | Description |
|---|---|
| [Video] | Présentation vidéoo |

# Notes de bas de page

[Video]: https://youtu.be/5STePF4dc2U "Related youtube video"

[RelationalSchema.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/RelationalSchema.png "Exemple de schéma relationel"
[KeyvalueSchema.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/KeyvalueSchema.png "Exemple de schéma clé-valeur"
[KeystructureSchema.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/KeystructureSchema.png "Exemple de schéma clé-structure"
