---
uid: LinearBenchPowerSupply30V3A
title: FC007 - Alimentation de labo linéaire 30V 3A
author: fcerbell
layout: post
lang: fr
#description:
category: Electronic
tags: [ PSU, Bench, Labo, Power supply, LM723, 2n3055, BD139 ]
#date: 9999-01-01
published: true
---

Voici la conception, réalisation et test d'une alimentation linéaire de
laboratoire 30V 3A sans ventilateur, basée sur un [LM723], deux [2N3055], un
[module chinois multi-metre][module] et deux galvanomètres. Elle dispose d'une
régulation de tension 0-30V et d'une limitation de courant 0-3A.

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.


* TOC
{:toc}

# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/44O2tYXILDA" frameborder="0" allowfullscreen></iframe></center>

# Objectif

Je dispose déjà d'alimentations de labo à découpage, mais elles sont plutôt
bruyantes et génèrent beaucoup de parasites électromagnétiques. J'ai un
transformateur linéaire, un module de mesure 30V/3A, un régulateur [LM723] et
plusieurs [2N3055] en stock. J'ai mis à profit un long week-end pour concevoir
une unité d'alimentation de laboratoire linéaire et je l'utiliserai pour
déboguer mon autre projet en cours : FC005, la charge électronique.

Je vais la construire en utilisant des cartes de prototypage, mais j'ai aussi
conçu le PCB pour m'aider à implanter les composants et à les router. Du coup,
le PCB est aussi disponible dans le projet Kicad ainsi que les fichiers gerbers.

# Spécifications

30V, 3A, sans ventilateur.
Limitation de tension et de courant.
Connexion du négatif ou positif à la terre.
Affichage de la tension et du courant à partir de la sortie.

# Conception

J'ai démarré à partir d'un ancien schéma Français « Office du Kit 147 
Alimentation de laboratoire ». Il ne fonctionnait pas très bien pour 
moi et ne me permettait pas d'ajuster la limitation de courant.

![4f9ed70ddbeac416efd9cdd8332ef83d.png]

Ainsi, j'ai utilisé des schémas de [Electronique 3D (fr)][Electro3D] 
[^1], [Electronics DIY][ElectroDIY] [^2] et la datasheet du 
[LM723][LM723] [^3].

![99f2890d5f280443078ffa07d741c451.png]

Pour faire court, un transformateur 220 vers 30V, suivi par un pont de diodes.
J'ai choisi d'utiliser des [1N5408] car j'en disposais. Elles sont limitées à
3A, mon maximum. J'ai choisi de les doubler pour être prudent. J'avais également
un gros condensateur 4700µF. J'ai inclus un TVS dans mon schéma malgré que je
n'en dispose pas et que je n'ai donc pas pu en implenter dans mon montage, comme
protection supplémentaire.

Le transformateur délivre 30VAC à partir de 230VAC, c'est un vieux
transformateur, maintenant le secteur est à 240VAC, un peu plus qu'autrefois. Le
transformateur délivre donc 35VAC. Cette tension signifie $35V * \sqrt(2) = 49 V$
en pic, chaque diode a une tension de seuil de 1V et le courant doit en
traverser deux, ainsi, la tension finale est de 47VDC. Le circuit est conçu pour
délivrer 30V max et le [LM723] ne peut pas supporter plus de 40V. J'ai donc du
débobiner approximativement 35 spires de l'enroulement secondaire du
transformateur pour en obtenir 30VAC et approximativement 40VDC après le pont de
diodes et le condensateur, à vide.

Le témoin néon dont je dispose comporte déjà une résistance, je n'ai donc pas
besoin d'en ajouter une, mais vous pourriez en avoir besoin si votre témoin n'en
dispose pas déjà.

Le fusible est un 1A (F1A 5x20mm), ce qui est assez. L'alimentation va pouvoir
délivrer au plus 100W et ne devrait pas tirer plus de 0,5A sur le secteur. Le
courant d'appel au démarrage peut être plus important à cause de la partie
inductance du transformateur et du gros condensateur. 1A devrait largement
suffire.

Rien de terrible ici, regardons maintenant la partie régulation.

![cd5ab2532d452407c4025a3ddbdd3ee6.png]

Je dispose déjà de 40VDC mais le module multi-mètre chinois fonctionne entre 
3.5V et 28V. Je n'ai pas de régulateur adapté mais j'ai des diodes Zener 5W.
J'ai utilisé une [1N5348] 11V (D16) pour obtenir $40-11 = 29V$. C'est un 
tout petit peu au-dessus de la specification, mais c'est une tension théorique,
à vide. J'ai rendu cette tension disponible sur J3 pour y connecter
l'alimentation du module.

J'ai choisi d'utiliser des transistors de puissance [2N3055][2N3055] (Q2 et Q3)
pour réguler la puissance, ils sont montés sur des radiateurs pour dissiper la
chaleur. J'ai utilisé des isolateurs en mica, mais je pourrais les retirer et
mettre de la graisse thermique. Chaque transistor dispose de son propre
radiateur, déconnecté, mais je pourrais n'en avoir qu'un seul puisque les
collecteurs des deux transistors sont connectés de toutes façon. Je pourrais
aussi mettre plus de transistors pour pouvoir dissiper plus de puissance, mais
je n'en ai que deux et c'est suffisant pour mon besoin. J'ai ajouté des
résistances d'équilibrage (R4 et R8) à chaque émetteur pour compenser la
différence entre les transistors.

Je ne peux pas les piloter directement depuis le [LM723], il ne peut délivrer
que 150mA. Du coup, j'ai utilisé un [BD139][BD139] (Q1), avec un petit morceau
de métal en tant que radiateur. Même s'il ne devrait pas chauffer beaucoup.
Ainsi, le [LM723] peut piloter directement Q1 et Q1 peut facilement piloter Q2
et Q3 (voire plus). J'ai ajouté les points de connexion J6, J7 et J8 car les
transistors ne se trouveront pas physiquement sur le PCB.

Maintenant, j'ai besoin de réguler la tension. J'ai besoin d'utiliser les
broches 4, 5 et 6 du [LM723]. Pour faire simple, 4 et 5 sont respectivement les
broches inverseuse et non-inverseuse d'un amplificateur opérationel interne. La
datasheet indique : pas plus de 8V entre le GND et les broches 4 et 5, pas plus
de 5V entre les broches 4 et 5. Le [LM723] fournit une tension de référence de
7,15V sur sa broche 6, mais cette broche ne peut pas délivrer plus de 15mA. Ok,
il faut commencer par faire un retour (feedback) de la tension de sortie sur la
broche 4.

![3d4579092e76f4699fc4e029bb70f3bf.png]

J'ai utilisé R2 et R3 pour diviser la tension de sortie et obtenir un retour
proportionel dans les spécifications du [LM723]. J'ai découvert que ce retour a
besoin d'être plus élevé que la tension de seuil de la jonction interne, j'ai
donc utilisé une diode [1N4004][1N4004] (D13) pour remonter le retour de 1V. Au
final, j'ai un retour entre 1V et 4,76V pour une tension de sortie entre 0 et
30V.

Maintenant, j'ai besoin de quelque chose de similaire pour le réglage de la
tension sur l'entrée non-inverseuse du comparateur. J'ai donc utilisé la même
diode [1N4004][1N4004] (D14) pour augmenter la tension de réglage de la même
valeur (1V) et calculé le diviseur de tension pour obtenir une tension de
consigne entre 1V et 4,77V afin d'alimenter l'entrée non-inverseuse de
l'amplificateur opérationel. Le diviseur de tension est dimensionné également
pour limiter la consommation de courant à partir de la broche 6 du [LM723] et ne
pas dépasser ses spécifications (15mA).

Ok, j'ai une correspondance entre le retour et la consigne, ils sont dans les
spécifications du [LM723] et devraient couvrir toute la plage de valeurs pour
une tension de sortie entre 0V et 30V. Regardons maintenant le limiteur de
courant.

Le limiteur de courant se trouve sur les broches 2 et 3 du [LM723]. Si la
différence entre la broche 3 (CSEN) et la 2 (ILIM) est positive, le [LM723] va
commencer à réduire sa sortie sur la broche 10 (Vout). Mais CSEN et ILIM sont
tous les deux connectés à une jonction interne qui va nécessiter également une
tension supérieurs à sa tension de seuil (environ 0,6V).

![bef4802abed42b8674431fa79cd42688.png]

J'ai utilisé une résistance 0,33R5W (R33) en tant que shunt pour récupérer une
différence de tension proportionelle au courant qui la traverse (0-3A). Selon la
loi d'Ohm, $U=R.I$, j'ai :
$$0.33*0 <= U <= 0.33*3$$, soit
$$0 <= U <= 1$$.
Super, mais j'ai besoin que le minimum soit supérieur à la tension de seuil de
la jonction interne, j'ai donc besoin d'une diode acceptant 3A : la [1N5408]
supporte 3A et je préfère la doubler pourdistribuer le courant. Même si la
distribution est déséquilibrée, au pire, aucun des deux n'aura à supporter son
maximum de 3A. Au final, le shunt renvoie $1 <= U <= 2$. Super ! J'ai besoin de
récupérer une fraction de cette valeur comme feedback. Je fais cela grâce à la
résistance variable (RV2) comme diviseur de tension. La valeur est suffisament
élevée comparée à la résistance de shunt pour que le courant qui la traverse
soit très petit. J'ai ajouté une diode [1N4004][1N4004] (pas besoin de puissance
ici) pour avoir la même chute de tension et obtenir un feedback dans la même
plage de valeurs.

Ok, maintenant, la fonctionnalité de limitation de courant est dimensionnée et
configurée.

Enfin, j'ai besoin d'un gros condensateur (environ 1/10 de celui de
redressement, en théorie). J'ai utilisé celui du kit d'origine : 2200µF. J'ai
connecté les ampère-mètres à la sortie, sur la branche négative, c'est
obligatoire par conception du module chinois. J'ai également ajouté un
interrupteur poussoir to court-circuiter la sortie, déclencher la limitation de
courant et mesurer le courant, ce qui permet de régler la consigne.

# Nomenclature

J'ai commencé par la nomenclature et non par la conception car je souhaitait
baser ma conception sur les composants dont je disposais, une approche du bas
vers le haut. Néanmoins, je fournis ici la liste des composants avec leur
datasheet, fabricant, référence fabricant et la référence chez [TME][TME] [^4].
TME est un fournisseur de qualité, peu cher, basé en Europe (Pologne) avec une
livraison rapide.

**Comme je l'ai indiqué, j'ai réutilisé des composants de mon stock, je n'ai pas
commandé ni essayé ceux-ci, il vous faut donc vérifier les valeurs références,
prix et empreintes avant de passer votre commande.**


|Référence| Valeur| Quantité| Datasheet| Fabricant| Réf.Fab.| Réf.TME|
|---|---|---|---|---|---|---|
|C1 |4700uF|1|https://www.tme.eu/Document/280e3fb6bfa2629e98808628203c848c/e-ls.pdf|NICHICON|LLS1J472MELA|LLS1J472MELA|
|C2 |10uF|1|https://www.tme.eu/Document/ee7c1395f0741ee0ee0df84539c3fd29/e-urs.pdf|NICHICON|URS1C100MDD|URS1C100MDD|
|C3 |100pF|1|https://www.tme.eu/Document/e69911e065ed5e1d0ce354af6c563ca3/CC-4.7.pdf|SR PASSIVES||CC-100|
|C4 |2200uF|1||||CE-2200/40A|
|D1 |D_TVS|1|||||
|D13 D14 D3 |1N4004|3|http://www.vishay.com/docs/88503/1n4001.pdf|VISHAY|||
|D16 |1N5348 11V 5W|1|https://www.tme.eu/Document/01c8e2b3cf396fe61d216c295d761a68/1N53_ser.pdf|ON SEMICONDUCTOR|1N5348BG|1N5348BG|
|D10 D11 D12 D2 D4 D5 D6 D7 D8 D9 |1N5408|10|http://www.vishay.com/docs/88516/1n5400.pdf|VISHAY|1N5408-E3/54|1N5408-E3/54|
|F1 |Fuse|1|||||
|HS1 |Heatsink|1|banggood.com/182x100x45mm-Aluminum-Heat-Sink-Heatsink-For-High-Power-LED-Amplifier-Transistor-Cooler-p-1142259.html|Banggood|1142259||
|J1 |Vcc|1|||||
|J2 |GND|1|||||
|J3 |Module+|1|||||
|J5 |Vout+|1|||||
|J6 |3055-Coll|1|||||
|J7 |3055-Base|1|||||
|J8 |3055-Emm|1|||||
|J9 |Vout-|1|||||
|NE1 |Red|1||NINIGI||NI-1RD|
|Q1 |BD139|1|http://www.st.com/internet/com/TECHNICAL_RESOURCES/TECHNICAL_LITERATURE/DATASHEET/CD00001225.pdf|STMicroelectronics|BD139|BD139|
|Q2 Q3 |2N3055|2|http://www.onsemi.com/pub_link/Collateral/2N3055-D.PDF|ON SEMICONDUCTOR|2N3055G|2N3055G|
|R1 |6K2|1|||||
|R2 |6K8|1|||||
|R3 |47K|1|||||
|R4 R8 |R33 5W|2||ROYAL OHM|KNP05SJ033KA10|KNP05WS-0R33|
|R5 |R33 5W|1||ROYAL OHM|KNP05SJ033KA10|KNP05WS-0R33|
|RV1 RV2 |10K|2|https://www.tme.eu/Document/e13a4eb615fc162fef410c3ed914459b/SR_Passives-POT2218M.pdf|SR PASSIVES|POT2218M-10K|POT2218M-10K|
|SW1 |SW_SPST|1|https://www.tme.eu/Document/f90695597f0f1676a8d370239f391d47/1811.1102.pdf|Marquardt|01811.1102-02|1811.1102|
|SW2 |AmpSet_3A|1|||||
|T1 |240-30-90VA|1|https://www.tme.eu/Document/c4aa10c935ccc8c890c2de085c552cbb/TMM-EN.pdf|BREVE TUFVASSONS|TMM63/A230/36V|TMM63/A230/36V|
|U1 |LM723_DIP14|1|http://www.ti.com/lit/ds/symlink/lm723.pdf|TEXAS INSTRUMENTS|UA723CN|UA723CN|

# Réalisation

Rien de terrible ici, un vieux boitier, une plaque de prototypage, un panneau
imprimé en 3D... J'ai utilisé des connecteurs [XT60], [Dean] et banane
[3,5mm][banana] entre le panneau avant, les cartes et le transformateur. Ces
petits connecteurs peuvent supporter pas mal de courant, ils sont utilisé sur
les drones avec des batteries LiPo 2,2A.h 35C !

J'ai ajouté deux galvanomètres. Ils ne sont pas si précis, mais mettent bien
mieux en évidence les variations que leurs homologues digitaux. J'ai un premier
interrupteur pour connecter la terre à la borne positive, négative ou pour
garder l'alimentation flottante. Le second interrupteur est un poussoir pour
court-circuiter la sortie et laisser passer le maximum de courant autorisé,
ainsi les ampèremètres affichent la consigne imposée et on peut effectuer le
réglage de limitation. Cet interrupteur doit impérativement pouvoir supporter
3A. J'utilise enfin deux potentiomètres 10 tours pour régler les limites de
tension et de courant.

# Tests

Toutner les potentiomètrs au minimum (vérifier à l'Ohm-mètre). Vérifier que
l'interrupteur de court-circuit n'est pas fermé. Allumer, lé témoin néon devrait
s'allumer, les galvanomètres devraient rester vers 0, la tension devrait être
de l'ordre de 3V et le courant de l'ordre de 0,013A. Vérifier la tension aux
bornes de C1, on devrait lire 40VDC.

Si on tourne le potentiomètre de tension, rien ne devrait vraiment changer, car
la limite de courant est trop basse. Augmenter la limite de courant de 2 ou 3
tours et modifier la limite de tension. La tension devrait s'élever lentement.
On peut essayer l'interrupteur de court-circuit pour vérifier le réglage de
limitation de courant et l'ajuster.

Attention, le limiteur de courant peut être réglé au-delà de 3A, mais le reste
du circuit ne le supportera pas  plus de quelques secondes, le module 
multi-mètre va fondre et les transistors de puissance vont frire.

Si vous disposez d'un oscilloscope, vous pouvez vérifier la chute de tension aux
bornes de C1 lors d'un court circuit à 3A :

![SDS00028.png]

et la propreté (ou non) de la sortie entre 2 et 25V avec ou sans court-circuit :

![SDS00029.png]

# Supports et liens

- [Video][video]
- [Kicad file][kicadfiles]
- [http://www.electronique-3d.fr/Le_regulateur_LM723.html][Electro3D]
- [http://electronics-diy.com/30v-10a-variable-bench-power-supply.php][ElectroDIY]

# Notes de bas de page

[^1]: [http://www.electronique-3d.fr/Le_regulateur_LM723.html](http://www.electronique-3d.fr/Le_regulateur_LM723.html)
[^2]: [http://electronics-diy.com/30v-10a-variable-bench-power-supply.php](http://electronics-diy.com/30v-10a-variable-bench-power-supply.php)
[^3]: [http://www.ti.com/lit/ds/symlink/lm723.pdf](http://www.ti.com/lit/ds/symlink/lm723.pdf)
[^4]: [https://www.tme.eu/fr/][tme]

[Electro3D]: http://www.electronique-3d.fr/Le_regulateur_LM723.html
[ElectroDIY]: http://electronics-diy.com/30v-10a-variable-bench-power-supply.php
[LM723]: http://www.ti.com/lit/ds/symlink/lm723.pdf
[1N5348]: https://www.tme.eu/Document/01c8e2b3cf396fe61d216c295d761a68/1N53_ser.pdf
[1N5408]: http://www.vishay.com/docs/88516/1n5400.pdf
[1N4004]: http://www.vishay.com/docs/88503/1n4001.pdf
[BD139]: http://www.st.com/internet/com/TECHNICAL_RESOURCES/TECHNICAL_LITERATURE/DATASHEET/CD00001225.pdf
[2N3055]: http://www.onsemi.com/pub_link/Collateral/2N3055-D.PDF
[Module]: https://www.banggood.com/RIDEN-0-33V-0-3A-Four-Bit-Voltage-Current-Meter-DC-Double-Digital-LED-Display-Voltmeter-Ammeter-p-1060303.html
[XT60]: https://www.banggood.com/search/xt60.html
[Dean]: https://www.banggood.com/search/dean.html
[banana]: https://www.banggood.com/50-Pairs-3_5mm-Gold-Bullet-Banana-Connector-Plug-Male-Female-For-ESC-Battery-Motor-p-996353.html
[TME]: https://www.tme.eu/fr/

[4f9ed70ddbeac416efd9cdd8332ef83d.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/6c8af79c25694315a48e339dd09a2ffd.png
[99f2890d5f280443078ffa07d741c451.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/85540f3733564585b3b51f658793b9a2.png
[cd5ab2532d452407c4025a3ddbdd3ee6.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/f70576f67fc94587b3dff3c7e29643d8.png
[3d4579092e76f4699fc4e029bb70f3bf.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/fe55a9c6a5834f0e8ab85cd9410ec237.png
[bef4802abed42b8674431fa79cd42688.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/c8286368da6a461daef70923b3982ce0.png
[SDS00028.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/f1b4caec56ad4f68abc87e8fbcee2d27.png
[SDS00029.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/c8aeab09b1644206a9dc9f5d5c2ba633.png

[Video]: https://youtu.be/44O2tYXILDA "Demonstration video recording"

[kicadfiles]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/FC007-BenchPowerSupply.zip "kicad project"
