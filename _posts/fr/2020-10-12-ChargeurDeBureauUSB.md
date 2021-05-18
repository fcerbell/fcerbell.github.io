---
uid: USBPSU
title: Chargeur USB de bureau 10A
description:
category: Electronique
tags: [ USB, Electronique, Téléphone mobile, Mobile, LEDs, Smartphone, Tablette ]
---

De plus en plus de périphériques sont alimentés avec une prise USB. Ils
nécessitent de plus en plus de puissance mais certaines prises USB ne sont
conçue que pour délivrer 500mA ou 1A maximum. Ce serait dangereux de brancher de
tels périphériques sur de HUB USB ou sur des ordinateurs. Je suis las de devoir
chercher une alimentation USB qui corresponde à la puissance nécessaire et d'en
avoir tout un stock. J'ai donc décidé de concevoir une alimentation très simple,
capable d'alimenter 5 appareils, de déliver 10A et de piloter les prises
individuellement. J'y connecterai mes paneaux LED USB (10W) et mon téléphone.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la [fin de cet article](#supports-et-liens).

* TOC
{:toc}

# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/JUCJF3AiknI " frameborder="0" allowfullscreen></iframe></center>

# Matériel

Les liens sont directs sur les articles chez Amazon ou Banggood.

J'ai eu besoin de :
- 5 x [Prises USB](https://www.banggood.com/fr/5pcs-USB-2_0-Female-Head-Socket-To-DIP-2_54mm-Pin-4P-Adapter-Board-p-1167635.html?p=74090529739222015113&custlinkid=1310592)
- 6 x [interrupteur à bascule](https://www.banggood.com/fr/10pcs-Rocker-Switchs-Copper-Boat-Rocker-Switch-2-Pin-Plastic-Button-ONOff-SPST-p-1276758.html?p=74090529739222015113&custlinkid=1310591)
- 1 x [LED (Peu importe la couleur)](https://www.banggood.com/fr/200pcs-5MM-LED-Diode-Kit-Mixed-Color-Red-Green-Yellow-Blue-Orange-p-1009873.html?p=74090529739222015113&custlinkid=1310594)
- 1 x [résistance de 220 ohms (correspond à n'importe quelle couleur de LED)](https://www.banggood.com/fr/560-Pcs-1-ohm-to-10M-ohm-1-or-4W-5-pencent-Metal-Film-Resistor-56-Value-Assorted-Kit-p-1072159.html?p=74090529739222015113&custlinkid=1310596)
- 1 x [Alimentation à découpage (5V 10A)](https://www.amazon.fr/dp/B07PPPFG8W/ref=cm_sw_em_r_mt_dp_0seHFb6TAFTM6)
- 1 x [Cordon secteur avec terre](https://www.banggood.com/fr/1_2m-AC-Power-Supply-Adapter-Cord-Cable-Lead-AC-Adapter-Power-Connector-Line-Lead-EU-US-UK-Plug-p-1224261.html?p=74090529739222015113&custlinkid=1310598)

J'ai utilisé mon imprimante Creality CR-10 pour le boitier et j'ai eu besoin de :
- 250g [PLA](https://www.banggood.com/fr/CCTREE-1_75mm-1KG-or-Roll-3D-Printer-ST-PLA-Filament-For-Ender-3-Pro-or-Ender-3-V2-or-Sidewinder-3D-Printer-p-1379089.html?p=74090529739222015113&custlinkid=1310600)
- 2 x [inserts M3](https://www.banggood.com/fr/100pcs-M3x5x5mm-Metric-Threaded-Brass-Knurl-Round-Insert-Nuts-p-1050182.html?p=74090529739222015113&custlinkid=1310602)
- [colliers](https://www.banggood.com/fr/50Pcs-RJXHOBBY-RJX29-3x150mm-Black-White-Color-Nylon-Cable-Zip-Tie-p-1430664.html?p=74090529739222015113&custlinkid=1310604)

# Supports et liens

| Lien | Description |
|---|---|
| [FreeCAD source][freecad_enclosurebox] | Enclosure box, |
| [STL box][stl_enclosurebox] | Enclosure box |
| [STL cover][stl_enclosurecover] | Enclosure cover |
| [Video] | Demonstration screencast recording |

# Notes de bas de page

[freecad_enclosurebox]: {{ "/assets/posts/" | append: page.uid | append:"/USBCharger.FCStd" | relative_url }} " "
[stl_enclosurebox]: {{ "/assets/posts/" | append: page.uid | append:"/USBCharger_Body.stl" | relative_url }} " "
[stl_enclosurecover]: {{ "/assets/posts/" | append: page.uid | append:"/USBCharger_Cover.stl" | relative_url }} " "
[Video]: https://youtu.be/JUCJF3AiknI "Demonstration video recording"

