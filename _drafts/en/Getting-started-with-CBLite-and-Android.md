---
uid: skel
author: fcerbell
title: Getting started with Couchbase Lite and Android
layout: post
lang: en
#description:
#category: Test
#categories
tags: android, couchbase, mobile
#date
published: true
---

Getting started with _Couchbase Lite_ as a storage backend embedded in an Android
application to store locally JSON documents and eventually synchronize them
between the local database and a _Couchbase_ Cluster. This post will explain how
to install _Android Studio_, how to start a new Android application project, how
to add _Couchbase Lite_ library and how to configure it.

# Download and Install Android Studio

The very first step is to download _Android Studio_ from
[Android.com](http://developer.android.com/sdk/index.html#Other). Choose to
download the whole _IDE_ with the _SDK_ for your platform and install it with
all the default choices.

# Download Android images

Then, I usually update the _Android SDK_ and install the Android images for all
the targetted versions. In my case, I download one image for each version,
_x86_64_  if available (faster emulation) or _ARM_, with _Google API_ if
available.

# Create Virtual Devices

I have 2 Android phones that I sometimes use to test my applications, but I
prefer to use an emulated phone to test on different Android versions. So, I
usually create several virtual Android Virtual Devices, mostly for phones and
tablets (TV and watches will come later).

# Create a project

# Add CBLite dependency

Add workaround

# Open a CBLite connection





![Start a new Android Studio project]({{site.url}}{{site.baseurl}}/assets/posts/GettingStartedWithCBLiteAndAndroid/120303.png)


Domoid : Home automation with Domoticz, Couchbase and CouchbaseLite

# Post 1 : Introduction, project specifications

## Why ? 
I am a mad and crazy computer addict since the age of 8 and opensource geek
since I discovered Linux in 1994.  I always wanted to create an Android app to
be famous and have a lot of 5 stars reviews (even if I am not sure to succeed
on this specific point).

I work as a sales engineer for Couchbase who asked me to be part of the IoT
subteam, mobile subteam and leader of the reporting subteam (I worked
previously at Jaspersoft)

We bought an old house and I need to refurbish the whole electrical system,
instead of simply following the standards, it would be clever to anticipate and
prepare the whole system for future standards, such as home automation. So, I
installed Domoticz in 2014 on one of my 18 Raspberry Pi (15 of them are in
cluster, maybe running Couchbase later) and began to install home automation
micro-modules everywhere I can (switches, roller-shutters, doors and windows,
radiators, Light sensors, temperature sensors, humidity sensors, IR sensors...).

## Goals

Home automation systems are amazing, you can get events and metrics and define
rules to apply. Of course a simple rule such as "when the IR sensor detects
someone, switch the light on" is quite stupid and a home automation system is
useless. But you can define more complex rules such as "when the night is
coming and the outdoor temperature is cold and the rollershutter are open,
close them, but only if the door is not open (I don't want to be locked out of
my house when I am outside)". It this case, it becomes more interesting. 

Then, you can define scenarios such as "I'm leaving the house", "I'm going to
sleep", "I'm coming back" to trigger a set of rules (light depending on the
enlightenment, heating, ...). 

Given that a standard mobile phone has a GPS embedded, it would be even more
clever to have specific scenarios trigerred automatically when I'm at the
beginning of my street, coming back to home... No need to press a button. It
could also notify me of some specific events (when we are at home, the IR
sensor can switch the light on during the evening, but when we are not at home,
triggering a siren and notifying me would be more useful).

At the end, as a strange paradoxal guy, I don't have an Android smart watch,
but a Pebble watch, so I'd like to control things from my watch too.

I don't have all the use cases, but I'm sure that I'll have to add more and
more use cases over the time. So I need a flexible solution.

## Online/Offline

Domoticz, as the other systems, has a web user-interface and an API, but the
mobile phones are not always connected when an event is trigerred, furthermore,
if the network connectivity is weak, I can not try-wait-retry for each action.
I'd like to open the application and trigger and action without waiting, and
the action will be actually executed when the network comes back.
Unfortunately, if I have no network, I even cannot see all my devices and
scenario, whereas these could be cached locally on the mobile device.

## Reporting

The home automation systems have a lot of very different devices connected. We
can not expect an IR sensor to return the same data schema as a switch. Thus,
having a JSON document database, with a flexible schema, is very interesting,
too. So, I'd like to be able to store each event from all the sensors in a
database, with historical values, and to generate reports, dashboards and
statistics on my mobile phone and maybe in a web user interface.

# Post x : Software choices

Android because I have only Android phones
iOS because my wife has an iPhone
Domoticz because it is opensource, working on RPi, under linux with a good architecture and very active.
Couchbase because it stores JSON documents, it can replicate parts of the database to/from mobile/embedded devices and I work there ! The only drawback is that I'll have to rebuild it for the RPi ARM architecture.

# Post x : Data model design

# Post x : Setting the Android environment

# Post x : Starting the Android project

# Post x : Setting the iOS/XCode environment

# Post x : Starting the iOS project

# Post x : Couchbase sync gateway compilation on ARM

# Post x : Replication with a standalone Sync Gateway

authentication

# Post x : Couchbase server compilation on ARM

# Post x : Persisting changes in a Couchbase cluster

# Post x : Tracking the GPS position from Android

# Post x : Tracking the GPS position from iOS

# Post x : Setting a NodeJS (CEAN) environment for the web UI

# Post x : Watching the GPS tracks from a Web UI

* TOC
{:toc}

# Initialize your project

## Create the project

## Add Couchbase Lite dependencie

## Create the database

## Implement something


# Other post : View the database contents with CBLiteViewer

# Other post : Couchbase Cluster

## Installation

## Configuration

## Test

# Other port : Couchbase Synchronization Gateway

## Installation

## Standalone configuration

## Test

## Persistent configuration

## Test



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

Content


