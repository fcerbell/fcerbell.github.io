---
uid: Debian113Server120LogWatchforadailyaggregatedloganalysis
title: Debian11, Server, LogWatch for a daily aggregated log analysis
description: Whereas LogCheck is low level and hourly log lines extractions, LogWatch is higher level daily log analysis with aggregation to have behavior statistics and detect trends, slow scans or slow attacks. The email reports are shorter and consolidated. This is a very short basic default installation documentation blog post. Part of my default server installation.
category: Computers
tags: [ Debian11 Server, Debian GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Logwatch, Analysis, Aggregated log analysis, Log Summary, Security ]
date: 2021-06-24 00:00:00
---

Whereas LogCheck is low level and hourly log lines extractions, LogWatch is higher level daily log analysis with aggregation to have behavior statistics and detect trends, slow scans or slow attacks. The email reports are shorter and consolidated. This is a very short basic default installation documentation blog post. Part of my default server installation.

* TOC
{:toc}

# LogWatch presentation

![ba17b78e47a8747e7559fd2ba367c6f3.png]({{ "/assets/posts/en/Debian113Server120LogWatchforadailyaggregatedloganalysis/f0495b89c2574697b62d4935f9fa6931.png" | relative_url }})

[LogWatch][homepage] [^1] only sends one single summary email per day. This is the first email to open in the morning. It is short, fast to read and gives a clue if something happened during the last 24h. Then, if you have doubts, or if there are other unusual emails, you can dive a little bit further with the daily TripWire email, fwlogcheck email, rkhunter email or logcheck emails. 

Logwatch is very easy to configure, and I do not change any defaults, thus I even do not install any configuration file.

# Prerequisites
This article only depends on the [Generic machine preparation](/pages/en/tags/#debian11-preparation) post serie.

# Installation
Let's install it from the official Linux Debian 11 Bullseye repositories :
```bash
apt-get install -y logwatch
```

# Default configuration
As said previously, I do not need to change the configuration's default values, thus I do not install the default configuration file. Anyway, if I want to change something, I'll install it from the template and alter it.
```bash
#cp /usr/share/logwatch/default.conf/logwatch.conf /etc/logwatch/conf/
```

# Test
This tests not only the log analysis but also the notifications. It can be executed several times, it is idempotent, it does not track the last execution and parses the last 24h.
```bash
/usr/sbin/logwatch --output mail
```

# Materials and links

- [Homepage][homepage] [^1]

# Footnotes

[homepage]: https://sourceforge.net/projects/logwatch/
[^1]: https://sourceforge.net/projects/logwatch/
