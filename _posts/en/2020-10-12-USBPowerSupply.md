---
uid: USBPSU
title: Desktop USB charger 10A
description:
category: Electronic
tags: [ USB, Electronic ]
---

More and more devices are powered with an USB plug. They require more and more
power but some USB sockets are designed to deliver 500mA or 1A max. It would be
danregous to plug such devices to USB HUBs or to computers. I am tired of
looking for a matching power supply and to have tons of them. Thus I designed a
very simple power supply to plug up to 5 devices, deliver up to 10A and to
individually switch them. I'll connect my light LED panels (10W) on this PSU and
my phone.

You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/JUCJF3AiknI " frameborder="0" allowfullscreen></iframe></center>

# Hardware

Links are direct to the items at Amazon's or Banggood's.

I needed :
- 5 x [USB sockets](https://www.banggood.com/fr/5pcs-USB-2_0-Female-Head-Socket-To-DIP-2_54mm-Pin-4P-Adapter-Board-p-1167635.html?p=74090529739222015113&custlinkid=1310592)
- 6 x [rocker switch](https://www.banggood.com/fr/10pcs-Rocker-Switchs-Copper-Boat-Rocker-Switch-2-Pin-Plastic-Button-ONOff-SPST-p-1276758.html?p=74090529739222015113&custlinkid=1310591)
- 1 x [LED (no matter which color)](https://www.banggood.com/fr/200pcs-5MM-LED-Diode-Kit-Mixed-Color-Red-Green-Yellow-Blue-Orange-p-1009873.html?p=74090529739222015113&custlinkid=1310594)
- 1 x [220 ohms resistor (fits any LED color)](https://www.banggood.com/fr/560-Pcs-1-ohm-to-10M-ohm-1-or-4W-5-pencent-Metal-Film-Resistor-56-Value-Assorted-Kit-p-1072159.html?p=74090529739222015113&custlinkid=1310596)
- 1 x [switching Power supply (5V 10A)](https://www.amazon.fr/dp/B07PPPFG8W/ref=cm_sw_em_r_mt_dp_0seHFb6TAFTM6)
- 1 x [mains cord (with earth)](https://www.banggood.com/fr/1_2m-AC-Power-Supply-Adapter-Cord-Cable-Lead-AC-Adapter-Power-Connector-Line-Lead-EU-US-UK-Plug-p-1224261.html?p=74090529739222015113&custlinkid=1310598)

I used my Creality CR-10 4D printer for the enclosure and needed :
- 250g [PLA](https://www.banggood.com/fr/CCTREE-1_75mm-1KG-or-Roll-3D-Printer-ST-PLA-Filament-For-Ender-3-Pro-or-Ender-3-V2-or-Sidewinder-3D-Printer-p-1379089.html?p=74090529739222015113&custlinkid=1310600)
- 2 x [M3 inserts](https://www.banggood.com/fr/100pcs-M3x5x5mm-Metric-Threaded-Brass-Knurl-Round-Insert-Nuts-p-1050182.html?p=74090529739222015113&custlinkid=1310602)
- [zip ties](https://www.banggood.com/fr/50Pcs-RJXHOBBY-RJX29-3x150mm-Black-White-Color-Nylon-Cable-Zip-Tie-p-1430664.html?p=74090529739222015113&custlinkid=1310604)

# Materials and Links

| Link | Description |
|---|---|
| [FreeCAD source][freecad_enclosurebox] | Enclosure box, |
| [STL box][stl_enclosurebox] | Enclosure box |
| [STL cover][stl_enclosurecover] | Enclosure cover |
| [Video] | Demonstration screencast recording |

# Footnotes

[freecad_enclosurebox]: {{ "/assets/posts/" | append: page.uid | append:"/USBCharger.FCStd" | relative_url }} " "
[stl_enclosurebox]: {{ "/assets/posts/" | append: page.uid | append:"/USBCharger_Body.stl" | relative_url }} " "
[stl_enclosurecover]: {{ "/assets/posts/" | append: page.uid | append:"/USBCharger_Cover.stl" | relative_url }} " "
[Video]: https://youtu.be/JUCJF3AiknI "Demonstration video recording"

