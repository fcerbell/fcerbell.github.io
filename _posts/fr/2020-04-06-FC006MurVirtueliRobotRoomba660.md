---
uid: irobotroomba660virtualwall
title: FC006 - Mur virtuel pour iRobot Roomba
description:
category: Electronic
tags: [ iRobot, Roomba, Infra-red, attiny85, avr ]
mathjax: true
---

iRobot vend des robot autonomes aspirateurs *Roomba*. Ils disposent de
recepteurs IR pour détecter les obstacles et pour reçevoir des commandes d'une
télécommande. iRobot vend un *mur virtuel* à 40€ pour créer une frontière et
contraindre le robot dans une partie de la pièce à nettoyer. Les composants
coûtent moins de 10€ ! J'ai décidé de créer le mien, basé sur un microcontroleur
AVR ATTiny.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

* TOC
{:toc}

# Vidéo

<center><iframe width="420" height="315"
src="https://www.youtube.com/embed/2QJ_tI8vHBU" frameborder="0"
allowfullscreen></iframe></center>

# Matériel

J'ai repris le schéma de [Petezah's
repository](https://github.com/Petezah/roomba_wall_v2). J'ai retiré le
résonateur externe pour économiser de l'énergie car je n'ai pas besoin d'une
grande précision d'horloge et j'ai mmodifié la liste des composants.

![e9b62e4d6ca94ea011baddec0d672755.png]

J'utilise un interrupteur classique pour alimenter le mur, ainsi je peux
l'arrêter complètement et économiser l'énergie.

Un ATTiny13 aurait pu être un bon candidat mais sa quantité de mémoire Flash
aurait nécessité des optimisations de code. J'ai choisi un ATTiny85 malgré son
surdimensionnement, car j'en ai acheté 5 (je peux en griller un lors du
développement et des tests) et il est suffisament versatile pour être réutilisé
dans d'autres projets. J'ai choisi le "ATTiny85V" car "V" signifie qu'il peut
continuer à fonctionner avec des voltages bas, jusqu'à 1.8V (et fonctionnera
plus longtemps lorsque la batterie est faible et sans élévateur de tension) ; la
version 10 Mhz car mon fournisseur n'avait que celle-la en stock et que ce
projet fonctionnera à 1Mhz pour économiser de l'énergie et diminuer la tension
minimale.

## Nomenclature

| Composant | Qté | Coût |
|---|---:|---:|
| ATTINY85V-10PU | 1 | 1,38 € |
| DEL IR 5mm, 940nm, 10°, 100mA | 1 | 0,35 € |
| DEL Rouge 5mm | 1 | 0,07 € |
| Socle DIP8 | 1 | 0,15 € |
| Transistor 2N2222A | 1 | 0,19 € |
| Résistance 560 Ohms | 2 | |
| Résistance 24 Ohms | 1 | |
| LiPo 1S 3.7V 850mAh | 1 | 5.52 € |
| Carte de charge micro USB et protection LiPo TP4056 TE585 | 1 | 1.27 € |

Alternative A : avec des piles AA 

| Composant | Qté | Coût |
|---|---:|---:|
| Support piles 2X 1.5V AA | 1 | 3.61 € |

Alternative B : avec une pile 3V CR123A

J'ai choisi d'utiliser une batterie LiPo 1S/850mAh avec une carte de chargement
car j'en avais en stock. Donc, le boitier et le code source (les seuils de
tension) sont adapté pour cette configuration.

# Logiciel

## Compilateur ATtiny pour Arduino

Les référentiels par défaut de l'IDE Arduino ne comportent pas la carte
"ATTiny". J'ai donc du ajouter le référentiel suivant dans la boîte
*Édition/Préférences* :

```
http://drazzy.com/package_drazzy.com_index.json
```

![1380a757a5d48aea3045c8a6bcd074ce.png]

Ensuite, j'ai pu ajouter le `ATTinyCore` de *Spence Konde* dans le gestionnaire
de cartes. Ce cœur peut configurer les fusibles pour changer la fréquence et
les autres réglages.

![fdce2d0d0490d3a4051874a1018bd841.png]

J'ai utilisé un programmateur USBasp et l'ai connecté aux broches ICSP (SPI) de
l'ATTiny. J'ai sélectionné le choix correspondant dans le menu
*Outils/Programmateur*. Je peux donc graver un bootloader, programmer les
fusibles et téleverser les programmes.

J'ai effectué les réglages suivants dans le menu *Outil* :

- Board : ATTiny25/45/85
- Chip : ATTiny85
- Clock : 1 Mhz (internal)
- BOD Level : BOD disabled
- Save EEPROM : EEPROM retained
- Timer 1 clock : CPU
- LTO : Enabled
- millis : Enabled

Le BOD est désactivé car je ne m'inquiète pas d'une tension trop basse qui
crasherait le périphérique. J'ai également désactivé le BOD dans le code source
mais, s'il n'est pas désactivé par les fusibles, le MCU va le réinitialiser à
chaque sortie de sommeil, consommant de l'énergie et du temps. J'aurais aussi pu
désactiver la fonction `millis` pour économiser de l'espace dans la mémoire,
mais mon code compilé ne dépasse jamais 15% de l'espace Flash disponible.

**L'horloge doit impérativement être configurée sur une source *interne* sans
quoi vous aller briquer votre MCU**

Ces réglages peuvent désormais être programmés dans les fusibles en utilisant le
menu *Outils/Burn bootloader*. Mais je n'ai pas besoin de le faire car ils
seront automatiquement mis à jour à chaque fois que je téléverserai mon
programme dans le MCU en utilisant l'USBasp avec le paquet ATTinyCore de Spence.

## Protocole de transmission

Chaque commande Roomba est un octet de 8bits. Chaque bit est encodé avec le
motif suivant, en utilisant une porteuse de 38kHz.

- 1 = 3ms actif suivi de 1ms inactif
- 0 = 1ms actif suivi de 3ms inactif

Chaque commande nécessite d'être envoyée trois fois avec une pause de 100 ms
entre chaque répétition et 150 ms après la dernière. Ainsi, l'envoi d'une
commande dure environ 
$$3 * ( 32ms + 100 ms) + 50 ms = 450 ms$$

![aad6704814837057484eb1d66efe564c.png]
Sortie PB0/Pin6 en jaune, signal reçu par un VS1838 en violet

## Programmation du Timer0

J'ai utilisé une programmation bas-niveau pour générer une modulation PWM de
38kHz à 50% à partir du timer 0. Cette porteuse encodera le signal en la
connectant/déconnectant à la broche PB0 de l'ATTiny85 (broche 6). J'ai du
désactiver les interruptions générées par le timer car les bibliothèques Arduino
y ont attaché des routines qui consomment du temps et de l'énergie (pour gérer
les fonctions delay et milli) et surtout car ces interruption réveilleraient le
MCU trop tôt pendant les cycles de sommeil.

``` c
// PWM Carrier
// FastPWM-Compare mode, no prescale (to support 1MHz internal clock)
// Disable interruptions (Arduino libs have ISR for delay and millis)
#define PWM_SETUP(val) ({ \
    const uint8_t pwmval = SYSCLOCK / val / 1000; \
    TCCR0A = 1<<WGM00 | 1<<WGM01; \
    TCCR0B = 1<<WGM02 | 1<<CS00; \
    TIMSK &= 0b10000001; \
    OCR0A  = pwmval;\
    OCR0B  = pwmval/2; \
  })
#define PWM_ON  ({TCNT0=0; TCCR0A |= _BV(COM0B1);})
#define PWM_OFF (TCCR0A &= ~(_BV(COM0B1)))
```

## Temporisation et délais

Le timer 0 est utilisé par la fonction `delay`, cette fonction n'est donc plus
utilisable car j'ai modifié la fréquence. J'ai réutilisé l'approche du projet
*TV B Gone* : une boucle active sur des instructions NOP, calibrée sur la
fréquence interne de mon ATTiny85 (1Mhz) à l'oscilloscope.

``` c
// Busy loop to manage very small delays (<16ms) that
// can not be managed by wdtSleep timer
// Inspired by TV B Gone project
// TODO: use Timer0 (38kHz), SLEEP_MODE_IDLE and interrupt
//       if not too long for PWM signal generation
#define DELAY_CNT SYSCLOCK/1000000
#define NOP __asm__ __volatile__ ("nop")

void delay_ten_us(unsigned long us) {
  uint8_t timer;
  while (us != 0) {
    for (timer = 0; timer <= DELAY_CNT; timer++) {
      NOP;
      NOP;
    }
    us--;
  }
}

void custom_delay_usec(unsigned long uSecs) {
  delay_ten_us(uSecs / 10);
}
```

## Pauses longues et économie d'énergie

Pour toutes les pauses de 100 et 150 ms, j'aurais pu utiliser une boucle active,
mais cela aurait consommé beaucoup de courant. Je place le périphérique dans son
mode de sommeil le plus profond : `SLEEP_MODE_PWR_DOWN`. Dans ce mode, seule une
interruption matérielle ou déclenchée par le watchdog peut le réveiller.

Le watchdog peut être configuré avec des durée de $2^n*16 ms$, ($0<=n<=9$), donc
pas moins de 16ms et pas plus de 8s. J'ai fait une boucle pour enchaîner
plusieurs cycles de sommeil avec des durées adaptées pour arriver le plus près
possible de la durée demandée. J'ai du le programmer bas-niveau pour désactiver
la fonction *réinitialisation* et ne conserver que la fonction *interruption*.

J'aurais pu ne pas désactiver le BOD car il est supposé étre déjà désactivé par
les fusibles. De plus, je désactive toutes les interruption tout le temps et je
ne les réactive qu'au moment de passer en mode sommeil ; je ne souhaite pas
dormir pour l'éternité. J'ai donc écrit le code pour ne pas utiliser
d'interruptions pas de bouton poussoir, pas de `delay`, pas de `millis`, rien)
et j'ai pu les désactiver toutes la plupart du temps (hors sommeil) pour
conserver ma synchronisation temporelle sous contrôle.

Je désactive également le Timer0, car il n'y a pas besoin de générer une
porteuse 38kHz pendant le sommeil et que cela consommerait du courant. Tout le
reste est déjà aussi désactivé (ADC, Timer1).

``` c
// watchdog interrupt
ISR (WDT_vect) {
  wdt_disable();
}

void wdtSleep (unsigned int ms) {
  power_timer0_disable();
  set_sleep_mode (SLEEP_MODE_PWR_DOWN);
  ms = ms / 16;
  // 0: 16 ms, 1: 32 ms, 2: 64 ms, 3: 128 ms, 4: 256 ms,
  // 5: 512 ms, 6: 1024 ms, 7: 2048 ms, 8: 4096 ms, 9: 8192 ms,
  unsigned char wdp = 0;

  while ((ms) && (wdp <= 9)) {
    if (ms & 1) {
      MCUSR = 0;                              // clear various "reset" flags
      //      noInterrupts();                         // Timed sequence follow
      WDTCR = (1 << WDCE | 1 << WDE);         // watchdog change enable
      WDTCR |= (1 << WDIE | 0 << WDE | wdp) ; // enable wdt interrupt
      //      interrupts();      // End of timed sequence

      // turn off brown‐out enable in software
      MCUCR = bit (BODS) | bit (BODSE);
      MCUCR = bit (BODS);

      wdt_reset();
      interrupts();      // waiting for watchdog interrupt to wakeup
      sleep_mode ();
      noInterrupts();    // no need for interruptions in this sketch
      sleep_disable();
    }
    ms = ms >> 1;
    wdp = wdp + 1;
  }
  power_timer0_enable();
}
```

## DEL d'activité et d'état de la batterie

J'ai fait clignoter la DEL d'activité rapidement une fois toutes les 15
secondes environ, deux fois lorsque la tension de la batterie tombe sous le
premier seuil et trois fois lorsqu'elle franchit le second seuil. Les seuils
dépendent du type de batterie, de la version de l'ATTiny (V ou pas V) et de la
fréquence du MCU.

- piles (2xAA, CR123A, CR2032) : 2V/1.8V pour un ATTiny85
- LiPo avec BMS (coupant à 2.5V) : 3V/2.8V 

Pour cela, j'ai réutilisé la fonction `ReadVcc` du projet
[MySensors][MySensors][^3]. J'ai uniquement ajouté une activation du circuit ADC
au début et une désactivation à la fin, ainsi, l'ADC ne consomme du courant
qu'au cours des mesures.

``` c
long readVcc() {
  power_adc_enable();
  // Read 1.1V reference against AVcc
  // set the reference to Vcc and the measurement to the internal 1.1V reference
#if defined(__AVR_ATmega32U4__) || defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
  ADMUX = _BV(REFS0) | _BV(MUX4) | _BV(MUX3) | _BV(MUX2) | _BV(MUX1);
#elif defined (__AVR_ATtiny24__) || defined(__AVR_ATtiny44__) || defined(__AVR_ATtiny84__)
  ADMUX = _BV(MUX5) | _BV(MUX0);
#elif defined (__AVR_ATtiny25__) || defined(__AVR_ATtiny45__) || defined(__AVR_ATtiny85__)
  ADMUX = _BV(MUX3) | _BV(MUX2);
#else
  ADMUX = _BV(REFS0) | _BV(MUX3) | _BV(MUX2) | _BV(MUX1);
#endif
  custom_delay_usec(2000); // 2ms enough

  ADCSRA |= _BV(ADSC); // Start conversion
  while (bit_is_set(ADCSRA, ADSC)); // measuring

  uint8_t low  = ADCL; // must read ADCL first - it then locks ADCH
  uint8_t high = ADCH; // unlocks both

  long result = (high << 8) | low;

  result = 1125300L / result; // Calculate Vcc (in mV); 1125300 = 1.1*1023*1000
  power_adc_disable();
  return result; // Vcc in millivolts
}
```

[MySensors]: https://www.mysensors.org/
[^3]: https://www.mysensors.org/

## Les commandes Roomba

J'ai ré-écrit la fonction `roomba_send` pour la rendre plus compacte et plus
spécialisée.

``` c
void roomba_send(char code) {
  for (char i = 7; i >= 0; i--) {
    if (code & (1 << i)) {
      PWM_ON;
      custom_delay_usec(3000);
      PWM_OFF;
      custom_delay_usec(1000);
    } else {
      PWM_ON;
      custom_delay_usec(1000);
      PWM_OFF;
      custom_delay_usec(3000);
    }
  }
}
```

J'ai trouvé la liste des commandes sur le [gist de Probonopd][ProbonopdGist][^1]
et dans le document [iRobot Roomba 500 Open Interface Specs, page
22][iRobotRoomba500OpenInterfaceSpecs][^2]

[ProbonopdGist]: https://gist.github.com/probonopd/5181021
[iRobotRoomba500OpenInterfaceSpecs]: https://www.irobot.lv/uploaded_files/File/iRobot_Roomba_500_Open_Interface_Spec.pdf

[^1]:https://gist.github.com/probonopd/5181021
[^2]:https://www.irobot.lv/uploaded_files/File/iRobot_Roomba_500_Open_Interface_Spec.pdf

```
 IR Remote Control
 129 Left 
 130 Forward 
 131 Right 
 132 Spot 
 133 Max 
 134 Small 
 135 Medium 
 136 Large / Clean 
 137 Stop 
 138 Power 
 139 Arc Left 
 140 Arc Right 
 141 Stop  
 
 Scheduling Remote  
 142 Download 
 143 Seek Dock 
 
 Roomba Discovery Driveon Charger 
 240 Reserved 
 248 Red Buoy 
 244 Green Buoy 
 242 Force Field 
 252 Red Buoy and Green Buoy 
 250 Red Buoy and Force Field 
 246 Green Buoy and Force Field 
 254 Red Buoy, Green Buoy and Force 
 
 Roomba 500 Drive-on Charger
 160 Reserved 
 161 Force Field 
 164 Green Buoy 
 165 Green Buoy and Force Field 
 168 Red Buoy 
 169 Red Buoy and Force Field 
 172 Red Buoy and Green Buoy 
 173 Red Buoy, Green Buoy and Force Field
 
 Roomba 500 Virtual Wall
 162 Virtual Wall 
 
 Roomba 500 Virtual Wall Lighthouse ###### (FIXME: not yet supported here)
 0LLLL0BB 
 LLLL = Virtual Wall Lighthouse ID
 (assigned automatically by Roomba 
 560 and 570 robots) 
 1-10: Valid ID 
 11: Unbound 
 12-15: Reserved 
 BB = Which Beam
 00 = Fence 
 01 = Force Field 
 10 = Green Buoy 
 11 = Red Buoy
```

## Connexion de tout ça

Enfin, les fonctions `setup` et `loop` restent relativement simples !

``` c
void setup() {
  noInterrupts();  // no need to interrupt when not sleeping
  LED_SETUP;
  IR_SETUP;
  PWM_SETUP(38);   // 38kHz carrier
  power_timer1_disable();
  power_adc_disable();
  wdt_disable(); // In case it was rebooted during sleep, for any reason, without power cycle, wdt is still enabled
}
```

Tout comme le mur virtuel iRobot d'origine, j'ai ajouté un délai d'expiration
lorsque l'on oublie de l'éteindre. Il entrera dans un sommeil profond infini
après 150 minutes d'activité.

``` c
void loop() {
  iter++;
  timeout++;

  if      (iter == 1) bat = readVcc();
  else if (iter == 2) LED_ON;
  else if (iter == 3) LED_OFF;
  else if ((iter == 4) && (bat < 3000)) LED_ON;   // Thresholds in mV for 1S LiPo + BMS
  else if ((iter == 5) && (bat < 3000)) LED_OFF;
  else if ((iter == 6) && (bat < 2800)) LED_ON;
  else if ((iter == 7) && (bat < 2800)) LED_OFF;
  else if (iter == 120) iter = 0;                 // New battCheck every 15s approx

  roomba_send(code); // 4ms
  wdtSleep(100);     // 100 ms

  // Extra 50ms break every 3 burst to have a 150ms break
  if ((iter % 3) == 0)
    wdtSleep(50);    // 50ms

  if (timeout == 0) {
    set_sleep_mode (SLEEP_MODE_PWR_DOWN);
    power_all_disable();
    noInterrupts();
    sleep_mode();
  }
}
```

# Boitier

Lorsque l'on aborde le sujet de la domotique, le critère le plus important est
le [WAF (Wife Acceptance Factor)][WAF][^4], le facteur d'acceptation de votre
femme ! et le boitier se doit d'être conforme WAF. J'ai donc conçu un boitier
aussi petit que possible, dépendant de la forme de la batterie. Il est conçu
pour être stable, petit, réduisant le diamètre du faisseau IR, permettant aux
DEL de charge/décharge/activité d'être visibles, avec l'interrupteur
marche-arrêt à l'arrière et le port micro-USB de charge accessible sur le coté.

![d6fbd67e80ed55ad70db83567c4d3430.png]

J'ai inclu un séparateur entre la LiPo et les PCB pour éviter que les broches
des composants n'endommagent la batterie, cela l'enflamerait et ne serait
définitivement pas WAF du tout !

![06668ef8d4cf1492827555e6681d628f.png]

J'ai utilisé *FreeCAD* pour la conception du boitier, ai exporté chacune des
trois parties dans un fichier STL séparé. Je les ai imprimés en PLA sur mon
imprimante CR-10 avec une qualité 0.2mm et 20% de remplissage avec Cura comme
slicer.

[WAF]: https://en.wikipedia.org/wiki/Wife_acceptance_factor
[^4]: https://en.wikipedia.org/wiki/Wife_acceptance_factor

# Améliorations

Elles sont en lien avec l'autonomie et l'économie d'énergie. J'ai mesuré 6mA en
moyenne, le périphérique devrait fonctionner plusieurs semaines avec une
batterie LiPo de 850mAh. J'ai donc noté les idées sans les implémenter.

![4e9580c8f4eb3d4f015f5273740ed586.png]
Courant consommé

## Code

Utilisation du mode `SLEEP_MODE_IDLE` ou mieux pendant les pauses de 1 et 3 ms
lors de la modulation du signal, en réutilisant le timer 0 à 38kHz.

## Hardware

Utilisation d'un bouton poussoir pour générer une interruption, sortir le MCU de
sa léthargie et initialiser une temporisation : une pression/un clignotement/une
heure, deux pressions/deux clignotements/deux heures, 3, 4, 5 et retour à 1.

## Domotique

Avec ce hack, il devient possible d'enrichir ce projet en combinaison avec le
projet MySensors pour implémenter un système intelligent de pilotage de Roomba
entre les pièces.

# Remerciements

Je tiens à remercier la société iRobot pour leurs appareils, leurs
documentations et leurs kits d'apprentissage.


# Supports et liens

- [Video][video]
- [Kicad file][kicadfiles]
- [FreeCAD files][FreeCADFiles]
- [Arduino source code][sourcecode]

# Notes de bas de page

[Video]: https://youtu.be/2QJ_tI8vHBU "Enregistrement vidéo de la démonstration"
[e9b62e4d6ca94ea011baddec0d672755.png]: {{ "/assets/posts/" | append: page.uid | append:"/e9b62e4d6ca94ea011baddec0d672755.png" | relative_url }} "Schema"
[1380a757a5d48aea3045c8a6bcd074ce.png]: {{ "/assets/posts/" | append: page.uid | append:"/1380a757a5d48aea3045c8a6bcd074ce.png" | relative_url }} "ATtiny repository"
[fdce2d0d0490d3a4051874a1018bd841.png]: {{ "/assets/posts/" | append: page.uid | append:"/fdce2d0d0490d3a4051874a1018bd841.png" | relative_url }} "ATTiny package"
[aad6704814837057484eb1d66efe564c.png]: {{ "/assets/posts/" | append: page.uid | append:"/aad6704814837057484eb1d66efe564c.png" | relative_url }} "Protocol"
[d6fbd67e80ed55ad70db83567c4d3430.png]: {{ "/assets/posts/" | append: page.uid | append:"/d6fbd67e80ed55ad70db83567c4d3430.png" | relative_url }} "Enclosure photo"
[06668ef8d4cf1492827555e6681d628f.png]: {{ "/assets/posts/" | append: page.uid | append:"/06668ef8d4cf1492827555e6681d628f.png" | relative_url }} "Enclosure design"
[4e9580c8f4eb3d4f015f5273740ed586.png]: {{ "/assets/posts/" | append: page.uid | append:"/4e9580c8f4eb3d4f015f5273740ed586.png" | relative_url }} "Current drawn"
[kicadfiles]: {{ "/assets/posts/" | append: page.uid | append:"/FC006-iRobotRoomba660VirtualWall_kicad.zip" | relative_url }} "kicad project"
[Freecadfiles]: {{ "/assets/posts/" | append: page.uid | append:"/FC006-iRobotRoomba660VirtualWall_freecad.zip" | relative_url }} "freecad design"
[sourcecode]: {{ "/assets/posts/" | append: page.uid | append:"/FC006-iRobotRoomba660VirtualWall_source.zip" | relative_url }} "source code"

