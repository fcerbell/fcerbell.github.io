---
uid: ManagedRedisForPythonMicroserviceInCloudRun
title: Redis 12 - Redis enterprise managé et microservice Python dans CloudRun
description: J'explique pas à pas comment implémenter une API Python FastAPI pour servir des données depuis un docker Redis-stack local, un docker Redis Enterprise local et un Redis Enterprise managé DBaaS. J'explique aussi comment dockeriser l'API, l'exécuter locallement et la faire exécuter comme service Google CloudRun. Avec les sources et la connexion depuis le client graphique RedisInsight.

category: Redis en 5 minutes
tags: [ Redis, Redis Enterprise, Python, Microservice, FastAPI, Docker, Google, GCP, CloudRun, PaaS, DBaaS, Managed Redis, REST API, Stateless ]

# lang: en/fr # (from _config.yml and folder)
# author: François Cerbelle # (From _config.yml)
# date: 22/02/2024 21:18 # from filename
# noindex: false # To disallow robots.txt (false)
# mainmenu: false # To include the main navbar (false)
# mathjax: true # To include mathjax js for LaTeX formulas (false)
# comments: true # To include Disqus bloc (true)
# published: true
---

J'explique pas à pas comment implémenter une API #Python FastAPI pour servir des données depuis un docker Redis-stack local, un docker #Redis Enterprise local et un Redis Enterprise managé DBaaS. J'explique aussi comment dockeriser l'API, l'exécuter locallement et la faire exécuter comme service Google #CloudRun. Avec les sources et la connexion depuis le client graphique #RedisInsight.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports imprimables associés à la
[fin de cet article](#supports-et-liens).

* TOC
{:toc}

# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/QONgF2J7qUE" frameborder="0" allowfullscreen></iframe></center>

# Squelette Python et FastAPI

## Environement de dev

D'abord, il faut créer un répertoire pour stocker les sources et un environnement de développement virtuel Python :

```bash
mkdir FastApiDemo
cd FastApiDemo
python3 -m venv venv
source venv/bin/activate
pip install fastapi
pip install uvicorn
```

## Code de l'API

Ensuite, on peut commencer avec une liste d'objets stockée en mémoire, dans un tebleau, et deux points de connexion REST pour implémenter les lectures (GET) et les écritures (PUT) :

**main.py** :
```python
# Modèle de données
#
from pydantic import BaseModel
from typing import Union
class User(BaseModel):
    name: str
    email: str
    age: int
    city: str
    height: float
    weight: float
    gender: Union[bool, None] = None

users = []

# Expose data access with a REST API provided by FastAPI
#
from fastapi import FastAPI
app = FastAPI()

# Interface de consultation
#
@app.get("/users/{user_id}")
def read_user(user_id: int):
    return users[user_id]

# Interface de modification
#
@app.put("/users/{user_id}")
def update_user(user_id: int, user: User):
    while (len(users)<=user_id):
        users.append("");
    users[user_id]=user
    return True
```

## Test de l'API

Nous pouvons désormais démarrer le serveur `uvicorn` pour exposer les points de connexion de l'API.

```bash
uvicorn main:app --reload
```

Puis les tester grâce à `curl` en ligne de commande, 

```bash
curl http://localhost:8000/users/1 --request GET --header 'content-type: application/json'
curl --request PUT --url "http://localhost:8000/users/1" --header 'content-type: application/json' --data '{"name":"Paul John","email":"paul.john@example.com","age":42,"city":"London","height":0,"weight":0,"gender":"True"}'
curl http://localhost:8000/users/1 --request GET --header 'content-type: application/json'
xdg-open http://localhost:8000/docs
```

puis grâce à l'interface wab de Swagger fournie par FastAPI sur l'URL http://localhost:8000/docs :

![372f09be9bbeea62c88ea95275f28e49.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/372f09be9bbeea62c88ea95275f28e49.png" | relative_url }})

# Base locale : Redis-Stack

Désormais, nous voulons utiliser une base Redis à la place du tableau d'objets en mémoire pour y stocker les enregistrements. Cela rendra notre microservice complètement « Stateless ».

## Préparation

Nous commençons par démarrer une image dockerisée de Redis communautaire avec tous les modules officiels. Elle expose une base Redis sur le port standard $6379$ et un client graphique *RedisInsight* sur le port $8001$

```bash
docker run -p 6379:6379 -p 8001:8001 --name redis-stack redis/redis-stack
```

Il faut ensuite installer la bibliothèque cliente Redis pour Python dans l'environnement virtuel de développement et j'utilise des variables d'environnement pour transmettre les détails de connexion au microservice :
```bash
pip install "redis[hiredis]"
export REDISHOST=localhost
export REDISPORT=6379
```

## Utilisation de Redis dans le code

Nous pouvons enfin modifier le code pour qu'il utilise Redis :
1. Retirer le tableau en mémoire
2. Inclure la bibliothèque cliente
3. Ouvrir une connexion sur la base Redis
4. Éventuellement pré-peupler la base avec des exemples
5. Utiliser Redis comme source pour le point de connexion en lecture (GET)
6. Utiliser Redis comme destination pour le point de connexion en écriture (PUT)

```python
# Modèle de données
#
from pydantic import BaseModel
from typing import Union
class User(BaseModel):
    name: str
    email: str
    age: int
    city: str
    height: float
    weight: float
    gender: Union[bool, None] = None

# Bibliothèque cliente Redis et ouverture de la connexion
#
import redis
import os
r = redis.Redis(
        host=os.environ.get('REDISHOST'),
        port=os.environ.get('REDISPORT'),
        )

# Insertion de quelques enregistrements d'exemple
# JSON en utilisant le module éponyme dans Redis
#
from redis.commands.json.path import Path
r.json().set("user:1", Path.root_path(), { "name": "Paul John", "email": "paul.john@example.com", "age": 42, "city": "London" })
r.json().set("user:2", Path.root_path(), { "name": "Eden Zamir", "email": "eden.zamir@example.com", "age": 29, "city": "Tel Aviv" })
r.json().set("user:3", Path.root_path(), { "name": "Paul Zamir", "email": "paul.zamir@example.com", "age": 35, "city": "Tel Aviv" })

# Expose data access with a REST API provided by FastAPI
#
from fastapi import FastAPI
app = FastAPI()

# Point de connexion en consultation
#
@app.get("/users/{user_id}")
def read_user(user_id: int):
    return r.json().get("user:"+str(user_id))

# Point de connexion en modification
#
@app.put("/users/{user_id}")
def update_user(user_id: int, user: User):
    return r.json().set('user:'+str(user_id), Path.root_path(),
        { "name": user.name, "email": user.email, "age": user.age, "city": user.city, "height": user.height, "weight": user.weight, "gender": user.gender })
```

## Test de l'API

Nous pouvons redémarrer le serveur d'application local :
```bash
uvicorn main:app --reload
```

et tenter de consulter les quatre premiers enregistrements :
```bash
for i in 1 2 3 4; do
  printf "\n%s: " "$i"
  curl http://localhost:8000/users/$i --request GET --header 'content-type: application/json'
done
```

Il n'y en a que trois, le quatrième n'existe pas et renvoie *null*

![315e0f9083bd7e02d1c533bc1da7990b.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/315e0f9083bd7e02d1c533bc1da7990b.png" | relative_url }})

Créons le en ligne de commande :
```bash
curl --request PUT --url "http://localhost:8000/users/4" --header 'content-type: application/json' --data '{"name":"Francois Cerbelle","email":"francois@redis.com","age":48,"city":"Paris","height":179,"weight":84,"gender":"True"}'
```

Et vérifions dans l'interface de Swagger, par exemple :

![0056b68bd7afe953885a69b1f28cfdf7.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/0056b68bd7afe953885a69b1f28cfdf7.png" | relative_url }})

# Base locale : Redis Enterprise

Le but est d'utiliser un environnement de développement aussi proche que possible de l'environnement final de production. Remplaçons la base locale Redis communautaire par une base Redis Entreprise.

## Installation rapide

Tout d'abord, nous pouvons démarrer une image docker de Redis Enterprise. J'expose les ports réseau pour l'interface d'administration web et pour l'API REST :
```bash
docker run -d --cap-add sys_resource --name redisenterprise1 -p 8443:8443 -p 9443:9443 redislabs/redis
```

## Initialisation du cluster

 Redis Entreprise fonctionne comme un orchestrateur et un gestionnaire de configuration pour des bases Redis, un peu comme Kubernetes pour des conteneurs. Nous devons donc commencer par initialiser le cluster Redis Enterprise avec un premier, et seul, nœud. Pour cela, il y a soit l'interface web : https://localhost:8443
```bash
xdg-open https://localhost:8443
```

Création du premier administrateur :

![8678540f2a120d7cefc1fe562b1e6474.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/8678540f2a120d7cefc1fe562b1e6474.png" | relative_url }})

Choix du nom de cluster :

![d6641ace1d45c9fcfc102e1093f2973d.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/d6641ace1d45c9fcfc102e1093f2973d.png" | relative_url }})

Configuration du nœud :

![a7f377b90656d0660e84de6b73b34d40.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/a7f377b90656d0660e84de6b73b34d40.png" | relative_url }})

soit l'API REST :
```bash
curl "https://127.0.0.1:9443/v1/bootstrap/create_cluster" --insecure -X "POST" -H "Accept:application/json" -H "Content-Type:application/json" -u "francois@redis.com:password" -d '{"action": "create_cluster","cluster": { "name": "cluster.local" },"node": {"paths": {"persistent_path": "/var/opt/redislabs/persist","ephemeral_path": "/var/opt/redislabs/tmp","bigredis_storage_path": "/var/opt/redislabs/flash"}},"license": "","credentials": {"username": "francois@redis.com","password": "password"}}'
```

## Création de la base

Nous pouvons ensuite décrire à Redis Enterprise la base Redis que nous souhaitons lui voir créer, superviser, maintenir et exposer avec les modules nécessaires à notre projet (JSON et Search). Nous utiliserons l'interface web, mais nous pourrions également utiliser l'API REST.

```bash
xdg-open https://localhost:8443
```

![c22f19ea3d6eb0c4b477af60d3f20bf2.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/c22f19ea3d6eb0c4b477af60d3f20bf2.png" | relative_url }})

Nous pourrions utiliser l'API REST, mais nous utiliserons l'interface web pour récupérer les informations de connexion à la base, le nom ou l'IP, le port et éventuellement le mot de passe :

![30c3a601f7ca0da4dda027e40b877224.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/30c3a601f7ca0da4dda027e40b877224.png" | relative_url }})

Utilisons les informations receuillies pour valoriser les variables d'environnement de notre microservice.

```bash
export REDISHOST=172.17.0.2
export REDISPORT=12581
export REDISPASS=xxx
```

## Authentification depuis le code

Nous devons éventuellement modifier le code pour utiliser le mot de passe fourni par la variable d'environnement lors de la connexion à la base Redis :

```python
# Modèle de données
#
from pydantic import BaseModel
from typing import Union
class User(BaseModel):
    name: str
    email: str
    age: int
    city: str
    height: float
    weight: float
    gender: Union[bool, None] = None

# Stockage des données dans Redis
#
import redis
import os
r = redis.Redis(
        host=os.environ.get('REDISHOST'),
        port=os.environ.get('REDISPORT'),
        password=os.environ.get('REDISPASS'),
        )

# Prépopulation de la base avec des enregistrements d'exemple
# en JSON
#
from redis.commands.json.path import Path
r.json().set("user:1", Path.root_path(), { "name": "Paul John", "email": "paul.john@example.com", "age": 42, "city": "London" })
r.json().set("user:2", Path.root_path(), { "name": "Eden Zamir", "email": "eden.zamir@example.com", "age": 29, "city": "Tel Aviv" })
r.json().set("user:3", Path.root_path(), { "name": "Paul Zamir", "email": "paul.zamir@example.com", "age": 35, "city": "Tel Aviv" })

# Expose data access with a REST API provided by FastAPI
#
from fastapi import FastAPI
app = FastAPI()

# Point de connexion pour les consultations
#
@app.get("/users/{user_id}")
def read_user(user_id: int):
    return r.json().get("user:"+str(user_id))

# Point de connexion pour les modifications
#
@app.put("/users/{user_id}")
def update_user(user_id: int, user: User):
    return r.json().set('user:'+str(user_id), Path.root_path(),
        { "name": user.name, "email": user.email, "age": user.age, "city": user.city, "height": user.height, "weight": user.weight, "gender": user.gender })
```

## Test du microservice

Voilà le moment de tester la connexion de notre microservice à la base Redis fournie par Redis Enterprise. Redémarrons-le :

```bash
uvicorn main:app --reload
```

Nous pouvons utiliser le même scénario que précédemment, je ne vais pas le détailler une seconde fois :
```bash
for i in 1 2 3 4; do
  printf "\n%s: " "$i"
  curl http://localhost:8000/users/$i --request GET --header 'content-type: application/json'
done
curl --request PUT --url "http://localhost:8000/users/4" --header 'content-type: application/json' --data '{"name":"Francois Cerbelle","email":"francois@redis.com","age":48,"city":"Paris","height":179,"weight":84,"gender":"True"}'
xdg-open http://localhost:8000/docs
```

# Dockerisation du microservice

## Préparation

Listons les dépendences de notre microservice pour qu'elles soient disponibles dans le conteneur.

**requirements.txt** :
```
typing
pydantic
fastapi
uvicorn
redis
```

Spécifions la manière de construire le conteneur. Je me suis basé sur l'exemple fourni par Google CloudRun que j'ai modifié pour utiliser *uvicorn* à la place de *gunicorn*.

**Dockerfile** :
```dockerfile
# From https://cloud.google.com/run/docs/quickstarts/build-and-deploy/python?hl=fr

# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.10-slim

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

# Install production dependencies.
RUN pip install --no-cache-dir -r requirements.txt

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.
#CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
CMD exec uvicorn --host 0.0.0.0 --port $PORT main:app
```

Il est inutile d'empaqueter certains fichiers temporaire ou de développement, listons les dans les exclusions.

**.dockerignore** :
```
Dockerfile
README.md
*.pyc
*.pyo
*.pyd
__pycache__
.pytest_cache
```

## Construction du conteneur

L'étape de construction doit être assez rapide, quelques secondes, vu la simplicité de notre microservice.

```bash
docker build -t fastapi .
```

## Exécution du microservice

La ligne de commande démarre le conteneur docker du microservice en précisant le port à utiliser par le serveur *uvicorn*, et le port forwarding associé pour rendre le serveur accessible depuis l'extérieur. Il est important de prévoir ce paramétrage qui sera indispensable pour le déploiement dans *CloudRun* par la suite. Le processus dans docker n'ayant pas accès directement aux variables d'environnement à l'extérieur, nous les passons en paramètre.

```bash
docker run --env PORT=8000 --env REDISHOST=$REDISHOST --env REDISPORT=$REDISPORT --env REDISPASS=$REDISPASS -p 8000:8000 --rm fastapi
```

## Test du microservice

Le test de cette version dockerisée du microservice est strictement identique à celui de la version non dockerisée, c'est le but de ce tutoriel. 

```bash
for i in 1 2 3 4; do
  printf "\n%s: " "$i"
  curl http://localhost:8000/users/$i --request GET --header 'content-type: application/json'
done
curl --request PUT --url "http://localhost:8000/users/4" --header 'content-type: application/json' --data '{"name":"Francois Cerbelle","email":"francois@redis.com","age":48,"city":"Paris","height":179,"weight":84,"gender":"True"}'
xdg-open http://localhost:8000/docs
```


# Redis Enterprise managé DBaaS

La prochaine étape consiste à utiliser une véritable instance managée de Redis Enterprise dans le cloud, à partir de notre microservice dockerisé, qu'il soit sur notre poste de développement ou déployé dans CloudRun.

## Création d'une base Redis enterprise dans le cloud
Il faut commencer par créer un compte sur le portail https://app.redislabs.com et s'y connecter.

Il faut ensuite créer une souscription, correspondant à un cluster, en choissant un plan (Fixed correspond à des configuration partagées pré-établies, Flexible correspond à des configurations sur mesure et Annual correspond à des configurations sur mesure négociées). Dans notre cas, je choisi Flexible. 

![aef637fc931802fe63f6d0467742b6ee.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/aef637fc931802fe63f6d0467742b6ee.png" | relative_url }})

Puis, il faut sélectionner le fournisseur Cloud dans lequel nous allons créer le service Redis. Notre microservice devant être déployé sur Google CloudRun, autant que le services Redis s'y trouve également. De même, choisissons la région la plus adaptée, (europe-west1 en ce qui me concerne). Enfin, nous devons lui donner un nom, ça pourrait être «Prod», «PreProd», par exemple.

![b6153e1e8d79e27aab6baa4171c9dbf2.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/b6153e1e8d79e27aab6baa4171c9dbf2.png" | relative_url }})

Nous devons ensuite lister les bases Redis que cette souscription doit nous fournir, avec un nom, éventuellement un port réseau, les modules à activer (JSON et Search), le dimensionnement (volumétrie et débit), la haute-disponibilité ou non... 

![46d405e8080d200e1999cf8ca3365f63.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/46d405e8080d200e1999cf8ca3365f63.png" | relative_url }})

L'étape suivante permet de valider tous les détails avant de lancer la construction du service. Il est possible d'utiliser des crédits à travers les liens disponibles sur le site https://redis.com. 

![00a538dc37aa6627aa722c294d92749a.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/00a538dc37aa6627aa722c294d92749a.png" | relative_url }})

Le premier service va prendre environ 15 minutes à se déployer lors de sa création. 

![d044a257798350a2e4ae1f66276fd154.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/d044a257798350a2e4ae1f66276fd154.png" | relative_url }})

L'interface fournit des facilités pour se connecter à la base depuis l'intérieur (private) du fournisseur Cloud ou depuis l'extérieur (public), à l'aide d'exemples de code utilisant les bibliothèques clientes les plus communes, les outils en ligne de commande ou le client graphique *RedisInsight*

![6837ad596dcda035077b29503f4bf954.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/6837ad596dcda035077b29503f4bf954.png" | relative_url }})

## Mise à jour des informations de connexion

Nous pouvons désormais utiliser les nouvelles informations de connexion disponibles sur l'interface web Cloud (ou par appel d'API REST) pour mettre à jour les variables d'environnement utilisées par le microservice pour se connecter.

```bash
export REDISHOST=redis-16566.c29816.eu-west1-mz.gcp.cloud.rlcp.com
export REDISPORT=16566
export REDISPASS=
```

## Test hybride du microservice
```bash
docker run --env PORT=8000 --env REDISHOST=$REDISHOST --env REDISPORT=$REDISPORT --env REDISPASS=$REDISPASS -p 8000:8000 --rm fastapi
```

Le test est presque devenu un automatisme et se répète exactement à l'identique, quelle que soit la configuration et l'architecture.
```bash
for i in 1 2 3 4; do
  printf "\n%s: " "$i"
  curl http://localhost:8000/users/$i --request GET --header 'content-type: application/json'
done
curl --request PUT --url "http://localhost:8000/users/4" --header 'content-type: application/json' --data '{"name":"Francois Cerbelle","email":"francois@redis.com","age":48,"city":"Paris","height":179,"weight":84,"gender":"True"}'
xdg-open http://localhost:8000/docs
```

## Supervision Cloud

On peut constater sur la console de supervision Cloud que les trois clés initiales ont bien été créées lors du démarrage du microservice.

![1d395c46e0f4640dd79225467afcf690.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/1d395c46e0f4640dd79225467afcf690.png" | relative_url }})

Ces clés sont bien visibles et consultables depuis *RedisInsight* en local connecté à la base DBaaS dans le Cloud.

![7b665fa9fc040413ad312156eb03fca7.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/7b665fa9fc040413ad312156eb03fca7.png" | relative_url }})

# Déploiement Google CloudRun

Enfin, nous disposons d'un service Redis managé dans le cloud (identique à un Redis local sur le poste de travail, identique à un Redis communautaire) et d'une API flexible conteneurisée pouvant être exécutée n'importe où pour se connecter à Redis. La dernière étape consiste à déployer le conteneur du microservice, à le faire exécuter et à l'exposer dans Google CloudRun.

## Création du service

Bien que nous puissions créer une image docker et l'enregistrer dans le dépôt d'artefacts Google pour l'utiliser depuis un service CloudRun, dans mon cas, je vais pousser les sources de mon microservice vers Google pour que Google construise l'image docker tout seul la stocke dans l' «artefact repository» et l'utilise pour démarrer un nouveau service CloudRun.... J'ai uniquement besoin de fournir les paramètres de connexion à Redis et le port que je souhaite exposer.

```bash
gcloud run deploy --source . --allow-unauthenticated --port=8080 --service-account=319143195410-compute@developer.gserviceaccount.com --min-instances=1 --set-env-vars=REDISHOST=$REDISHOST,REDISPORT=$REDISPORT,REDISPASS=$REDISPASS --cpu-boost --region=europe-west1 --project=central-beach-194106
```

![63d06355771882c95d6a3ea3c173667f.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/63d06355771882c95d6a3ea3c173667f.png" | relative_url }})

On peut constater au bout de quelques dizaines de secondes que le service a bien été déployé à partir d'une image construite à la volée par Google.

![7820c653cec27efc7827e247f9cc312f.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/7820c653cec27efc7827e247f9cc312f.png" | relative_url }})

## Test final

On peut constater que l'interface Swagger est bien disponible sur l'url fournie par le service CloudRun.

![e9d4568c59bade96a1684bd232c9c8e8.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/e9d4568c59bade96a1684bd232c9c8e8.png" | relative_url }})

Les nouveau enregistrements se stockent bien dans la base Redis managée sur GCP.

![f8349a52a1e0ba9f7b33b9ebceac4277.png](../{{ "/assets/posts/fr/ManagedRedisForPythonMicroserviceInCloudRun/f8349a52a1e0ba9f7b33b9ebceac4277.png" | relative_url }})

# Supports et liens

- [Demo video][Video] [^1]

# Notes de bas de page

[Video]: https://youtu.be/QONgF2J7qUE "Demonstration video recording"
[^1]: [https://youtu.be/QONgF2J7qUE]


