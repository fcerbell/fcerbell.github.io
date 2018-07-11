---
uid: RLECNodesIPManagement
title: Gestion des IPs d'un cluster Redis Enterprise
author: fcerbell
layout: post
lang: fr
#description:
category: Tutos
tags: [ Redis, RedisLabs, RLEC, Cluster ]
#date: 9999-01-01
published: true
---

Les nœuds d'un cluster RedisLabs (RLEC[^1]) peuvent séparer les traffic réseau
en deux catégories : interne utilisant une et une seule interface réseau pour
communiquer entre les nœuds pour la réplication et la gestion du cluster, et
externe utilisant une ou plusieurs interfaces pour les connexions des
applications. Voici comment changer ces réglages après avoir effectué la
configuration initiale, en utilisant l'API REST ou les outils en ligne de
commande.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

* TOC
{:toc}

# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/kK4GxAwJKD0" frameborder="0" allowfullscreen></iframe></center>

# Pré-requis

Vous disposez d'un cluster Redis Enterprise fonctionnel. Soit vous avez
ajouté/retiré des interfaces réseau aux nœuds, soit vous avez changé le plan
d'adressage des interfaces réseau.

# Pourquoi 

Lorsque vous créez une base de données dans Redis Enterprise, le cluster vous
donne un point d'entrée. Il s'agit du nom de la base qui sera utilisé par les
applications pour se connecter à la base. Dans RLEC, chaque nœud exécute les
même processus, incluant le processus proxy pour gérer les connexions des
clients.

En fonction de la politique de proxy des point d'entrées de votre base, un
d'entre-eux ou plusieurs seront configurés pour accepter les connexions
concernant cette base. Cela signifie que votre client pourra se connecter à la
base de donnée en utilisant un des proxy configurés et devra donc connaître la
liste des proxy qui sont configurés. Cela peut se faire en utilisant une
résolution DNS ou un service de découverte.

Quelque soit le protocole utilisé, il doit renvoyer la liste d'adresses IP
appropriée, soit la liste des adresses IP externes associées aux nœuds
concernés, mais pas leur adresse IP interne.

Peut-être avez-vous fait une erreur lors de l'initialisation, ou vous avez
modifié la configuration matérielle pour ajouter ou retirer des interfaces
réseau, ou vous souhaitez optimiser votre utilisation du réseau, ou... Peu
importe, vous devez modifier la liste des adresses IP externes de certains
nœuds.

Malgré le fait que vous puissiez vérifier la configuration des adresses internes
et externes depuis l'interface web d'administration, dans le menu « Nodes », et
dans l'onglet « Configuration » d'un des nœuds, vous ne pouvez pas l'y modifier.

![Onglet de configuration d'un nœud][webnodeconfiguration.png]

Vous pouvez modifier ces réglages en utilisant soit l'outil en ligne de commande
« rladmin », soit les appels d'API REST.

Cela peut être utile lorsque vous initialisez un nœud rapidement. Par défaut,
toutes les interfaces réseau sont dans la liste des adresses externes, les
points d'entrées renverront toutes les adresses, mais certaines d'entre-elles ne
seront peut-être pas joignables depuis vos applications clientes.

# Avec rladmin

Vous pouvez ouvrir une fenêtre de commande sur n'importe quel nœud du cluster et
vous y connecter avec un compte membre du groupe « redislabs » pour utiliser
rladmin. Ensuite, vous pouvez soit le démarrer interactivement, avec une invite
de commande, soit lui demander d'exécuter une commande spécifique passée en
argument. Les deux possibilités suivantes sont strictement similaires.

```
root@ip-172-31-56-5:~# rladmin status endpoints
ENDPOINTS:
DB:ID      NAME     ID                       NODE         ROLE         SSL      
db:1       IoT      endpoint:1:1             node:3       single       No       
```

```
root@ip-172-31-56-5:~# rladmin 
RedisLabs Admin CLI
Version 5.0.2-15

Use <?> for help at any time, <TAB> for command completion.

rladmin> status endpoints
ENDPOINTS:DB:ID      NAME     ID                       NODE         ROLE         SSL      
db:1       IoT      endpoint:1:1             node:3       single       No       
rladmin> quit
```

La première est pratique pour scripter et automatiser des commandes, la seconde
pour une administration interactive avec auto-complétion.

## Vérification des adresses externes

Vous pouvez demander la configuration de tous les nœuds ou vous pouvez indiquer
un nœud particulier :

```
rladmin> info node 1
node:1
    address: 172.31.56.5
    external addresses: 34.199.174.185
    recovery path: N/A
    quorum only: disabled
```

```
rladmin> info node
node:1
    address: 172.31.56.5
    external addresses: 34.199.174.185
    recovery path: N/A
    quorum only: disabled

node:2
    address: 172.31.55.7
    external addresses: 34.199.175.137
    recovery path: N/A
    quorum only: disabled

node:3
    address: 172.31.50.67
    external addresses: 34.195.100.46
    recovery path: N/A
    quorum only: disabled
```

Si je tente de résoudre l'un de mes points d'entrée, j'obtiens une seule adresse
IP :

```
root@ip-172-31-56-5:~# nslookup redis-14658.demo.francois.demo-rlec.redislabs.com
Server:		172.31.0.2
Address:	172.31.0.2#53

Non-authoritative answer:
Name:	redis-14658.demo.francois.demo-rlec.redislabs.com
Address: 34.195.100.46
```

Ce point d'entrée est configuré pour n'avoir qu'un seul proxy en écoute, ce
proxy est actuellement celui du troisième nœud et ce nœud ne dispose que d'une
seule adresse externe.

## Ajout d'une adresse dans la liste des adresses externes d'un nœud

Maintenant que vous disposez de la liste des nœuds et de leurs adresses externes
associées, vous pouvez ajouter une adresse à la liste externe d'un des nœuds en
utilisant la commande suivante. Supposons que je souhaite gérer les connexions
clientes entrantes sur les deux interfaces du nœud 3. Je dois ajouter l'adresse
172.31.50.67 (actuellement uniquement utilisée pour le traffic interne) à la
liste des adresses externes :

```
rladmin> node 3 external_addr add 172.31.50.67
Updated successfully.
```

Ensuite, je peux vérifier en utilisant la commande `info node 3` décrite
précédemment :

```
rladmin> info node 3
node:3
    address: 172.31.50.67
    external addresses: 34.195.100.46, 172.31.50.67
    recovery path: N/A
    quorum only: disabled
```

Si je demande une résolution pour le point d'entrée actuellement attaché au
proxy du troisième nœud, je peux voir les deux adresses externes.

```
root@ip-172-31-56-5:~# nslookup redis-14658.demo.francois.demo-rlec.redislabs.com
Server:		172.31.0.2
Address:	172.31.0.2#53

Non-authoritative answer:
Name:	redis-14658.demo.francois.demo-rlec.redislabs.com
Address: 34.195.100.46
Name:	redis-14658.demo.francois.demo-rlec.redislabs.com
Address: 172.31.50.67
```

Mes clients auront le choix pour se connecter.

## Suppression d'une adresse de la liste externe d'un nœud

La suppression d'une adresse de la liste des adresses externes d'un nœud se fait
à l'aide de la sous-sous-commande « remove » :

```
rladmin> info node 3
node:3
    address: 172.31.50.67
    external addresses: 34.195.100.46, 172.31.50.67
    recovery path: N/A
    quorum only: disabled

rladmin> node 3 external_addr remove 172.31.50.67
Updated successfully.
```

```
rladmin> info node 3
node:3
    address: 172.31.50.67
    external addresses: 34.195.100.46
    recovery path: N/A
    quorum only: disabled
```

# Avec l'API REST

La documentation de l'API REST est inclue et installée lorsque vous provisionnez
un nœud, avec le logiciel. J'utilise ici l'outil en ligne de commande `curl`.

Par défaut, l'API écoute depuis tous les nœuds sur le port 9443, en utilisant
des certificats SSL. Les certificats SSL sont créés lorsque vous initialisez
votre cluster et sont auto-signés. Curl ne les acceptera pas à moins d'ajouter
l'argument « insecure ». La commande curl devrait donc toujours commencer par
`curl "https://localhost:9443/v1/nodes/1" --insecure`

Étant donné que les connexions se font pas le réseau, vous devez fournir les
identifiants de connexion d'un administrateur du cluster : `-u
"francois@redislabs.com:secret"`

L'API REST attend des commandes et des données au format JSON, curl peut dont
l'informer qu'il envoit bien du JSON : `-H "Content-Type:application/json"` et
qu'il accepte des réponse au format JSON en retour : `-H
"Accept:application/json"`

Ainsi, les commands curl commenceront par :
```
curl "https://localhost:9443/v1/nodes/1" \
        --insecure \
        -u "francois@redislabs.com:password" \
        -H "Accept:application/json" \
        -H "Content-Type:application/json" \
```

Commençons à partir de cette configuration initiale :

```
root@ip-172-31-56-5:~# rladmin info node
node:1
    address: 172.31.56.5
    external addresses: 34.199.174.185
    recovery path: N/A
    quorum only: disabled

node:2
    address: 172.31.55.7
    external addresses: 34.199.175.137
    recovery path: N/A
    quorum only: disabled

node:3
    address: 172.31.50.67
    external addresses: 34.195.100.46
    recovery path: N/A
    quorum only: disabled
```

## Vérification des adresses externes

Vous pouvez soit demander la configuration de tous les nœuds ou vous pouvez
indiquer un nœud particulier :

Pour le premier nœud :
```
root@ip-172-31-56-5:~# curl "https://localhost:9443/v1/nodes/1" \
--insecure \
-X "GET" \
-H "Accept:application/json" \
-H "Content-Type:application/json" \
-u "francois@redislabs.com:password" 
{
  "accept_servers": true,
  "addr": "172.31.56.5",
  "architecture": "x86_64",
  "bigredis_storage_path": "/var/opt/redislabs/flash",
  "bigstore_driver": "rocksdb",
  "bigstore_size": 26279878656,
  "cores": 36,
  "ephemeral_storage_path": "/var/opt/redislabs/tmp",
  "ephemeral_storage_size": 26279878656.0,
  "external_addr": [
    "34.199.174.185"
  ],
  "os_version": "Ubuntu 16.04.3 LTS",
  "persistent_storage_path": "/var/opt/redislabs/persist",
  "persistent_storage_size": 26279878656.0,
  "rack_id": "",
  "shard_count": 0,
  "shard_list": [],
  "software_version": "5.0.2-15",
  "status": "active",
  "supported_database_versions": [
    {
      "db_type": "memcached",
      "version": "1.4.17"
    },
    {
      "db_type": "redis",
      "version": "3.2.11"
    },
    {
      "db_type": "redis",
      "version": "4.0.2"
    }
  ],
  "total_memory": 63314849792,
  "uid": 1,
  "uptime": 3633
}
```

Pour tous les nœuds :
```
root@ip-172-31-56-5:~# curl "https://localhost:9443/v1/nodes" \
--insecure \
-X "GET" \
-H "Accept:application/json" \
-H "Content-Type:application/json" \
-u "francois@redislabs.com:password" 
```

Si je tente de résoudre un de mes points d'entrée, j'obtiens uniquement une
seule adresse IP :

```
root@ip-172-31-56-5:~# nslookup redis-14658.demo.francois.demo-rlec.redislabs.com
Server:		172.31.0.2
Address:	172.31.0.2#53

Non-authoritative answer:
Name:	redis-14658.demo.francois.demo-rlec.redislabs.com
Address: 34.195.100.46
```

Ce point d'entrée est configuré pour n'avoir qu'un seul proxy à l'écoute, ce
proxy est celui du troisième nœud et ce troisième nœud ne dispose que d'une
seule adresse externe.

## Ajout d'une adresse à la liste d'adresses externe

Maintenant que vous avez la liste de vos nœuds et les adresses externes
associées, vous pouvez ajouter une adresse à la liste d'un nœud en utilisant la
commande suivante. Supposons que je souhaite gérer les connexions clientes
entrantes sur les deux interfaces du nœud 3, je dois ajouter l'adresse
172.31.50.67 (actuellement uniquement utilisée pour le traffic interne) à la
liste des adresses externes.

Lorsque l'on utilise l'API REST, il faut indiquer la liste complète des adresses
externes, il n'est pas possible de d'ajouter ou de supprimer une adresse seule.

```
curl "https://localhost:9443/v1/nodes/3" \
        --insecure \
        -X "PUT" \
        -H "Accept:application/json" \
        -H "Content-Type:application/json" \
        -u "francois@redislabs.com:password" \
        -d '{
       "external_addr": ["34.195.100.46","172.31.50.67"]
}'
```

Ensuite, je peux vérifier en utilisant la commande `info node 3` décrite
précédemment :

```
rladmin> info node 3
node:3
    address: 172.31.50.67
    external addresses: 34.195.100.46, 172.31.50.67
    recovery path: N/A
    quorum only: disabled
```

Si je demande la résolution du point d'entrée actuellement attaché au proxy du
troisième nœud, je peux voir les deux adresses externes.

```
root@ip-172-31-56-5:~# nslookup redis-14658.demo.francois.demo-rlec.redislabs.com
Server:		172.31.0.2
Address:	172.31.0.2#53

Non-authoritative answer:
Name:	redis-14658.demo.francois.demo-rlec.redislabs.com
Address: 34.195.100.46
Name:	redis-14658.demo.francois.demo-rlec.redislabs.com
Address: 172.31.50.67
```

Mes clients auront donc le choix pour se connecter.

## Suppression d'une adresses de la liste d'adresses externes d'un nœud

Avec l'API REST, il faut indiquer la liste complète d'adresse. La première étape
est donc de récupérer cette liste :

```
root@ip-172-31-56-5:~# curl "https://localhost:9443/v1/nodes/3" \
--insecure \
-X "GET" \
-H "Accept:application/json" \
-H "Content-Type:application/json" \
-u "francois@redislabs.com:password" 
{
  "accept_servers": true,
  "addr": "172.31.50.67",
  "architecture": "x86_64",
  "bigredis_storage_path": "/var/opt/redislabs/flash",
  "bigstore_driver": "rocksdb",
  "bigstore_size": 26279878656,
  "cores": 36,
  "ephemeral_storage_path": "/var/opt/redislabs/tmp",
  "ephemeral_storage_size": 26279878656.0,
  "external_addr": [
    "34.195.100.46",
    "172.31.50.67"
  ],
  "os_version": "Ubuntu 16.04.3 LTS",
  "persistent_storage_path": "/var/opt/redislabs/persist",
  "persistent_storage_size": 26279878656.0,
  "rack_id": "",
  "shard_count": 2,
  "shard_list": [
    1,
    3
  ],
  "software_version": "5.0.2-15",
  "status": "active",
  "supported_database_versions": [
    {
      "db_type": "memcached",
      "version": "1.4.17"
    },
    {
      "db_type": "redis",
      "version": "3.2.11"
    },
    {
      "db_type": "redis",
      "version": "4.0.2"
    }
  ],
  "total_memory": 63314849792,
  "uid": 3,
  "uptime": 5533
}
```

Ensuite, il est possible de mettre à jour la liste du nœud 3, en retirant
l'adresse voulue :

```
curl "https://localhost:9443/v1/nodes/3" \
        --insecure \
        -X "PUT" \
        -H "Accept:application/json" \
        -H "Content-Type:application/json" \
        -u "francois@redislabs.com:password" \
        -d '{
       "external_addr": ["34.195.100.46"]
}'
```

Enfin, je peux vérifier en utilisant la commande vue précédemment :

```
root@ip-172-31-56-5:~# curl "https://localhost:9443/v1/nodes/3" \
--insecure \
-X "GET" \
-H "Accept:application/json" \
-H "Content-Type:application/json" \
-u "francois@redislabs.com:password" 
{
  "accept_servers": true,
  "addr": "172.31.50.67",
  "architecture": "x86_64",
  "bigredis_storage_path": "/var/opt/redislabs/flash",
  "bigstore_driver": "rocksdb",
  "bigstore_size": 26279878656,
  "cores": 36,
  "ephemeral_storage_path": "/var/opt/redislabs/tmp",
  "ephemeral_storage_size": 26279878656.0,
  "external_addr": [
    "34.195.100.46"
  ],
  "os_version": "Ubuntu 16.04.3 LTS",
  "persistent_storage_path": "/var/opt/redislabs/persist",
  "persistent_storage_size": 26279878656.0,
  "rack_id": "",
  "shard_count": 2,
  "shard_list": [
    1,
    3
  ],
  "software_version": "5.0.2-15",
  "status": "active",
  "supported_database_versions": [
    {
      "db_type": "memcached",
      "version": "1.4.17"
    },
    {
      "db_type": "redis",
      "version": "3.2.11"
    },
    {
      "db_type": "redis",
      "version": "4.0.2"
    }
  ],
  "total_memory": 63314849792,
  "uid": 3,
  "uptime": 5846
}
```


# Supports et liens

| Lien | Description |
|---|---|
| [RedisLabs.com] | L'entreprise derrière Redis |
| [Redis.io] | Page du projet Redis |
| [Video] | Enregistrement vidéo |

# Notes de bas de page

[^1]: RLEC, RedisLabs Enterprise Cluster, désormais connu sous le nom de Redis^e pour Redis Enterprise.

[Video]: https://youtu.be/kK4GxAwJKD0 "Enregistrement vidéo de la démonstration"
