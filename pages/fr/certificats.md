---
uid: certificats
title: Certificats
layout: page
description: Mes certificats, avec leur chaine de certification.
mainmenu: true
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
href="{{ "/assets/pages/cerbelle-cachain.pem" | relative_url }}">cerbelle-cachain.pem</a></p>

<h3>Importer les certificats de mes deux CA</h3>

<p>Vous pouvez aussi importer individuellement les deux certificats de la
chaine, soit en format DER, soit au format PEM, en fonction de votre
navigateur.<br/>
    <ul>
        <li>cerbelle-root <a href="{{ "/assets/pages/cerbelle-root.crt" | relative_url }}">PEM</a></li>
        <li>cerbelle-servers <a href="{{ "/assets/pages/cerbelle-servers.crt" | relative_url }}">PEM</a></li>
        <li>sd-102086.dedibox.fr <a href="{{ "/assets/pages/sd-102086.dedibox.fr.crt" | relative_url }}">PEM</a></li>
    </ul>
</p>
