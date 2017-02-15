---
uid: ConfigureRoute53ForRLEC
title: Comment configurer le DNS Route53 d'Amazon pour RedisLabs Enterprise Cluster
author: fcerbell
layout: post
lang: fr
#description:
#category: Test
#categories
#tags
#date: 9999-01-01
published: true
---

RedisLabs Enterprise Cluster (RLEC[^1]) nécessite une configuration DNS particulière pour offrir la haute-disponibilité (HA). Cet article décrit comment configurer le DNS *Route53* d'*Amazon Web Services* (AWS) correctement.


Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

* TOC
{:toc}

# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/nmVD5uTjP2M" frameborder="0" allowfullscreen></iframe></center>

# Pré-requis

Vous devez disposer d'un nom de domaine enregistré. Ensuite, *Route53* doit être configuré pour être le DNS primaire/maître du domaine ou d'une zone de délégation sous ce domaine. Enfin, vous devez avoir configuré la zone (soit le domaine complet, soit une sous-zone) dans *Route53*.

# Comment RLEC gère-t-il la haute-disponibilité ?

Si vous disposez d'un cluster RLEC de trois nœuds, lorsque votre application veut se connecter à un cluster, elle se connecte à n'importe quel nœud de ce cluster en utilisant son nom pleinement qualifié (FQDN[^2]), par exemple : `noeud1.moncluster.francois.entreprise.fr`. Elle a besoin de connaître
l'adresse IP associée avec ce nom et demande aux serveurs de noms racine (TLD[^3]) gérant le domaine `.fr` la liste des serveurs de nom en charge de `entreprise.fr`. Ensuite, elle demande à ces serveurs (l'un après l'autre en cas de défaillance) les noms des serveurs en charge de
`moncluster.entreprise.fr`, et finallement elle demande à ces derniers (l'un après l'autre en cas de défaillance) l'adresse IP de `noeud1.moncluster.entreprise.fr`. Elle termine en se connectant à cette adresse. Tout ce traitement est transparent pour l'application, il est effectué par le résolveur,
une bibliothèque du système.

Vos serveurs de noms se chargent de `entreprise.fr`. Ainsi, ils peuvent donner la liste des serveurs de noms chargés du cluster. RLEC embarque un serveur de nom dans chaque nœud. Chacun est chargé de la résolution des noms dans la zone du cluster et est capable de donner l'adresse IP de chaque nœud du
cluster. Lorsque tout fonctionne, peu importe le serveur racine, il donne la liste des serveurs de noms de votre entreprise. Ensuite, peu importe celui qui est interrogé, il donne la liste des serveurs de noms du cluster (les nœuds). Enfin, peu importe celui qui est interrogé, il renvoie l'adresse IP
du nœud dont lenom a été donné.

Si le serveur de nom du cluster (nœud) interrogé est tombé, selon le processus de résolution, le résolveur passera au suivant dans la liste et obtiendra l'adresse IP demandée. Il s'agit du comportement par défaut de résolution DNS.

Maintenant, lorsqu'un des nœuds du cluster tombe. quelle qu'en soit la raison, les autres nœuds ne peuvent plus le joindre et vont remplacer l'adresse IP associée à son nom par l'adresse IP d'un autre nœud du cluster dans les serveurs de nom du cluster. Cela signifie que l'adresse IP inactivée ne sera
jamais plus renvoyée par les serveurs de nom pour résoudre n'importe quel nom de nœud. Par ailleurs, deux noms de nœuds partageront la même adresse IP. Autrement dit, cela signifie que, quelque soit le nom de nœud demandé par votre application, elle obtiendra toujours l'adresse IP d'un nœud du cluster
en état de lui répondre et la connexion réussira.

# Configuration

Après la théorie, on peut passer à la pratique pour réaliser cette configuration avec le DNS *Route53* d'Amazon comme serveur officiel de votre domaine ou sous-domaine.

## Connexion au DNS Route53 d'Amazon

La première étape consiste à connecter votre navigateur à *AWS*[^4] et à vous connecter à l'interface d'administration. Ansuite, vous devez aller dans le menu *Services* en
haut à gauche de la page et cliquer sur *Route53*:

![Route53 dans le menu Services][01-ServicesRoute53.png]

Ensuite, je suppose que vous avez déjà enregistré un domaine et que vous avez défini *Route53* comme serveur maître/primaire pour tout le domaine ou un de ses sous-domaine.
Vous devriez vons avoir au moins une zone dans *Route53*. Cliquez sur *Zones hébergées* pour ouvrir la liste:

![Zones hébergées dans Route53][02-Route53HostedZones.png]

*Route53* affiche désormais la liste des zones que vous avez définies. Vous devez cliquer sur la zone dans laquelle vous voulez définir votre cluster, *demo-rlec.redislabs.com*, dans mon cas:

![Sélection de la zone hébergée][03-HostedZoneSelection.png]

## Création des enregistrements des serveurs de nom

L'étape suivante consiste à créer les enregistrements qui renvoient l'adresse IP des serveurs de nom du cluster, les nœuds du cluster. Pour créer le premier enregistrement de
résolution des adresses IP des serveurs de nom du cluster, vous devez cliquer sur le bouton bleu *Créer un jeu d'enregistrements* en haut de la liste:

![Créer un jeu d'enregistrements][04-CreateRecordSet.png]

Cet enregistrement sera **seulement** utilisé pour résoudre l'adresse IP du serveur de nom à interroger. Il **ne servira pas** à l'application pour se connecter au cluster.
Cet enregistrement est de type *A* et associe une adresse IP à un nom. Pour éviter tout le processus de résolution à chaque fois qu'un nom en a besoin, les résultats sont
conservés en cache par les serveurs DNS intermédiaires (forwarding) et par la bibliothèque du résolveur. Étant donné que l'adresse IP associée à un nœud peut changer lorsque
cd nœud est indisponible, l'information doit se périmer rapidement, sinon le nœud tombe, les DNS du cluster le prennent en compte, mais ils ne reçoivent jamais les requêtes et
le résolveur local continue à renvoyer l'adresse IP périmée et invalide. Pour l'expiration, c'est le champs Time To Live (TTL) associé à l'enregistrement.

C'est pourquoi vous devez saisir le nom utilisé pour le serveur de nom du cluster, bien que l'on puisse saisir autrechose, je recommande de saisir le nom du nœud. Vous devez
saisir son adresse IP, configurer le TTL à une période courte. Je le règle à une minute. Cela correspond au délai maximum pendant lequel l'enregistrement sera conservé dans le
cache du résolveur et dans les DNS relais. Si le nœud tombe, le résolveur continuera à utiliser cette valeur jusqu'à son expiration mais, étant donné que le nœud ne répond
plus, le résolveur tentera d'utiliser le serveur suivant dans la liste (il dispose de l'enregistrement *A* car il a eu besoin de connaître l'adresse IP du premier serveur de
nom, et s'il a eu besoin de cette IP, c'est qu'il dispose déjà de la liste des serveurs de nom).

Finalement, soumettez l'enregistrement *A* du premier serveur de nom à *Route53* en utilisant le bouton *Créer* en bas du paneau latéral droit:

![Configuration du premier serveur de noms][05-NS1Configuration.png]

Vous voulez (et devez) avoir tous vos nœuds de cluster agissant comme serveurs de noms, vous devez donc répéter ces étapes pour tous vos nœuds et devez obtenir une liste
d'enregistrements *A* dans l'interface de *Route53* :

![Liste de serveurs de noms][06-NSList.png]

Maintenance, le résolveur du côté client et les DNS relais peuvent atteindre les serveurs de noms du cluster grâce à leur adresse IP s'ils en connaissent le nom. C'est donc le
but de la prochaine étape.

## Définition de la liste des serveurs de nom de la sous-zone

Ici, l'idée est de pouvoir fournir la liste des serveurs de nom du cluster au résolveur et aux DNS relais pour qu'ils soient capable de résoudre l'adresses IP de l'un
d'entre-eux et de l'interroger pour connaître l'adresse IP du nœud souhaité. Pour cela, nous devons définir un nouvel enregistrement dans *Route53*, un enregistrement *NS*
pour *Name Server* (serveur de nom). Une fois de plus, il faut cliquer sur le bouton *Créer un jeu d'enregistrements* et saisir les informations dans le panneau latéral droit:

Le nom est celui du cluster, si vos nœuds sont nommés `noeudX.moncluster.entreprise.fr` alors le nom du cluster est `moncluster.entreprise.fr`. Souvenez-vous, le résolveur va
commencer par demander «Qui est responsable de la zone <Cluster> ?». Le nom est la clé de recherche, le type d'enregistrement est un champ. Dans notre cas, le résolveur va
demander l'enregistrement de type *NS* pour obtenir la liste des serveurs de noms du cluster, nous devons donc choisir ce type. Un TTL court, tel qu'une minute, est aussi une
bonne idée. Puis nous devons saisir la liste des serveurs de noms du cluster, donc la liste des nœuds. Dans d'autres logiciels de DNS, nous devrions saisir un enregistrement
*NS* par valeur mais *Route53* s'en charge pour nous. J'ai également pris l'habitude de terminer chaque valeur par un point, ce n'est pas une coquille, car certains logiciels
DNS le nécessitent et cela ne semble pas poser de problème à *Route53*. Finalement, cliquez sur le bouton *Créer*:

![Enregistrement des noms de serveurs][07-NSRecord.png]

Félicitations, vous avez terminé la configuration DNS dans *Route53* pour votre cluster RLEC. Il est temps de vérifier ce que nous avons.

# Vérification

Vous devriez avoir plusieurs enregistrements *A* de serveur DNS (un pour chaque nœud du cluster) pour pouvoir atteindre n'importe lequel par son nom. Vous devriez également
disposer d'un enregistrement *NS* qui liste tous les DNS de la zone (cluster):

![Configuration finale][08-FinalConfig.png]

Si les nœuds du cluster sont en bonne santé et fonctionnels, avec les ports réseau DNS ouverts, vous pouvez tester la configuration. Qui sont les serveurs de noms en carge de
la résolution dans le cluster:

```
dig ns demo.francois.demo-rlec.redislabs.com

; <<>> DiG 9.9.5-9+deb8u9-Debian <<>> ns demo.francois.demo-rlec.redislabs.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 25061
;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;demo.francois.demo-rlec.redislabs.com. IN NS

;; ANSWER SECTION:
demo.francois.demo-rlec.redislabs.com. 3409 IN NS ns2.demo.francois.demo-rlec.redislabs.com.
demo.francois.demo-rlec.redislabs.com. 3409 IN NS ns1.demo.francois.demo-rlec.redislabs.com.
demo.francois.demo-rlec.redislabs.com. 3409 IN NS ns3.demo.francois.demo-rlec.redislabs.com.

;; Query time: 31 msec
;; SERVER: 192.168.1.254#53(192.168.1.254)
;; WHEN: Tue Feb 14 16:49:13 CET 2017
;; MSG SIZE  rcvd: 120
```

Vous pouvez constater que les noms ont été remplacés par `ns?`. Cette réponse ne provient pas de *Route53*, mais des serveurs de nom du cluster.

Maintenant, vous pouvez soit installer et configurer vos nœuds, si ce n'est déjà fait, soit connecter votre client en utilisant le nom d'un des nœuds du cluster (**surtout pas
une adresse IP**)

# Supports et liens

| Lien | Description |
|---|---|
| [Video] | Enregistrement vidéo de la démonstration |

# Notes de bas de page

[Video]: https://youtu.be/nmVD5uTjP2M "Demonstration video recording"
[01-ServicesRoute53.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/01-ServicesRoute53-fr.png "Route53 in the Services menu"
[02-Route53HostedZones.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/02-Route53HostedZones-fr.png "Route53 Hosted zones"
[03-HostedZoneSelection.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/03-HostedZoneSelection-fr.png "Route53 Hosted zone selection"
[04-CreateRecordSet.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/04-CreateRecordSet-fr.png "Create a new record set"
[05-NS1Configuration.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/05-NS1Configuration-fr.png "First nameserver configuration"
[06-NSList.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/06-NSList-fr.png "Nameservers list"
[07-NSRecord.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/07-NSRecord-fr.png "Nameservers record"
[08-FinalConfig.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/08-FinalConfig-fr.png "Final configuration"
[^1]: RedisLabs Enterprise Cluster
[^2]: Fully Qualified Domain Name
[^3]: Top Level Domins
[^4]: Amazon Web Services
