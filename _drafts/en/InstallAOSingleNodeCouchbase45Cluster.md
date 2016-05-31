---
uid: InstallASingleNodeCouchbase45Cluster.md
title: Install a single node Couchbase 4.5 Cluster
author: fcerbell
layout: post
lang: en
#description:
#category: Test
#categories
#tags
#date: 9999-01-01
published: true
---

Couchbase nodes are designed to work in a cluster. When installing a new
cluster, we have to install a first node. This node will be the minimal form of
the cluster before other nodes are added. We will see how to install this first
node. We will enable all services, so it will be possible to use this single
node as a Couchbase cluster, without redundancy (and replication). It is enough
to test the data access, to develop an application or to evaluate some of the
product's features.

You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video

<center></center>

# Prerequisites
You will need a computer with at least 2 GB of RAM and 2 cores, even if the
recommended settings are 4 GB of RAM and 4 cores. You will also need one of the
supported operating systems installed on this computer. It can be a physical
computer or a virtual computer. Couchbase also provides a *Docker* container,
but it is currently not officially supported and I won't use it here.

# Prepare the operating system

## Windows

## Debian

## Ubuntu

## CentOS/RedHat

## MacOS


# Download Coucbase server 4.5

## Windows

## Debian

## Ubuntu

## CentOS/RedHat

## MacOS


# Installation

## Windows

## Debian

## Ubuntu

## CentOS/RedHat

## MacOS

# Configuration

## Cluster name

## Auto-failover

## Audit logging

# Sample data loading

# Materials and Links

| Link | Description |
|---|---|
| [MainBook][mainbook], Slides([dualhead][maindeck_dualhead], [notesonly][maindeck_notesonly], [paper][maindeck_paper], [slidesonly][maindeck_slidesonly]) | Article booklet to print and associated slidedecks |
| [DemoBook][demobook], Slides([dualhead][demodeck_dualhead], [notesonly][demodeck_notesonly], [paper][demodeck_paper], [slidesonly][demodeck_slidesonly]) | Demo script booklet to print and associated slidedecks |
| [LabsBook][labsbook], Slides([dualhead][labsdeck_dualhead], [notesonly][labsdeck_notesonly], [paper][labsdeck_paper], [slidesonly][labsdeck_slidesonly]) | Hands-on scripts booklet to print and associated slidedecks |
| [ExercicesBook][exercicesbook], Slides([dualhead][exercicesdeck_dualhead], [notesonly][exercicesdeck_notesonly], [paper][exercicesdeck_paper], [slidesonly][exercicesdeck_slidesonly]) | Exercices and solutions booklet to print and associated slidedecks |
| [Video] | Demonstration screencast recording |

# Footnotes

[mainbook]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/mainbook.pdf "Printable handout booklet"
[maindeck_dualhead]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/maindeck_dualhead.pdf "Handout's slidedeck with notes in dualhead layout"
[maindeck_notesonly]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/maindeck_notesonly.pdf "Handout's slidedeck notes"
[maindeck_paper]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/maindeck_paper.pdf "Handout's printable slidedeck with notes in paper layout"
[maindeck_slidesonly]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/maindeck_slidesonly.pdf "Handout's slidedeck without notes"
[demobook]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/demobook.pdf "Printable demo booklet"
[demodeck_dualhead]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/demodeck_dualhead.pdf "Demo slidedeck with notes in dualhead layout"
[demodeck_notesonly]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/demodeck_notesonly.pdf "Demo slidedeck notes"
[demodeck_paper]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/demodeck_paper.pdf "Demo slidedeck with notes in paper layout"
[demodeck_slidesonly]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/demodeck_slidesonly.pdf "Demo slidedeck without notes"
[labsbook]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/labsbook.pdf "Printable labs booklet"
[labsdeck_dualhead]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/labsdeck_dualhead.pdf "Labs slidedeck with notes in dualhead layout"
[labsdeck_notesonly]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/labsdeck_notesonly.pdf "Labs slidedeck notes"
[labsdeck_paper]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/labsdeck_paper.pdf "Labs slidedeck with notes in paper layout"
[labsdeck_slidesonly]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/labsdeck_slidesonly.pdf "Labs slidedeck without notes"
[exercicesbook]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/exercicesbook.pdf "Printable Exercices booklet"
[exercicesdeck_dualhead]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/exercicesdeck_dualhead.pdf "Exercices slidedeck with notes in dualhead layout"
[exercicesdeck_notesonly]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/exercicesdeck_notesonly.pdf "Exercices slidedeck notes"
[exercicesdeck_paper]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/exercicesdeck_paper.pdf "Exercices slidedeck with notes in paper layout"
[exercicesdeck_slidesonly]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/exercicesdeck_slidesonly.pdf "Exercices slidedeck without notes"
[Video]: https://youtu.be/kK4GxAwJKD0 "Demonstration video recording"
