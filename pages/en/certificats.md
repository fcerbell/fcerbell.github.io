---
uid: certificats
title: SSL/TLS/GPG
layout: page
description: My SSL/TLS certificate, with the certification authority chain. 
category: Security
tags: [ pki ]
---
<p>All my websites and services are using SSL/TLS certificates to protect our
security of you and me.  All these certificates are signed by my own
Certification Authority (CA) which is not embedded in the CA list of the
browsers (I'd have to pay for that). Instead of being asked for a confirmation
each time, you can just add my CA in your browser. <br/>
Here are the different options</p>
  
<h3>Import the CA chain</h3>

<p>Here is the single file to add to your browser <em>with the ability to
certify every kind of service</em> (user, email, websites, ...) : <a
href="{{ "/assets/pages/CERBELLE_SSL-cachain.pem" | relative_url }}">CERBELLE_SSL-cachain.pem</a></p>

<h3>Import the two CA certificates</h3>

<p>You can also import each of the two certificates contained in the chain,
either in the DER or PEM format depending on your browser.<br/>
    <ul>
        <li>CERBELLE_ROOT in <a href="{{ "/assets/pages/CERBELLE_ROOT-cacert.pem" | relative_url }}">PEM</a> or in <a href="{{ "/assets/pages/CERBELLE_ROOT-cacert.der" | relative_url }}">DER</a></li>
        <li>CERBELLE_SSL in <a href="{{ "/assets/pages/CERBELLE_SSL-cacert.pem" | relative_url }}">PEM</a> or in <a href="{{ "/assets/pages/CERBELLE_SSL-cacert.der" | relative_url }}">DER</a></li>
    </ul>
</p>
