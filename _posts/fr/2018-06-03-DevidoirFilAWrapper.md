---
uid: WrappingWireDispenser
title: Distributeur de fil à wrapper imprimé en 3D
description:
category: 3DPrinting
tags: [ Wrapping, Wire, Dispenser, 3D, Printing, Creality, CR-10, OpenSCAD, Design, PLA ]
---

J'utilise souvent du fil à wrapper pour mes projets électoniques. Soit
je wrappe les fils pour un prototypage rapide et je peux déwrapper,
soit je les soude quand je souhaite un prototype plus durable. Banggood
vends 8 couleurs de [bobine de 300m de fil à wrapper à 8€
pièce][Banggood], j'en ai acheté une de chaque et j'avais besoin d'un
distributeur pratique.

Vous pouvez trouver les liens à la <a href="#supports-et-liens">fin de
cet article</a>.

* TOC
{:toc}

# Résultat

![Result][result.jpg]

# Conception

Je me suis inspiré de la [Chaîne Youtube][CyrobChan] et du [site
internet][CyrobOrg] de Philippe Demerliac.

![Spools][spools.jpg]

J'ai toujours utilisé Blender3D pour mes conceptions d'objets 3D, mais
j'ai lu quelquepart qur [Blender][BlenderOrg] était mieux pour les
modélisations du vivant et que [OpenSCAD][OpenSCADOrg] était meilleur
pour les pièces mécaniques. J'ai donc décidé de lui donner une chance.
De plus, je publie mes modèles sur [mon compte
Thingiverse][FCerbellThingiverse] et ils savent utiliser les
conceptions OpenSCAD comme modèles que les utilisateurs peuvent
personnaliser en ligne.

Je voulais quelquechose de simple, tel qu'un bloc de deux bobines sur
quatres. Je voulais imprimer sans support et obtenir un objet
assemblable sans vis. J'ai commencé par concevoir un cube en U avec
des trous sur chaque côté et un tube avec un filetage. Bien qu'il soit
possible d'imprimer des filetages, ce n'est pas toujours facile de le
faire précisément sur tout modèle d'imprimante et avec différents
matériaux. J'ai donc préféré retirer le filetage et j'ai remplacé le
trou par une fente en forme de trou de serrure pour clipser le tube.
Ensuite, je ne voulais pas que plusieurs bobines tournent quand je
tire un des fils et j'ai ajouté des cloisons intercalaires. Enfin,
j'ai arrondi le haut des côtés pour les rendre moins moches.

J'avais la base. Comme je suis curieux, je voulais essayer de publier
un « customizer » dans Thingiverse. J'ai donc rendu toutes les
constantes paramétrables et documenté les variables. Puis j'ai
commencé à réfléchir aux autres utilisateurs. Mon besoin est d'avoir
un dévidoir posé à plat sur la table. Mais ce besoin peut être amené à
changer avec le temps et d'autres utilisateurs peuvent vouloir
l'accrocher au mur. J'ai donc rendu l'arrière carré pour pouvoir le
poser verticalement. J'ai également ajouté des trous de vis pour
l'accrocher au mur.

![First design][firstdesign.jpg]

Je n'ai toujours pas trouvé de solution pour bloquer les fils. L'idée
est d'utiliser une éponge ou une mousse entre deux parties imprimées
et d'y faire passer les fils. J'ai décidé d'utiliser les extrémités
carrées des côtés pour y fixer le support de la mousse mais comme le
dévidoir peut être placé à la verticale, cela ne serait pas pratique
d'avoir la mousse au raz de la table, j'ai donc rendu carré la seconde
extrémité des côtés.

Je n'ai pas encore modélisé ce support de mousse, n'en ayant pas un
besoin urgent pour le moment.

C'est tout pour la conception.

# Impression

J'ai eu une Creality CR-10 l'année dernière
et j'en suis vraiment très content. J'ai
rencontré des difficultés mais je les ai
résolues par l'apprentissage. Cela signifie
que les problèmes n'étaient pas dûs au
matériel mais à l'utilisateur ! ;)

L'ABS est plus solide, plus résistant à
l'humidité et à la température, a de
meilleures propriétés mécaniques et il est
plus flexible que le PLA, il ne casse pas
aussi facilement. Mais il est également
plus compliqué à imprimer. Comme mon
dévidoir est destiné à rester en intérieur,
sur mon bureau, j'ai choisi de l'imprimer
en PLA avec la bobine d'essai (350g) de
[PLA blanc ArianePlast][ArianePlastWhitePLA].

J'ai utilisé [Cura][UltimakerCura] comme trancheur[^1]

* Heuteur de couche = 0.3mm car je n'ai pas
  besoin d'un objet à la finition parfaite.

* Remplissage = 50% avec des triangles,
  c'est un peu plus long maisj'ai besoin
  d'un peu de solidité et de rigidité.

* 4 périmètres par défaut dans toutes les
  directions.

* pas de support, seulement un coutour[^2]
  car la face inférieur est relativement
  large dans mon cas (15x15 cm) et les
  tubes doivent bien tenir.

* Correction XY = -0.3mm **très important**
  car toutes les pièces sont conçues sans
  jeu pour les assembler. Sans ce réglage,
  étant donné que l'extrudeur déborde un
  peu du volume de l'objet, il serait
  difficile d'assembler les parties
  ensemble (les trous seraient un peu trop
  petits et les picots un peu trop larges).

* Vitesse = 45 mm/s car mon stepper a un
  peu de mal à pousser mon PLA plus
  rapidement avec une température de 215°C.
  Si j'augmente la température, le PLA
  laisse des cheveux lors des déplacements
  (retractation de 4mm) et si e rétracte
  plus, mon extrudeur va se boucher.

Avec ces réglages, cela m'a pris environ
30h pour tout imprimer, cela peut sembler
long, mais c'est très rapide pour obtenir
un objet répondant exactement à mon besoin
spécifique.

# Supports et liens

Voici le lien vers la conception sur
Thingiverse. Vous pouvez utiliser le lien «
customizer » pour l'adapter à votre besoin
sans devoir télécharger le source et
l'éditer dans OpenSCAD.



| Lien | Description |
|---|---|
| [Fichier de profil Cura][MyWrappingWireDispenser.curaprofile] | Les réglages que j'ai utilisé dans Cura sur ma Creality CR-10 avec un extrudeur 0.4 mm et du PLA ArianePlast blanc |
| [Source OpenSCAD][MyWrappingWireHolder.scad] | Le fichier source de ma conception, au format SCAD |
| [Customizer Thingiverse][Customizer] | Lien vers la page de personnalisation Thingiverse de mon objet |
| [Page sur Thingiverse][Thing] | Page de l'objet sur Thingiverse |
| [Fichier STL][MyWrappingWireHolder.stl] | Le fichier STL que j'ai imprimé pour mon besoin avec les 8 bobines Banggood |



# Footnotes

[spools.jpg]: {{ "/assets/posts/" | append: page.uid | append:"/spools.jpg" | relative_url }} "Wrapping wire spools"
[firstdesign.jpg]: {{ "/assets/posts/" | append: page.uid | append:"/firstdesign.jpg" | relative_url }} "First design"
[result.jpg]: {{ "/assets/posts/" | append: page.uid | append:"/result.jpg" | relative_url }} "Result"
[Banggood]: https://www.banggood.com/0_55mm-Circuit-Board-Single-Core-Tinned-Copper-Wire-Wrap-Electronic-Wire-Fly-Wire-Dupont-Cable-Jumper-Cable-8-Color-Available-p-1121767.html
[CyrobOrg]: http://philippe.demerliac.free.fr/Misc.htm
[CyrobChan]:https://www.youtube.com/channel/UC5QPFDZ3Y4ylkkGJc6Y1OOA
[ArianePlastWhitePLA]: https://www.arianeplast.com/pla-format-350g/362-pla-blanc-3d-filament-arianeplast-350g.html
[BlenderOrg]: https://www.blender.org/ "Blender 3D website"
[OpenSCADOrg]: http://www.openscad.org/ "OpenSCAD website"
[FcerbellThingiverse]: https://www.thingiverse.com/fcerbell/designs "My space on Thingiverse"
[UltimakerCura]: https://ultimaker.com/en/products/ultimaker-cura-software "Cura slicer homepage"
[MyWrappingWireHolder.scad]: {{ "/assets/posts/" | append: page.uid | append:"/MyWrappingWireHolder.scad" | relative_url }} "MyWrappingWireHolder.scad"
[MyWrappingWireDispenser.curaprofile]: {{ "/assets/posts/" | append: page.uid | append:"/MyWrappingWireDispenser.curaprofile" | relative_url }} "MyWrappingWireDispenser.curaprofile"
[MyWrappingWireHolder.stl]: {{ "/assets/posts/" | append: page.uid | append:"/MyWrappingWireHolder.stl" | relative_url }} "MyWrappingWireHolder.stl"
[Thing]: https://www.thingiverse.com/thing:2942689
[Customizer]: https://www.thingiverse.com/apps/customizer/run?thing_id=2942689
[^1]: slicer
