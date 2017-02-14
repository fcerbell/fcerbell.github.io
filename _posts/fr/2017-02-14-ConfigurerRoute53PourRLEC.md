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


# *Traduction du texte en cours. Vidéo déjà en Français*

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

After the theory, we can go through the hands-on steps to achieve this configuration with AWS's Route53 DNS as your domain or sub-domain official name server.

## Connexion au DNS Route53 d'Amazon

The first step is to connect your browser to AWS and to login into the administration interface. Then, you have to go in the *Services* menu at the top of the page and clic on the *Route53* menu item :

![Route53 dans le menu Services][01-ServicesRoute53.png]

Then, I assume that you already have registered a domain, and that you defined *Route53* as the primary/master name server for the whole domain or for one of its sub-domains. So, you should have at least one zone in *Route53*. Clic on the *Hosted zones* link to open it:

![Zones hébergées dans Route53][02-Route53HostedZones.png]

*Route53* is now displaying the list of the zones that you defined. You need to clic on the zone in which you want to define your cluster, *demo-rlec.redislabs.com* in my case:

![Séléction de la zone hébergée][03-HostedZoneSelection.png]

## Création des enregistrements des serveurs de nom

The next step is to create the record that returns the IP address of your cluster's name servers, ie one of your cluster's nodes. To create the first name server IP address resolution record, you need to clic on the *Create Record Set* blue button at the top of the list:

![Créer un jeu d'enregistrements][04-CreateRecordSet.png]

This record will **only** be used to resolve the IP address of the cluster name server to query, it is **not** used by the application to connect to the cluster. This kind of record is an *A* record type and associates an IP address to a name. To avoid the whole resolving process each time that a name
is requested, the results are cached in the forwarding DNS and in the application's resolver library. Given that the IP address associated with a node can change when thoe related hardware fails, the information needs to expire quickly, otherwise, the node fails, the name servers reflects the failover,
but they are not queried again and the local resolver still returns the IP of the failed node. This is the Time To Live (TTL) field associated to the record.

So, you need to enter the name used as the name server's name, despite that it could be different, I suggest that you use the node name. You need to enter its IP address, to set the TTL to something short, I'll set it to one minute. This is the maximum amount of time that the record will be kept in
cache of the resolver and of the forwarding DNS. If the node goes down, the resolver will still use this value until the record expires in his cache, but as the node will not answer, the resolver will try the next name server in the list (he has the *A* record because he needed to know the IP of the
first name server, and if he needed this IP, he already had the name server list).

Finally submit the first name server's *A* record to *Route53*, using the *Create* button at the bottom of the right panel:

![Configuration du premier serveur de noms][05-NS1Configuration.png]

You want (and need) to have all your cluster nodes acting asname servers, soyou have to repeat these steps for all your nodes and you should get a list of *A* records in *Route53* interface:

![Liste de serveurs de noms][06-NSList.png]

Now, the client-side resolver and the forwarding DNS can reach the cluster nmeservers by their IP address, if they know what are the names of the cluster's name servers. That's the next point.

## Définition de la liste des serveurs de nom de la sous-zone

Here, the idea is to provide the list of the cluster nameserver's names to the resolvers and the forwarding DNS, so that they will be able to resolve the IP address of one of them and query it for node's IP. To achieve that, we have to define a new record in *Route53*, an *NS* record for Name Server
record. So, once again, we will clic on the button to *Create [a] Record Set* and we will enter the relevant informations in the right panel.

The name is the name of the cluster, if your cluster nodes are `nodeX.mycluster.enterprise.com`, then the cluster name is `mycluster.enterprise.com`. Remember, the resolver will ask "who are the name servers for zone <ClusterName>". The name is the searched key, the record type is the field. In our
case, the resolver will ask for the `NS` record type to get the nameservers list of the clustername, so we have to choose this type. A short TTL, such as one minute, is a good idea here, too. And we have to enter the node name list in the text box. In other DNS, we would have to create one NS record
for each item, but *Route53* takes care of that for us. I also have the habbit to end these records with a final dot, it is not a typo, because some other DNS require it and it does not seem to be an issue with *Route53*. At the end, we can clic on the *Create* button:

![Enregistrement des noms de serveurs][07-NSRecord.png]

Congratulations, you completed the *Route53* DNS configuration for your RLEC. Let's check what you have.

# Vérification

You should end with several name server *A* record (one for each cluster node) to be able to reach any of them by its name. You should also have one record that lists the nameservers names for the zone (cluster):

![Configuration finale][08-FinalConfig.png]

If your cluster nodes are healthy, up and running, with DNS network ports unfiltered, you can test the configuration. Who are the nameservers in charge of the resolution in the cluster:

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

You can see that the name were changed to `ns?`. This answer does not come from *Route53* but from the cluster nameservers themselves.

Now you can either install and configure your nodes, if not already made, or connect your client, using the cluster name (**not the IP address**).

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
