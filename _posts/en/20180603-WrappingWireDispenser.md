---
uid: WrappingWireDispenser
title: 3D printed wrapping wire dispenser
author: fcerbell
layout: post
lang: en
#description:
#category: Test
tags: [ Wrapping, Wire, Dispenser, 3D, Printing, Creality, CR-10, OpenSCAD, Design, PLA ]
#date: 9999-01-01
published: true
---

I often use wrapping wire for my electronic projects. Either I wrap the wires for quick prototyping, and
then I can unwrap them, or I solder them when I want a more long term prototype. Banggood sells 8 colors
of [wrapping wire in 300m spools, at 8€ each][Banggood]. I bought one of each and needed a convenient
storage and dispenser. 

You can find links at the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Result

![Result][result.jpg]

# Design

I took some inspiration from Philippe Demerliac's [YouTube Channel][CyrobChan] and [website][CyrobOrg].

![Spools][spools.jpg]

I always used Blender3D for my 3D printing designs, but I read somewhere that [Blender][BlenderOrg] is better for
designing organic things and [OpenSCAD][OpenSCADOrg] is better for mecanical parts. So, I decided to
give it a chance. Furthermore, I publish my things on [my Thingiverse account][FCerbellThingiverse] and
they are able to use OpenSCAD files as template that the user can customize.

I wanted something very simple, such as two rows of 4 spools. I wanted to print without supports and to
have something that can be mounted without screws. I first designed an U shaped cube, with holes on both
sides and a tube ended with a thread. Despite that printing a thread can work ... or not, it is not easy
to print it accurately on every printer with every material. So, I removed the thread and created a key
shaped hole on both sides to clip the tube in the box. Then, I did not want that several spools turn
when using one, and I inserted fillers.  I rounded the top of the sides to have something less ugly.

I had the basis. I am curious and wanted to try to publish a "customizer" in Thingiverse. So, I
parametrized every constant and documented the variable. And I began to think to other people. My need
is to have the dispenser's bottom flat on the table. But this need could change with the time and some
other users might want to have it wall mounted. So, I made the back square shaped, to be able to return
the dispenser and use it vertically. And I also added 4 screw holes in case of wall mounting.

![First design][firstdesign.jpg]

I still did not have a solution to lock the wires. The idea is to use a sponge or foam, between two
printed parts, and to have the wires that come from the spools, go through the foam and ends there. I
decided to use the square shaped back to clip this foam support. But if I want to place my dispenser
vertically, this would not be convenient, so I square shaped the front too. 

I did not yet design the foam support
because I still don't have an urgent need
for it, yet.

That's all for the design.

# Print

I got a Creality CR-10 last year and I am really very happy with it. I had issues, but I solved them
all, by learning. This means that the problem is not the hardware, but the user ;)

ABS is stronger, had better resistance against humidity and temperature, better mecanical properties, is
more flexible than PLA and des not break so easily, but is also more complex to print. As my dispenser
will reside indoor, on my desk, I chose to print in PLA, with an [ArianePlast White
PLA][ArianePlastWhitePLA] test spool (350g).

I used [Cura][UltimakerCura] for slicing.


* Layer heigth = 0.3mm because I don't need a perfectly finished thing

* Infill = 50% with triangles, it is a lot longer but I need some rigidity and strength

* 4 perimeters by default in each direction

* no support, only a brim because the back plate is quite wide in my case (15 x 15cm) and the tubes need to be well secured.

* Horizontal size expansion = -0.3mm, **this is very important** as I design all my parts to exactly fit
  together. Without this setting, given that the extruder pushed material a little bit outside of the
  thig's volume, I would not be able to clip the parts together (every hole would be a little bit
  smaller than the design and every pin, a little bit larger).

* speed = 45mm/s because my stepper begins to have difficulty to push my PLA faster with the nozzle set
  at 215°C. If I increase the nozzle temperature, the PLA leaks (retract 4mm) I get hairs between
  perimeters, and if I retract more than, my nozzle will clog.

With these settings, it took approximately 30h to print, this can seem to be long but it is fast to
finally get a perfect fit for my need.

# Materials and Links

Here is the Thingiverse thing link. You can use the "customize" link to adapt the thing to your need
without downloading the source file and editing it in OpenSCAD.



| Link | Description |
|---|---|
| [My Cura profile file][MyWrappingWireDispenser.curaprofile] | Settings that I used on my Creality CR-10, with 0.4 nozzle and ArianePlast White PLA |
| [SCAD design file][MyWrappingWireHolder.scad] | The design source file to edit it with OpenSCAD |
| [Thingiverse customizer][Customizer] | The interractive customizable online design file |
| [Thingiverse thing][Thing] | The design page on Thingiverse |
| [My STL file][MyWrappingWireHolder.stl] | The STL file that I printed for my usage with 8 (4x2) banggood spools |



# Footnotes

[spools.jpg]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/spools.jpg "Wrapping wire spools"
[firstdesign.jpg]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/firstdesign.jpg "First design"
[result.jpg]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/result.jpg "Result"
[Banggood]: https://www.banggood.com/0_55mm-Circuit-Board-Single-Core-Tinned-Copper-Wire-Wrap-Electronic-Wire-Fly-Wire-Dupont-Cable-Jumper-Cable-8-Color-Available-p-1121767.html
[CyrobOrg]: http://philippe.demerliac.free.fr/Misc.htm
[CyrobChan]:https://www.youtube.com/channel/UC5QPFDZ3Y4ylkkGJc6Y1OOA
[ArianePlastWhitePLA]: https://www.arianeplast.com/pla-format-350g/362-pla-blanc-3d-filament-arianeplast-350g.html
[BlenderOrg]: https://www.blender.org/ "Blender 3D website"
[OpenSCADOrg]: http://www.openscad.org/ "OpenSCAD website"
[FcerbellThingiverse]: https://www.thingiverse.com/fcerbell/designs "My space on Thingiverse"
[UltimakerCura]: https://ultimaker.com/en/products/ultimaker-cura-software "Cura slicer homepage"
[MyWrappingWireHolder.scad]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/MyWrappingWireHolder.scad "MyWrappingWireHolder.scad"
[MyWrappingWireDispenser.curaprofile]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/MyWrappingWireDispenser.curaprofile "MyWrappingWireDispenser.curaprofile"
[MyWrappingWireHolder.stl]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/MyWrappingWireHolder.stl "MyWrappingWireHolder.stl"
[Thing]: https://www.thingiverse.com/thing:2942689
[Customizer]: https://www.thingiverse.com/apps/customizer/run?thing_id=2942689
