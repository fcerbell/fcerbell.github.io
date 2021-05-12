---
uid: skel
title: Squelette en Français
description:
category: Test
tags: [ tag1, tag2 ]
---

Abstract/Excerpt/Intro

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

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

# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/" frameborder="0" allowfullscreen></iframe></center>

# Pré-requis

Contenu

# Supports et liens

| Lien | Description |
|---|---|
| [MainBook][mainbook], Slides([dualhead][maindeck_dualhead], [notesonly][maindeck_notesonly], [paper][maindeck_paper], [slidesonly][maindeck_slidesonly]) | Article booklet to print and associated slidedeck |
| [DemoBook][demobook], Slides([dualhead][demodeck_dualhead], [notesonly][demodeck_notesonly], [paper][demodeck_paper], [slidesonly][demodeck_slidesonly]) | Demo script booklet to print and associated slidedeck |
| [LabsBook][labsbook], Slides([dualhead][labsdeck_dualhead], [notesonly][labsdeck_notesonly], [paper][labsdeck_paper], [slidesonly][labsdeck_slidesonly]) | Hands-on scripts booklet to print and associated slidedeck |
| [ExercicesBook][exercicesbook], Slides([dualhead][exercicesdeck_dualhead], [notesonly][exercicesdeck_notesonly], [paper][exercicesdeck_paper], [slidesonly][exercicesdeck_slidesonly]) | Exercices and solutions booklet to print and associated slidedeck |
| [Video] | Enregistrement vidéo de la démonstration |

# Notes de bas de page

[mainbook]: {{ "/assets/posts/" | append: page.uid | append:"/mainbook.pdf" | relative_url }} "Livret principal imprimable"
[maindeck_dualhead]: {{ "/assets/posts/" | append: page.uid | append:"/maindeck_dualhead.pdf" | relative_url }} "Diaporama du livret principal avec les notes, dans un format pour deux écrans"
[maindeck_notesonly]: {{ "/assets/posts/" | append: page.uid | append:"/maindeck_notesonly.pdf" | relative_url }} "Notes du diaporama du livret principal"
[maindeck_paper]: {{ "/assets/posts/" | append: page.uid | append:"/maindeck_paper.pdf" | relative_url }} "Diaporama du livret principal imprimable sur papier avec les notes"
[maindeck_slidesonly]: {{ "/assets/posts/" | append: page.uid | append:"/maindeck_slidesonly.pdf" | relative_url }} "Diaporama du livret principal sans les notes"
[demobook]: {{ "/assets/posts/" | append: page.uid | append:"/demobook.pdf" | relative_url }} "Script de démonstration imprimable"
[demodeck_dualhead]: {{ "/assets/posts/" | append: page.uid | append:"/demodeck_dualhead.pdf" | relative_url }} "Diaporama du script de démonstration avec les notes, dans un format à deux écrans"
[demodeck_notesonly]: {{ "/assets/posts/" | append: page.uid | append:"/demodeck_notesonly.pdf" | relative_url }} "Notes diaporama du script de démonstration"
[demodeck_paper]: {{ "/assets/posts/" | append: page.uid | append:"/demodeck_paper.pdf" | relative_url }} "Diaporama du script de demonstration imprimable sur papier avec les notes"
[demodeck_slidesonly]: {{ "/assets/posts/" | append: page.uid | append:"/demodeck_slidesonly.pdf" | relative_url }} "Diaporama du script de démonstration sans les notes"
[labsbook]: {{ "/assets/posts/" | append: page.uid | append:"/labsbook.pdf" | relative_url }} "Cahier de travaux dirigés imprimable"
[labsdeck_dualhead]: {{ "/assets/posts/" | append: page.uid | append:"/labsdeck_dualhead.pdf" | relative_url }} "Diaporama du cahier de travaux dirigés avec les notes, dans un format à deux écrans"
[labsdeck_notesonly]: {{ "/assets/posts/" | append: page.uid | append:"/labsdeck_notesonly.pdf" | relative_url }} "Notes du diaporama du cahier de travaux dirigés"
[labsdeck_paper]: {{ "/assets/posts/" | append: page.uid | append:"/labsdeck_paper.pdf" | relative_url }} "Diaporama du cahier de travaux dirigés imprimable sur papier avec les notes"
[labsdeck_slidesonly]: {{ "/assets/posts/" | append: page.uid | append:"/labsdeck_slidesonly.pdf" | relative_url }} "Diaporama du cahier de travaux dirigés sans les notes"
[exercicesbook]: {{ "/assets/posts/" | append: page.uid | append:"/exercicesbook.pdf" | relative_url }} "Livret d'exercices imprimable"
[exercicesdeck_dualhead]: {{ "/assets/posts/" | append: page.uid | append:"/exercicesdeck_dualhead.pdf" | relative_url }} "Diaporama du livret d'exercices avec les notes au format double-écran"
[exercicesdeck_notesonly]: {{ "/assets/posts/" | append: page.uid | append:"/exercicesdeck_notesonly.pdf" | relative_url }} "Notes du diaporama du cahier d'exercices"
[exercicesdeck_paper]: {{ "/assets/posts/" | append: page.uid | append:"/exercicesdeck_paper.pdf" | relative_url }} "Diaporama du cahier d'exercices avec les notes au format papier"
[exercicesdeck_slidesonly]: {{ "/assets/posts/" | append: page.uid | append:"/exercicesdeck_slidesonly.pdf" | relative_url }} "Diaporama du cahier d'exercices sans les notes"
[Video]: https://youtu.be/kK4GxAwJKD0 "Enregistrement vidéo de la démonstration"
