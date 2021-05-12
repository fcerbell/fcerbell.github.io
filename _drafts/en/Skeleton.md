---
uid: skel
title: English Skeleton
description:
category: Test
tags: [ tag1, tag2 ]
---

Abstract/Excerpt/Intro

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

Content

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
