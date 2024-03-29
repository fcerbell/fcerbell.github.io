---
uid: VtxOsdMount
title: VTX and OSD mount for FPV
description:
category: 3DPrinting
tags: [ VTX, OSD, RC, FPV ]
---

I bought a mini camera, an OSD (On Screen Display) and a VTX
(Video Transmitter) to mount on my 250 quadcopter (drone), it
does not have any mount hole and I need to secure them on board.
Here is a 3D printed box for the VTX+OSD.

You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/" frameborder="0" allowfullscreen></iframe></center>

# Hardware

I wanted to mount these hardware :

* the Eachine VTX-03 (25/200/600mW video only emitter) : [https://www.banggood.com/Eachine-VTX03-Super-Mini-5_8G-72CH-025mW50mw200mW-Switchable-FPV-Transmitter-p-1114206.htm]

* the micro minimOSD On Screen Display : [https://www.banggood.com/CC3D-Flight-Controller-Mini-OP-OSD-For-FPV-Multicopter-p-1009911.html]

I soldered the wires, but it was impossible to secure the PCBs
on the model. I decided to print a box for the OSD+VTX, that I
could secure and the camera will be secured later.

Include photo of the devices

On the VTx side, there need to be a hole to see LED display, to
let the antenna connector be used and to be able to use the
setting button. 

Regardng the OSD, I used bended pins to connect either to the
flight controller (CC3D Atom with BetaFlight) or to an FTDI for
configuration with MWOSD Configurator. The 3 wires for the
camera are pinched between the box and the cover to limit the
stress on the connections.

I chose to power the whole system using the OSD pins, with 5V
from the flight controller (Camera + OSD + VTx 600mW uses only
approx 400mA and the Flight controller is powered from PDB with
a 3A BEC). That way, all the devices share the same GND and +5V. 

Printed with a Creality CR-10, nozzle size 0.4mm, white Optimus 
PLA, nozzle temp 200, bed heat 60, layer height 0.15, infill
20%, in approximately 1h.

SCAD file
SCAD preview
Photos

# Possible improvements

I could add 

- mounting holes to secure the thing on my frame 

- a plate to have the camera attached to the box, limitting the
  stress on the camera wires and connections.

# Disclamer

Never forget that such a multicopter is an RC model, not a toy,
it can be really dangerous because of the propellers or of its
own weight when falling. Flying FPV does not give you a good
vision of the whole environment.

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
