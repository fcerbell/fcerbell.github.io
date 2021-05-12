---
uid: IotSensorSendingToRedis
title: Envoyer des valeurs dans Redis depuis un capteur IoT sur ESP8266
description:
category: Tutos
tags: [iot, embedded, esp8266, arduino, redis, home automation]
---

Créer un capteur de luminosité en utilisant un ESP8266 et une photoresistance
pour 5€, envoyer directement les mesures dans une base de données Redis via la
pile Wifi/TCP/IP et publier un message « push » pour notifier votre interface
utilisateur (décrite dans un futur article) qu'il y a une nouvelle valeur à
afficher en temps réel. Redis est une base clé-valeur en mémoire avec la
persistence sur le disque, la haute-disponibilité et la distribution des données
en cluster. Il est tellement facile à utiliser qu'un simple micro-controleur,
tel qu'un Arduino ou un ESP8266, avec une pile TCP/IP peut s'y connecter et
l'utiliser.

Vous pouvez trouver des liens vers les supports associés à la <a
href="#supports-et-liens">fin de cet article</a>.

* TOC
{:toc}

# Pré-requis

## Matériel

Je devais construire environ 200 de ces périphériques, au plus bas prix, dans un
délais aussi court que possible. L'idée était de les construire et d'enseigner
comment les utiliser avec Redis dans les meetups en France. Les participants
pouvaient conserver les périphériques après la rencontre pour continuer à jouer
avec à la maison.

Ils devaient être aussi peu cher que possible (j'ai atteint moins de 5€), aussi
faciles et rapides que possible à assembler (30 secondes de moins par
périphérique sont importantes quand on en fabrique 200), aussi polyvalents que
possibles pour y connecter d'autres capteurs (thermistances, capteurs
numériques, capteurs I2C, capteurs SPI, ...).

Tout d'abord, il faut un peu de matériel. Malgré le fait que je sois un adepte
d'Arduino, ils nécessiteraient une carte Wifi (chère) et de la soudure (long à
construire). J'ai choisi d'utiliser des petites plaques de prototypage, un
ESP8266 tout-en-un, une résistance et une photorésistance (LDR), qui peut
facilement être remplacée par une thermistance pour le même prix.

### Composants et outils

Parlons maintenant des fournitures :
![IoT1][iot-device-build-01.jpg]
[Pleine taille][iot-device-build-01.jpg]

Mes prix comportent une remise car j'en ai commandé 100 de chaque.

|-----+-------------------------------------+----------|------------|
| Qté | Composant                           | Prix (€) | Lien       |
|----:+:------------------------------------+---------:|:-----------|
|   1 | Plaque de prototypage 170 points    |     0.86 | [Banggood](https://www.banggood.com/Mini-Solderless-Prototype-Breadboard-170-Points-For-Arduino-Shield-p-74814.html) |
|   1 | ESP8266 ESP-12E/F sur PCB           |     3.18 | [Banggood](https://www.banggood.com/Geekcreit-Doit-NodeMcu-Lua-ESP8266-ESP-12E-WIFI-Development-Board-p-985891.html)|
|   1 | Résistance 10K Ohms (metal/carbone) |     0.03 | [Conrad](http://www.conrad.fr/ce/fr/product/1417697/Rsistance-couche-carbone-Yageo-CFR25J10KH-10-k-sortie-axiale-0207-025-W-1-pcs)|
|   1 | GL5528 LDR (Photorésistance)        |     0.02 | [Banggood](https://www.banggood.com/100Pcs-5MM-GL5528-Light-Dependent-Resistor-Photoresistor-LDR-p-943463.html)|
|   1 | Cable micro-USB                     |     1.10 | [Banggood](https://www.banggood.com/12cm-Universal-Micro-USB-2_0-Data-And-Charging-Cable-For-Raspberry-Pi-p-1079610.html)|
|=====+=====================================+==========+============|
|     | **Total**                           | **5.19** |            |
|-----+-------------------------------------+----------|------------|

* Pince fine
* Pince coupante

### Construction

Voici les étapes. Les liens permettent d'ouvrir les photos détaillées
intermédiaires.

* Commencer par utiliser la pince coupante pour raccourcir les pattes de la
  résistance.
[Résistance coupée][iot-device-build-02.jpg]

* Plier les pattes de la résistance pour traverser 9 trous (2.29 cm)
[Résistance pliée][iot-device-build-03.jpg]

* Placer la résistance entre C3 et L3sur la plaque.
[Place the resistor picture][iot-device-build-04.jpg]

* Raccourcir les pattes de la photorésistance à 2 cm chacune.
[Cut the LDR picture][iot-device-build-05.jpg]

* Plier les pattes de la photorésistance pour traverser 10 trous (2.54 cm).
[Fold the LDR picture][iot-device-build-06.jpg]

* Placer la photorésistance entre C1 et M1.
[Place the LDR picture][iot-device-build-07.jpg]

* Placer le PCB de l'ESP de façon à placer AD0 en C2 et 3.3V dans M2.
[Place the ESP picture][iot-device-build-08.jpg]

* Presser doucement et garder la photorésistance à l'extérieur !!! ;)
![Build completed][iot-device-build-09.jpg]
[Pleine taille][iot-device-build-09.jpg]

Félicitations !!! C'est terminé pour le matériel !

## Logiciel

### Interface de développement, compilateur croisé et téléversement

Nous allons avoir besoin d'un logiciel pour écrire notre code, l'interface de
développement (IDE), le logiciel pour compiler notre code dépendant à la fois du
couple ordinateur/système d'exploitation et du micro-controlleur visé, le
compilateur croisé, et du logiciel pour téléverser le code compilé dans le
périphérique.

Il existe plusieurs interface et chaînes de compilation disponibles pour
compiler du code C/C++ pour des micro-controlleurs. J'ai choisi d'utiliser l'IDE
très simple mais suffisante fournie par le projet [Arduino][Arduino]. Elle est
générique mais peut automatiquement télécharger la chaîne de compilation
nécessaire pour un micro-controlleur et compatible avec votre ordinateur, elle
peut également télécharger et inclure de nombreuses bibliothèques depuis des
dépôts sur internet.

Vous pouvez soit aller sur le site [Arduino][Arduino] pour télécharger
l'IDE[^1], soit cliquer sur les liens de téléchargement direct :

* [Linux 64bits][ArduinoIDE-Linux64]
* [Linux 32bits][ArduinoIDE-Linux32]
* [Windows][ArduinoIDE-Windows]
* [MacOS][ArduinoIDE-MacOS]

Extraire l'archive dans un répertoire, n'importe où dans votre système de
fichiers. l'interface sera exécutée depuis ce répertoire et tous vos fichiers
s'ytrouveront aussi. Le répertoire pourra être déplacé n'importe où, n'importe
quand.

### Bibliothèques, extraits de code et personnalisation de l'interface

L'interface peut être personnalisée pour devenir déplaçable et embarquer tout
dans un seul répertoire (l'interface elle-même, la configuration, la chaîne de
compilation pour les périphériques et votre code). Pour cela, nous devons
uniquement créer un sous-répertoire *portable* qui contiendra tout notre code,
toutes les bibliothèques et les fichiers de configuration (un peu comme un
répertoire personnel).

J'en ai préparé un et ai créé un fichier de configuration avec les dépôts
externes. Comme indiqué précédemment, la chaîne de compilation doit être
installes. Comme les binaires dépendent de votre ordinateur et de votre système
d'exploitation, je ne peux que préconfigurer le dépôt à partir duquel vous
devrez les télécharger et les installer par vous-même. Une bibliothèque de
connexion à Redis et un modèle de code sont également inclus dans le fichier de
configuration.

Le fichier ajoutera aussi le code source complet de cet article de blog.

* Télécharger l'[archive de personnalisation][PortableArchive]

* Extraire l'archive à la racine du répertoire d'installation de l'interface (ou
  dans le sous-répertoire *Contents/java* pour les utilisateurs de MacOS).

* Démarrer l'interface

* Aller dans le menu *Tools/Board/Board manager* (éventuellement Françisé)
![menu du gestionnaire de cartes][arduino-ide-boardsmanager-00.png]

* Chercher *ESP8266* (il devrait y en avoir un trouvé depuis les dépôts
  préconfigurés). le **Selectionner** dans la liste et l'installer.
![Menu du gestionnaire de cartes][arduino-ide-boardsmanager-01.png]

* Refermer la boîte de dialogue et sélectionner *NodeMCU 1.0 (ESP-12E Module)*
  dans le menu *Tools/Board* 
![Menu du gestionnaire de cartes][arduino-ide-boardsmanager-03.png]

C'en est terminé avec l'installation et la configuration de l'interface.

### Redis

Vous aurez besoin d'une base de données Redis, il peut s'agit de l'édition
communautaire ou de l'édition entreprise. Cet article de blog ne traitera pas de
l'implémentation du protocole des *sentinelles*, ni de celui du *cluster*,
nécessaire respectivement pour la haute-disponibilité et pour la répartition des
données dans l'édition communautaire. Ces deux protocoles ne sont pas
nécessaires ni pour la haute-disponibilité, ni pour la répartition dans
l'édition entreprise, ces fonctionnalités seront automatiquement activées dans
l'édition entreprise.

Étant donné que l'édition entreprise est vue comme une simple instance Redis par
les applications, indépendemment de l'activation de la répartition ou de la
réplication, et afin de garder cet article d'une taille raisonnable, je décrirai
l'installation et l'utilisation de l'édition communautaire, sans répartition et
sans réplication.

Pour éviter d'avoir besoin des droits d'administration, pour garder
l'installation de Redis déplaçable et pour maîtriser les versions utilisées, je
n'utiliserai pas les paquetages *redis-server* disponible dans la plupart des
distributions Linux, mais je vais télécharger, compiler, configurer et
exécuter la version de Redis disponible sur le [site officiel de Redis
communautaire][RedisIO].

Télécharger le code source depuis le lien suivant [Source Redis][RedisTGZ] et
l'extraire dans un répertoire. Ouvrir un terminal dans ce répertoire et saisir
`make`. Une fois la compilation terminée, exécuter Redis à partir du même
répertoire, en saisissant `./src/redis-server --protected-mode no` (la
protection limite les connexions entrantes à l'ordinateur local).

C'est terminé en ce qui concerne Redis. Epoustouflant, n'est-ce pas ? Seulement
quatre commandes (téléchargement, extraction, compilation et exécution) et vous
disposez d'une installation déplaçable démarrée.

## Application sur le micro-controlleur

Il est désormais temps de commencer à coder !

### Création d'une nouvelle application

Vous devriez avoir un squelette d'application dans votre interface
lorsque vous la démarrez. Il y a deux functions obligatoires : `void
setup()` et `void loop()`. Lorsque vous réinitialisez le périphérique
(que ce soit matériellement avec le bouton, depuis le port USB, en
l'alimentant ou par logiciel), il exécute le micro-programme de
démarrage (*bootloader*). Si des données sont présentes sur le port
série (ponté sur le connecteur USB), il les enregistre en mémoire
flash puis exécute le contenu de la mémoire flash. S'il n'y a pas de
données, il passe directement à l'exécution du programme en mémoire
flash.

À chaque cycle d'alimentation ou de réinitialisation, le programme
exécute la fonction `setup` une fois, puis itère sur la fonction
`loop` sans fin.

Donc, il faut initialiser la console série (pour le deboggage) et
ourir la connexion Wifi depuis la fonction `setup`. Ensuite, à chaque
itération de la fonction `loop`, il faut vérifier si l'on doit lire et
envoyer une valeur dans Redis. Si oui, il faut vérifier que nous disposons
d'une connexion TCP ouverte vers le serveur Redis, éventuellement en
ouvrir une et envoyer la valeur.

### Lecture de la mesure

Premièrement, initialiser le retour sur la console série et lire la
mesure du capteur.

Dans la fonction `setup`, initialiser la console série et attendre que
ce soit fait (uniquement utile pour certains modèles d'Arduino, tels
que le Yun, mais sans incidence pour les autres).

{% highlight c %}
void setup() {
  // Serial console initialization for debugging
  Serial.begin(115200);
//  Serial.setDebugOutput(true); // Wifi debugging
  while (!Serial);
  Serial.println("Serial initialized.");
}
{% endhighlight %}
In the `loop` function, print the sensor's value, from the
Analog-Ditial-Converter, to the serial console.


{% highlight c %}
void loop() {
    Serial.print("Sensor value (0-1024) : ");
    Serial.println(analogRead(0));
}
{% endhighlight %}

Tester le code avec l'icone *Vérifier* dans la barre d'outils, depuis
le menu *Sketch > Verify/Compile* ou avec le raccourcis clavier
*Ctrl+R*.

Si vous n'avez pas d'erreur, téléverser le binaire vers le
périphérique en utilisant l'icone *flèche*, le menu *Sketch > Upload*
ou le raccourcis clavier *Ctrl+U*. L'exécution commence dès le
téléversement terminé.

Ouvrir la console série à l'aide de l'icone *loupe* (à droite de la
barre d'outils), le menu *Tools > Serial Monitor* ou avec le
raccourcis clavier *Shift+Ctrl+M*. Ajuster la vitesse de communication
en fonction de celle définie dans le code (115200) et observer.

Vous pouvez constater la vitesse d'exécution de la fonction `loop`.
Même s'il serait possible d'introduire un appel à la fonction `void
delay(long ms)` dans la function `loop`, ce serait une mauvaise
pratique, la fonction `loop` a besoin de s'exécuter aussi rapidement
que possible, sans blocage, c'est la boucle principale de gestion des
événements. Il est préférable d'initialiser une variable retenant
l'heure de la dernière lecture à chaque affichage et de ne lire une
nouvelle valeur qu'après un certain délai.

{% highlight c %}
unsigned long lastSensorRead=0;
{% endhighlight %}

{% highlight c %}
void loop() {
  if ((millis() - lastSensorRead)>5000) {
    lastSensorRead = millis();
    Serial.print("Sensor value (0-1024) : ");
    Serial.println(analogRead(0));
  }
}
{% endhighlight %}

Compiler, téléverser et observer... C'est mieux, seulement une valeur
toutes les 5 secondes.

### Connexion au réseau Wifi

Commençons par la fonction `setup`. il faut définir le nom du réseau
Wifi et son mot de passe pour s'y connecter. Ajouter l'en-tête ESP,
définir les informations de connexion au Wifi et ajouter les lignes
suivantes dans la fonction `setup`. J'ai également inclus un
clignotement de la LED pendant la phase de connexion pour avoir un
retour d'état matériel, ainsi que des lignes de réinitialisation
commentées en cas de problème inexplicable.

{% highlight c %}
//  your network SSID (name)
#define WIFI_SSID "YourWifiNetwork"
#define WIFI_PASS "YourWifiNetworkPassword"

#include <ESP8266WiFi.h>

unsigned long lastSensorRead=0;

void setup() {
  // Serial console initialization for debugging
  Serial.begin(115200);
//  Serial.setDebugOutput(true); // Wifi debugging
  while (!Serial);
  Serial.println("Serial initialized.");

  // WIFI connection
//  ESP.eraseConfig();           // in case of need
//  ESP.reset();                 // in case of need
//  WiFi.softAPdisconnect(true); // in case of need
//  WiFi.disconnect(true);       // in case of need
  Serial.print("Connecting to ");
  Serial.print(WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  // Blink LED twice per second while waiting for connection
  pinMode(LED_BUILTIN, OUTPUT);
  while (WiFi.status() != WL_CONNECTED) {
    digitalWrite(LED_BUILTIN,HIGH);
    delay(250);
    digitalWrite(LED_BUILTIN,LOW);
    delay(250);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("WiFi (");
  Serial.print(WiFi.macAddress());
  Serial.print(") connected with IP ");
  Serial.println(WiFi.localIP());
  Serial.print("DNS0 : ");
  Serial.println(WiFi.dnsIP(0));
  Serial.print("DNS1 : ");
  Serial.println(WiFi.dnsIP(1));
}
{% endhighlight %}

Compiler, Téléverser et observer...

### Connexion TCP à Redis

Il est maintenant temps de vérifier si la connexion à Redis est
ouverte. Nous pouvons utiliser l'objet `WiFiClient`. Il peut ouvrir
une connexion vers une adresse IP ou un nom DNS et un numéro de port.
Il s'occupera de la résolution d'adresse DNS, mais aussi
éventuellement conserver cette résolution en cache (ce qui peut poser
problème si les DNS sont utilisés dans l'architecture pour la
haute-disponibilité). Le support de l'encryption SSL est limité dans
l'ESP, mais nous ne l'utiliserons pas dans cet article.

L'idée est de vérifier que nous disposons d'une connexion ouverte à
chaque lecture de la mesure. Si nous ne l'avons pas, nous l'ouvrons.

Définir la connexion Redis, ajouter un objet `WiFiClient` et modifier
la fonction `loop` :

{% highlight c %}
//  your network SSID (name)
#define WIFI_SSID "Freebox-AEA6A1"
#define WIFI_PASS "adherebit-commend96-sonatio#!-calidior26"

// Redis details
#define REDISHOST "redisdb.server.com"
#define REDISPORT 6379

#include <ESP8266WiFi.h>

unsigned long lastSensorRead=0;
WiFiClient redis;
unsigned long lastValue=0;

{% endhighlight %}

{% highlight c %}
void loop() {
  if ((millis() - lastSensorRead)>5000) {
    lastSensorRead = millis();
    lastValue = analogRead(0);
    Serial.print("Sensor value (0-1024) : ");
    Serial.println(lastValue);
    if (!redis.connected()) {
      Serial.print("Redis not connected, connecting...");
      if (!redis.connect(REDISHOST,REDISPORT)) {
        Serial.print  ("Redis connection failed...");
        Serial.println("Waiting for next read");
        return; 
      } else
        Serial.println("OK");
    }
}
{% endhighlight %}

### Envoi de commandes à Redis

Il est temps d'envoyer réellement des commandes à Redis pour insérer
les valeurs au début d'une list en utilisant `LPUSH`. La clé de la
liste est construite par concaténation de la chaîne « v: » et de
l'adresse MAC du périphérique.

Ajouter ce code immédiatement après le test de connexion.

{% highlight c %}
    // 10 is the base
    ltoa(lastValue,szValue,10);
    redis.print(
      String("*3\r\n")
      +"$5\r\n"+"LPUSH\r\n"
      +"$19\r\n"+"v:"+WiFi.macAddress().c_str()+"\r\n"
      +"$"+strlen(szValue)+"\r\n"+szValue+"\r\n"
    );
{% endhighlight %}

J'ai utilisé une `String` C++ pour rendre le code plus compact.

Redis envoie une réponse à chaque commande, y compris lorsqu'il se
produit une erreur. Ces réponses sont enregistrées dans des tampons du
périphérique. Lorsque tous les tampons sont pleins, le périphérique
ne peut plus émettre de nouvelle commande jusqu'à ce qu'un des tampons
se libère suite à une expiration (chaque seconde). Je pourrais
attendre la réponse de manière synchrone, mais ce serait une boucle
bloquante. Même si ce serait acceptable car Redis répond
habituellement très rapidement, ce serait également une mauvaise
pratique. J'ai choisi de tester la présence d'une éventuelle réponse à
chaque tour de boucle et de la consommer, juste avant la fin de la
fonction `loop`.

{% highlight c %}
  // If there is an answer from the Redis server available
  // Consume Redis server replies from the buffer and discard them
  while (redis.available() != 0)
    Serial.print((char)redis.read());
{% endhighlight %}

Compiler, téléverser et observer le résultat.

![Résultats dans la console Arduino][serial-monitor.png]
[Pleine taille][serial-monitor.png]

### Envoi de notification *Push* grâce à la commande PUBLISH

En tant qu'exercice, vous pouvez envoyer une autre commande à Redis en
utilisant le protocole [REdis Serialization Protocol][RESP] pour
notifier toutes les autres applications ayant souscrit (SUBSCRIBE) au
canal que votre périphérique vient de mettre la liste à jour. L'idée
est d'envoyer `PUBLISH chan:<MACAddr> <lastValue>`. Grâce à un tel
message, les autres applications n'auront même pas à récupérer la
mesure depuis la liste puisqu'elle sera transmise à l'intérieur même
du message.

Vous serez en mesure d'observer les résultats si vous ouvez une
connexion à Redis avec l'outil `src/redis-cli -h <IP> -p <PORT>` et si
vous saisissez `SUBSCRIBE chan:<MACAddr>`...

# Résolution de problèmes

Si votre ESP lance une moche trace de crash sur la console série, il
est possible de la comprendre en utilisant des `Serial.print`, mais
vous pouvez également installer le [greffon ESP Exception
decoder][EspExceptionDecoder] dans l'interface.

Si vous voulez regarder ce qui se passe dans votre serveur Redis, vous
pouvez le surveiller avec l'outil `src/redis-cli -h <IP> -p <PORT>` et
la commande `MONITOR`.
![Commande Monitor][redis-monitor.png]
[Pleine taille][redis-monitor.png]

# Améliorations

Vous pouvez connecter la LDR à une sortie numérique à la place du
3.3V. Il sera ainsi possible de l'alimenter uniquement au moment de
lire les mesures pour économiser de l'énergie.

Une autre solution est d'utiliser une résistance interne de tirage
pour retirer celle externe et de connecter la LDR directement entre
AD0 et GND. Les valeurs seront inversées mais vous économiserez 0.02€.
Ensuite, il sera possible de couper la résistance de tirage interne
entre deux lectures pour économiser de l'énergie.

Vous pouvez utiliser les commandes de mise en veille du
micro-controlleur pour l'endormir entre deux mesures, pour économiser
de l'energie. C'est un peu plus complex, mais peut faire chuter le
courant consmmé à quelques µA la plupart du temps !!! Pratique pour
les périphériques sur batterie difficile d'accès pour la maintenance.

Si vous souhaitez avoir de la haute-disponibilité, vous pouvez soit
implémenter le protocol des `sentinelles` Redis, soit une partie du
protocole du `cluster` Redis, soit utiliser un proxy tel que celui
fourni dans l'édition entreprise.

En ajoutant une encryption SSL entre le périphérique et le serveur,
vous pourrez utiliser une authentification par mot de passe (command
`AUTH`) pour améliorer le niveau de sécurité des accès à votre base de
données.

Vous pouvez implémenter une bibliothèque pour encoder plus facilement
les commandes Redis dans le protocol [REdis Serialization
Protocol][RESP] et une seconde pour gérer la connexion avec Redis
(expirations, pertes de connexion, pipelining).

# Supports et liens

| Lien | Description |
|---|---|
| [Full source][Sketch] | Code source complet isans la notification |
| [06/09/2017: Meetup Redis IOT à Tel Aviv, Israël][MeetupTLV] | chez [RedisLabs Tel Aviv][RedisLabsTLV] |
| [10/10/2017: Meetup Redis IOT à Paris, France][MeetupParis] | chez [SOAT] |
| [17/10/2017: Meetup Redis IOT à Toulouse, France][MeetupToulouse] | chez [Étincelle coworking Toulouse][EtincelleTLS] |
| [07/11/2017: Meetup Redis IOT à Lille, France][MeetupLille] | chez [Zenika Lille][ZenikaLille] |
| [14/11/2017: Meetup Redis IOT à Bordeaux, France][MeetupBordeaux] | chez [Le Wagon Bordeaux][LeWagonBDX] |
| [21/11/2017: Meetup Redis IOT à Lyon, France][MeetupLyon] | chez [La cordée coworking][LaCordee] |
| [Redis France][MeetupFrance] | Groupe meetup sur Redis en France |

# Notes de bas de page

[MeetupParis]: https://www.meetup.com/fr-FR/Paris-Redis-Meetup/events/242249391/ "Meetup sur le sujet à Paris, France"
[MeetupLille]: https://www.meetup.com/fr-FR/Redis-Lille/events/242029096/ "Meetup sur le sujet à Lille, France"
[MeetupToulouse]: https://www.meetup.com/fr-FR/Redis-Toulouse/events/242029119/ "Meetup sur le sujet à Toulouse, France"
[MeetupBordeaux]: https://www.meetup.com/fr-FR/Redis-Bordeaux/events/242029157/ "Meetup sur le sujet à Bordeaux, France"
[MeetupLyon]: https://www.meetup.com/fr-FR/Redis-Lyon/events/242029145/ "Meetup sur le sujet à Lyon, France"
[MeetupFrance]: https://www.meetup.com/fr-FR/Redis-France/ "Meetup sur Redis en France"
[MeetupTLV]: https://www.meetup.com/fr-FR/Tel-Aviv-Redis-Meetup/events/242587656/ "Meetup sur le sujet à Tel Aviv, Israël"
[SOAT]: http://www.soat.fr "Site officiel de SOAT"
[ZenikaLille]: https://zenika.com "Site officiel de Zenika"
[EtincelleTLS]: http://www.coworking-toulouse.com/ "Site officiel d'Étincelle coworking à Toulouse"
[LeWagonBDX]: https://www.lewagon.com/fr/bordeaux "Site officiel du Wagon à Bordeaux"
[LaCordee]: https://www.la-cordee.net/ "Site officiel de la Cordée"
[RedisLabsTLV]: http://www.redislabs.com/ "Site officiel de RedisLabs"
[iot-device-build-01.jpg]: {{ "/assets/posts/" | append: page.uid | append:"/iot-device-build-01.jpg" | relative_url }} "IoT device build : Furnitures"
[iot-device-build-02.jpg]: {{ "/assets/posts/" | append: page.uid | append:"/iot-device-build-02.jpg" | relative_url }} "IoT device build : Cut the resistor"
[iot-device-build-03.jpg]: {{ "/assets/posts/" | append: page.uid | append:"/iot-device-build-03.jpg" | relative_url }} "IoT device build : Fold the resistor"
[iot-device-build-04.jpg]: {{ "/assets/posts/" | append: page.uid | append:"/iot-device-build-04.jpg" | relative_url }} "IoT device build : Place the resistor"
[iot-device-build-05.jpg]: {{ "/assets/posts/" | append: page.uid | append:"/iot-device-build-05.jpg" | relative_url }} "IoT device build : Cut the LDR"
[iot-device-build-06.jpg]: {{ "/assets/posts/" | append: page.uid | append:"/iot-device-build-06.jpg" | relative_url }} "IoT device build : Fold the LDR"
[iot-device-build-07.jpg]: {{ "/assets/posts/" | append: page.uid | append:"/iot-device-build-07.jpg" | relative_url }} "IoT device build : Place the LDR"
[iot-device-build-08.jpg]: {{ "/assets/posts/" | append: page.uid | append:"/iot-device-build-08.jpg" | relative_url }} "IoT device build : Place the ESP"
[iot-device-build-09.jpg]: {{ "/assets/posts/" | append: page.uid | append:"/iot-device-build-09.jpg" | relative_url }} "IoT device build : Completed"
[arduino-ide-boardsmanager-00.png]: {{ "/assets/posts/" | append: page.uid | append:"/arduino-ide-boardsmanager-00.png" | relative_url }} "Arduino IDE : 00"
[arduino-ide-boardsmanager-01.png]: {{ "/assets/posts/" | append: page.uid | append:"/arduino-ide-boardsmanager-01.png" | relative_url }} "Arduino IDE : 01"
[arduino-ide-boardsmanager-02.png]: {{ "/assets/posts/" | append: page.uid | append:"/arduino-ide-boardsmanager-02.png" | relative_url }} "Arduino IDE : 02"
[arduino-ide-boardsmanager-03.png]: {{ "/assets/posts/" | append: page.uid | append:"/arduino-ide-boardsmanager-03.png" | relative_url }} "Arduino IDE : 03"
[serial-monitor.png]: {{ "/assets/posts/" | append: page.uid | append:"/serial-monitor.png" | relative_url }} "Results in the serial monitor"
[redis-monitor.png]: {{ "/assets/posts/" | append: page.uid | append:"/redis-monitor.png" | relative_url }} "Results in the redis monitor"
[Arduino]: https://www.arduino.cc/ "Arduino official website"
[ArduinoIDE-Linux64]: https://downloads.arduino.cc/arduino-1.8.3-linux64.tar.xz "Direct download link to Arduino IDE 1.8.3 for Linux 64bits"
[ArduinoIDE-Linux32]: https://downloads.arduino.cc/arduino-1.8.3-linux32.tar.xz "Direct download link to Arduino IDE 1.8.3 for Linux 32bits"
[ArduinoIDE-Windows]: https://downloads.arduino.cc/arduino-1.8.3-windows.zip "Direct download link to Arduino IDE 1.8.3 for Windows"
[ArduinoIDE-MacOS]: https://downloads.arduino.cc/arduino-1.8.3-macosx.zip "Direct download link to Arduino IDE 1.8.3 for MacOSX"
[PortableArchive]: {{ "/assets/posts/" | append: page.uid | append:"/portable.zip" | relative_url }} "IDE customization file"
[Sketch]: {{ "/assets/posts/" | append: page.uid | append:"/sketch.zip" | relative_url }} "Result Sketch archive"
[RedisIO]: https://redis.io "Official Redis Open-Source community website"
[RedisTGZ]: http://download.redis.io/releases/redis-4.0.1.tar.gz "Redis 4.0.1 source code"
[EspExceptionDecoder]: https://github.com/me-no-dev/EspExceptionDecoder "Arduino IDE ESP stack dump decoder"
[RESP]: https://redis.io/topics/protocol "REdis Serialization Protocol"

[^1]: Utilisateurs de Windows : Choisir le fichier ZIP, pas
l'installeur MSI ou l'application du *store*. Nous voulons créer une
installation portable sans requerir les droits d'administration, avec
tous les fichiers dans un seul et unique dossier pouvant être déplacé.
