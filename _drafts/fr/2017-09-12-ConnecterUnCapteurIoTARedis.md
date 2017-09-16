---
uid: IotSensorSendingToRedis
title: Envoyer des valeurs dans Redis depuis un capteur IoT sur ESP8266
author: fcerbell
layout: post
lang: fr
#description:
category: Tutos
tags: [iot, embedded, esp8266, arduino, redis, home automation]
#date: 9999-01-01
#published: true
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

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/" frameborder="0" allowfullscreen></iframe></center>

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
connection à Redis et un modèle de code sont également inclus dans le fichier de
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

You should have an empty application skeleton in your IDE when you start it.
Basically, there are two mandatory functions : `void setup()` and `void loop()`.
When you reset it (either hard reset with the button or from the USB connection,
or soft reset from the application), it executes the Arduino *bootloader*. if
data is available on the serial link (bridged with the USB), it stores the data
in the flash memory and execute the program from flash. If there is no data, the
bootloader directly executes the program from flash memory. 

At each power cycle or reset, the program executes once the `setup` function and
then loops on the `loop` one.

So, you need to initialize the serial console (for debugging) and open a Wifi
connection from the `setup` function. Then, at each loop iteration, you will
check if you need to send the sensor's value to Redis, if yes, you will check
that you have an active connection to Redis and open it if needed, and you'll
send your data.

### Check sensors values

First, initialize the feedback with the serial console and read the sensor's
values.

In the `setup` function, initialize the serial console, wait for its
initialization.

``` c
void setup() {
  // Serial console initialization for debugging
  Serial.begin(115200);
//  Serial.setDebugOutput(true); // Wifi debugging
  while (!Serial);
  Serial.println("Serial initialized.");
}
```
In the `loop` function, print the sensor's value, from the
Analog-Ditial-Converter, to the serial console.


``` c
void loop() {
    Serial.print("Sensor value (0-1024) : ");
    Serial.println(analogRead(0));
}
```

Test your sketch with the *tick* icon in the toolbar, or from the menu *Sketch >
Verify/Compile* or with the keyboard shortcut *Ctrl+R*. 

If you have no error, upload it to the device using the *arrow* icon, the menu
*Sketch > Upload* or the shortcut *Ctrl+U*. As soon as it is uploaded, it is
executed.

Start the serial monitor with the right *magnification glass* icon, from the
menu *Tools > Serial Monitor* or with the keyboard shortcut *Ctrl+Shift+M*.
Choose the same baud rate as in the sketch (115200) and observe.

You can see the speed of the loop function. Despite you could introduce a
`void delay(long ms)` call in the loop, it would be a bad practice, the loop
function needs to be executed as fast as possible, without blocking. It is
better to initialize a millisecond timestamp at each print and to only send a
new value after a timeout :

``` c
//  your network SSID (name)
#define WIFI_SSID "YourWifiNetwork"
#define WIFI_PASS "YourWifiNetworkPassword"

#include <ESP8266WiFi.h>

unsigned long lastSensorRead=0;
```

``` c
void loop() {
  if ((millis() - lastSensorRead)>5000) {
    lastSensorRead = millis();
    Serial.print("Sensor value (0-1024) : ");
    Serial.println(analogRead(0));
  }
}
```

Compile, upload and observe... It is better, one value every 5 seconds.

### WIFI network connection

Lets begin with the `setup` function. You need at least a Wifi network name and
password to connect to. Add the ESP simple Wifi header, define your Wifi
credentials and add the following at the end of the `setup` function. I also
included a LED blinking during the WIFI connection.

``` c
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
```

Compile, upload and watch. 

### TCP Redis connection
Now, it is time to check that you have an opened Redis connection. For that, we
use a `WiFiClient` object. It can open a TCP connection to an IP or an hostname
and a port number. It will take care of the DNS resolution, but might keep the
IP in cache. The SSL support is quite limited in the ESP, but we wont use it in
this post.

The idea is to check that we have an opened redis connection at each sensor
read, if not we open it.

Define your Redis connection, add a `WiFiClient` object and change your `loop`
function :

``` c
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

```

``` c
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
```

### Redis commands

Now, it is time to actually send commands to Redis to send the value at the
begining of a Redis list using `LPUSH`. The list is named from the device's MAC
address prefixed by "v:".

Add this code immediately after the connection test.

``` c
    // 10 is the base
    ltoa(lastValue,szValue,10);
    redis.print(
      String("*3\r\n")
      +"$5\r\n"+"LPUSH\r\n"
      +"$19\r\n"+"v:"+WiFi.macAddress().c_str()+"\r\n"
      +"$"+strlen(szValue)+"\r\n"+szValue+"\r\n"
    );
```

I used a C++ `String` to make the code shorter. 

Redis server send back a reply to every Redis command, even when there is an
error. These replies are stored in buffers on the device. When all the buffer
are full, the device can not send new commands anymore, until one of the buffer
expires and become available (every second). Thus, I could wait synchroneously
for the reply, but it would be a busy loop, even if it is usually fine because
Redis server replies very fast, it is a bad practice. I chose to test for a
reply at each loop iteration and to consume it. Just before the end of the
`loop`.

``` c
  // If there is an answer from the Redis server available
  // Consume Redis server replies from the buffer and discard them
  while (redis.available() != 0)
    Serial.print((char)redis.read());
```

Compile, upload and observe

![Result in Arduino console][serial-monitor.png]
[Pleine taille][serial-monitor.png]

### Push notification with a PUBLISH

As an exercice, you can send another command using the [REdis Serialization Protocol][RESP] protocol to Redis, so that it will notify all listening
(SUBSCRIBEd) application that you updated your value list. The idea is to send
`PUBLISH chan:<MACAddr> <lastValue>`. With such a message, the other application
won't have to get the value from the list, as the value is already part of the
message.

You will be able to observe the results if you connect to your Redis server with
the `src/redis-cli -h <IP> -p <PORT>` tool and if you type `SUBSCRIBE
chan:<MACAddr>`...

# Troubleshooting

If your ESP throw an ugly stack strace on your serial console, you can debug
using a lot of `Serial.print`, but you can also install [The ESP Exception
decoder plugin][EspExceptionDecoder] in the IDE.

If you want to see what happens on your Redis server, you can monitor it using
the `src/redis-cli -h <IP> -p <PORT>` tool and typing `MONITOR`.
![Result in Redis monitor][redis-monitor.png]
[Pleine taille][redis-monitor.png]

# Improvements

You can connect the LDR to a digital pin instead of 3.3V. So, you can choose to
give power only when you read the value, to save energy.

Another solution is to use the internal pull-up resistor to remove the external
pull-down one and connect the LDR between AD0 and GND. The values will be
inverted, but you save 0.02€. Then, you can disable the pull-up resistor between
readings to save energy.

You can also use sleep commands to put your device in sleep mode between
reading/sending values, to save energy. This is more complex, but can lower down
the current to few µA most of the time !!! Useful for battery powered devices
that should last a long time without maintenance.

If you want high-availability, either you need to implement parts of the
sentinel protocol, or parts of the cluster protocol or to use a proxi such as
the one provided in the enterprise edition.

Add SSL between the device and Redis server, then, you can also use the `AUTH`
redis command to add some security to your database.

You can implement a library to encode commands in the [REdis Serialization
Protocol][RESP] and another one to manage the redis connection, with pipelining.

# Supports et liens

| Lien | Description |
|---|---|
| [Full source][Sketch] | Full source code without the publish |
| [Video] | Enregistrement vidéo de la démonstration |
| [06/09/2017: Meetup Redis IOT à Tel Aviv, Israël][MeetupTLV] | chez [RedisLabs Tel Aviv][RedisLabsTLV] |
| [10/10/2017: Meetup Redis IOT à Paris, France][MeetupParis] | chez [SOAT] |
| [17/10/2017: Meetup Redis IOT à Toulouse, France][MeetupToulouse] | chez [Étincelle coworking Toulouse][EtincelleTLS] |
| [07/11/2017: Meetup Redis IOT à Lille, France][MeetupLille] | chez [Zenika Lille][ZenikaLille] |
| [14/11/2017: Meetup Redis IOT à Bordeaux, France][MeetupBordeaux] | chez [Le Wagon Bordeaux][LeWagonBDX] |
| [21/11/2017: Meetup Redis IOT à Lyon, France][MeetupLyon] | chez [La cordée coworking][LaCordee] |
| [Redis France][MeetupFrance] | Groupe meetup sur Redis en France |

# Notes de bas de page

[Video]: https://youtu.be/kK4GxAwJKD0 "Enregistrement vidéo de la démonstration"
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
[iot-device-build-01.jpg]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/iot-device-build-01.jpg "IoT device build : Furnitures"
[iot-device-build-02.jpg]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/iot-device-build-02.jpg "IoT device build : Cut the resistor"
[iot-device-build-03.jpg]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/iot-device-build-03.jpg "IoT device build : Fold the resistor"
[iot-device-build-04.jpg]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/iot-device-build-04.jpg "IoT device build : Place the resistor"
[iot-device-build-05.jpg]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/iot-device-build-05.jpg "IoT device build : Cut the LDR"
[iot-device-build-06.jpg]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/iot-device-build-06.jpg "IoT device build : Fold the LDR"
[iot-device-build-07.jpg]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/iot-device-build-07.jpg "IoT device build : Place the LDR"
[iot-device-build-08.jpg]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/iot-device-build-08.jpg "IoT device build : Place the ESP"
[iot-device-build-09.jpg]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/iot-device-build-09.jpg "IoT device build : Completed"
[arduino-ide-boardsmanager-00.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/arduino-ide-boardsmanager-00.png "Arduino IDE : 00"
[arduino-ide-boardsmanager-01.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/arduino-ide-boardsmanager-01.png "Arduino IDE : 01"
[arduino-ide-boardsmanager-02.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/arduino-ide-boardsmanager-02.png "Arduino IDE : 02"
[arduino-ide-boardsmanager-03.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/arduino-ide-boardsmanager-03.png "Arduino IDE : 03"
[serial-monitor.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/serial-monitor.png "Results in the serial monitor"
[redis-monitor.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/redis-monitor.png "Results in the redis monitor"
[Arduino]: https://www.arduino.cc/ "Arduino official website"
[ArduinoIDE-Linux64]: https://downloads.arduino.cc/arduino-1.8.3-linux64.tar.xz "Direct download link to Arduino IDE 1.8.3 for Linux 64bits"
[ArduinoIDE-Linux32]: https://downloads.arduino.cc/arduino-1.8.3-linux32.tar.xz "Direct download link to Arduino IDE 1.8.3 for Linux 32bits"
[ArduinoIDE-Windows]: https://downloads.arduino.cc/arduino-1.8.3-windows.zip "Direct download link to Arduino IDE 1.8.3 for Windows"
[ArduinoIDE-MacOS]: https://downloads.arduino.cc/arduino-1.8.3-macosx.zip "Direct download link to Arduino IDE 1.8.3 for MacOSX"
[PortableArchive]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/portable.zip "IDE customization file"
[Sketch]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/sketch.zip "Result Sketch archive"
[RedisIO]: https://redis.io "Official Redis Open-Source community website"
[RedisTGZ]: http://download.redis.io/releases/redis-4.0.1.tar.gz "Redis 4.0.1 source code"
[EspExceptionDecoder]: https://github.com/me-no-dev/EspExceptionDecoder "Arduino IDE ESP stack dump decoder"
[RESP]: https://redis.io/topics/protocol "REdis Serialization Protocol"

[^1]: Windows users : choose the ZIP file, not the installer nor the app from the store. We want to create a portable install without admin permissions, with everything in one singe folder that can be moved.

