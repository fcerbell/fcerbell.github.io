---
uid: HomeAutomationCenterPrintedBox
title: Home automation center printed box
description:
category: Home Automation
tags: [ Creality, CR-10, Blender, Slic3r, Domoticz, RFXCom, RFX433trs, MySensors, Z-Wave.me, Z-Wave, Razberry ]
---

I used Domoticz on a Raspberry PI 1 model B, with the z-wave.me
Razberry Z-Wave daughter card, an RFXCOM RFX433trx and a
MySensors.org gateway for almost three years to control more
than 100 devices (sensors and actuators) at home. All the
hardware was as-is, with cables, power stolen from my internet
box, ... I decided to clean up and redesign everything,
including the box and the power supply to have an integrated
hardware more convenient to use. This post describes the
hardware and the 3D printed box design.

You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

* H1 : # Header 1
* H2 : ## Header 2
* H3 : ### Header 3
* H4 : #### Header 4
* H5 : ##### Header 5
* H6 : ###### Header 6
* Links : [Title](URL)
* Links : [Label][linkid]
[linkid]: http://www.example.com/ "Optional Title"
* Bold : **Bold**
* Italicize : *Italics*
* Strike-through : ~~text~~
* Highlight : ==text==
* Paragraphs : Line space between paragraphs
* Line break : Add two spaces to the end of the line
* Lists : * an asterisk for every new list item.
* Quotes : > Quote
* Inline Code : `alert('Hello World');`
* Horizontal Rule (HR) : --------
[^1]: This is my first footnote
[^n]: Visit http://milanaryal.com
[^n]: A final footnote

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/" frameborder="0" allowfullscreen></iframe></center>

# Prerequisites

# The past

I used the following harware for the last 3 years :

* Raspberry PI 1 model B with the official box

* Z-Wave.me Razberry Z-Wave controller daughter card v1

* RFXCom RFX433trx transceiver

* Power stolen from the internet box

* Ethernet (wired) network connection

There were several drawbacks :

* I lost the IDs of some Z-Wave devices, software bug ?
  Insufficient power supply ? Razberry hardware bug ? IoT
  devices firmware bug ?

* Due to the power supply, when I wanted to include/exclude a
  node which is not mobile (wall switch, for example), I had to
  halt the system, unplug it (main and network), plug it near 
  the device (main and network), reboot it, and wait for the
  Z-Wave network discovery to end...

* The MySensors gateway is connected to the network by ethernet,
  and powered by USB (weak power, too), which causes some
  instabilities and resets.

# The needs

I needed  to remove all these pains :

* Embedded power supply, powerful enough for the Raspberry, the
  Razberry and the RFXcom.

* Battery, powerful enough for the hardware, charging and
  feeding the hardware while connected to the power supply, with
  a poweroff switch

* Wifi connection available anywhere at home, to avoid wired
  connection when transporting the hardware near a device to
  include/exclude.

* Stabilize and integrate the Ethernet/Arduino/NRF24L01+
  MySensors gateway in the box.

* For the security : a main power switch and high-voltage
  insulated and separated from the low-voltage.

* The SD card should be accessible without a screw driver, but
  does not need to be visible.

# The selected hardware

* Raspberry Pi 3 to have the wifi embedded

* Power supply Unit AC-DC 220-5V 4A

* Razberry Z-Wave v2 daughter card

* Geekcreit® V1.0 Lithium Battery Expansion Board For Raspberry Pi 3 Model B / Pi 2B / B+

* Migrate the MySensors gateway to Serial/Arduino/NRF24L01+ to
  avoid the need for an ethernet connection and power it from
  the box power supply.

* Printed plastic (PLA) box

* Power cord, micro power switch, ...

Due to the proximity, I might encounter some interferences between :

* Wifi and NRF24L01+ (2.4GHz)

* Z-Wave (868MHz)

* RFXCom433trx (433MHz)

* Switching power supply (noisy)

* a bunch of M3 (for the bo) and M2 screws (for the boards)



# Materials and Links

| Link | Description |
|---|---|
| [MainBook][mainbook], Slides([dualhead][maindeck_dualhead], [notesonly][maindeck_notesonly], [paper][maindeck_paper], [slidesonly][maindeck_slidesonly]) | Article booklet to print and associated slidedecks |
| [DemoBook][demobook], Slides([dualhead][demodeck_dualhead], [notesonly][demodeck_notesonly], [paper][demodeck_paper], [slidesonly][demodeck_slidesonly]) | Demo script booklet to print and associated slidedecks |
| [LabsBook][labsbook], Slides([dualhead][labsdeck_dualhead], [notesonly][labsdeck_notesonly], [paper][labsdeck_paper], [slidesonly][labsdeck_slidesonly]) | Hands-on scripts booklet to print and associated slidedecks |
| [ExercicesBook][exercicesbook], Slides([dualhead][exercicesdeck_dualhead], [notesonly][exercicesdeck_notesonly], [paper][exercicesdeck_paper], [slidesonly][exercicesdeck_slidesonly]) | Exercices and solutions booklet to print and associated slidedecks |
| [Video] | Demonstration screencast recording |

# Footnotes

[mainbook]: {{ "/assets/posts/" | append: page.uid | append:"/mainbook.pdf" | relative_url }} "Printable handout booklet"
[maindeck_dualhead]: {{ "/assets/posts/" | append: page.uid | append:"/maindeck_dualhead.pdf" | relative_url }} "Handout's slidedeck with notes in dualhead layout"
[maindeck_notesonly]: {{ "/assets/posts/" | append: page.uid | append:"/maindeck_notesonly.pdf" | relative_url }} "Handout's slidedeck notes"
[maindeck_paper]: {{ "/assets/posts/" | append: page.uid | append:"/maindeck_paper.pdf" | relative_url }} "Handout's printable slidedeck with notes in paper layout"
[maindeck_slidesonly]: {{ "/assets/posts/" | append: page.uid | append:"/maindeck_slidesonly.pdf" | relative_url }} "Handout's slidedeck without notes"
[demobook]: {{ "/assets/posts/" | append: page.uid | append:"/demobook.pdf" | relative_url }} "Printable demo booklet"
[demodeck_dualhead]: {{ "/assets/posts/" | append: page.uid | append:"/demodeck_dualhead.pdf" | relative_url }} "Demo slidedeck with notes in dualhead layout"
[demodeck_notesonly]: {{ "/assets/posts/" | append: page.uid | append:"/demodeck_notesonly.pdf" | relative_url }} "Demo slidedeck notes"
[demodeck_paper]: {{ "/assets/posts/" | append: page.uid | append:"/demodeck_paper.pdf" | relative_url }} "Demo slidedeck with notes in paper layout"
[demodeck_slidesonly]: {{ "/assets/posts/" | append: page.uid | append:"/demodeck_slidesonly.pdf" | relative_url }} "Demo slidedeck without notes"
[labsbook]: {{ "/assets/posts/" | append: page.uid | append:"/labsbook.pdf" | relative_url }} "Printable labs booklet"
[labsdeck_dualhead]: {{ "/assets/posts/" | append: page.uid | append:"/labsdeck_dualhead.pdf" | relative_url }} "Labs slidedeck with notes in dualhead layout"
[labsdeck_notesonly]: {{ "/assets/posts/" | append: page.uid | append:"/labsdeck_notesonly.pdf" | relative_url }} "Labs slidedeck notes"
[labsdeck_paper]: {{ "/assets/posts/" | append: page.uid | append:"/labsdeck_paper.pdf" | relative_url }} "Labs slidedeck with notes in paper layout"
[labsdeck_slidesonly]: {{ "/assets/posts/" | append: page.uid | append:"/labsdeck_slidesonly.pdf" | relative_url }} "Labs slidedeck without notes"
[exercicesbook]: {{ "/assets/posts/" | append: page.uid | append:"/exercicesbook.pdf" | relative_url }} "Printable Exercices booklet"
[exercicesdeck_dualhead]: {{ "/assets/posts/" | append: page.uid | append:"/exercicesdeck_dualhead.pdf" | relative_url }} "Exercices slidedeck with notes in dualhead layout"
[exercicesdeck_notesonly]: {{ "/assets/posts/" | append: page.uid | append:"/exercicesdeck_notesonly.pdf" | relative_url }} "Exercices slidedeck notes"
[exercicesdeck_paper]: {{ "/assets/posts/" | append: page.uid | append:"/exercicesdeck_paper.pdf" | relative_url }} "Exercices slidedeck with notes in paper layout"
[exercicesdeck_slidesonly]: {{ "/assets/posts/" | append: page.uid | append:"/exercicesdeck_slidesonly.pdf" | relative_url }} "Exercices slidedeck without notes"
[Video]: https://youtu.be/kK4GxAwJKD0 "Demonstration video recording"
