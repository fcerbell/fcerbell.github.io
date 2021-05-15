---
uid: certificats
title: Certificats
layout: page
description: Mes certificats, avec leur chaine de certification.
mainmenu: true
category: Securité
tags: [pki]
---
<p>Tous mes sites et services utilisent des certificats SSL/TLS pour protéger
notre sécurité à vous et moi. Tous ces certificats sont signés par ma propre
autorité de certification (CA) qui n'est pas embarquée dans la liste de CA des
navigateurs (je devrais payer pour cela). Au lieu d'être sollicité par votre
navigateur pour des confirmations à chaque visite, vous pouvez simplement
ajouter ma CA dans votre navigateur.<br/>
Voici les différentes possibilités :</p>
  
<h3>Importer la chaine de certification</h3>

<p>Voici l'unique fichier à ajouter à votre navigateur <em>avec l'autorisation
de certifier tout type de service</em> (email, utilisateur, site web, ...) :<a
href="{{ "/assets/pages/CERBELLE_SSL-cachain.pem" | relative_url }}">CERBELLE_SSL-cachain.pem</a></p>

<h3>Importer les certificats de mes deux CA</h3>

<p>Vous pouvez aussi importer individuellement les deux certificats de la
chaine, soit en format DER, soit au format PEM, en fonction de votre
navigateur.<br/>
    <ul>
        <li>CERBELLE_ROOT : <a href="{{ "/assets/pages/CERBELLE_ROOT-cacert.pem" | relative_url }}">PEM</a> ou <a href="{{ "/assets/pages/CERBELLE_ROOT-cacert.der" | relative_url }}">DER</a></li>
        <li>CERBELLE_SSL : <a href="{{ "/assets/pages/CERBELLE_SSL-cacert.pem" | relative_url }}">PEM</a> ou <a href="{{ "/assets/pages/CERBELLE_SSL-cacert.der" | relative_url }}">DER</a></li>
    </ul>
</p>
