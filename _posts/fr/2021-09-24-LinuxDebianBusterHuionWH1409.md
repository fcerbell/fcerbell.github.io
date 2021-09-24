---
uid: LinuxDebianBusterHuionWH1409
title: Avis, installation et utilisation de la tablette Huion Inspiroy WH1409 sous Debian
description: Comment installer, configurer et utiliser une tablette graphique Huion Inspiroy WH1409 sous Linux Debian Buster. Installation d'un pilote(driver), configuration du serveur XOrg, configuration des paramètres de la tablette pour les boutons, configuration multi-écran. Configuration et utilisation dans Blender, Krita, OpenToonz, Compiz, StoryBoarder, Zoom, Microsoft Teams, Google Hangout, GoToMeeting, BigBlueButton, Open Broadcast Studio (OBS), Compiz...
category: Informatique
tags: [ Linux, Debian, Buster, Tablette graphique, Huion, WH1409, Inspiroy, Pilotes, Drivers, X11, Xorg, Compiz, Krita, Blender, OpenToonz, StoryBoarder, Zoom, Microsoft Teams, Teams, Google Hangout, Hangout, Citrix GoToMeeting, GoToMeeting, BigBlueButton, OBS, Open Broadcast Studio, Digimend, Compiz ]
---
Comment installer, configurer et utiliser une tablette graphique [Huion][Huion_site] Inspiroy [WH1409][WH1409_site] sous Linux [Debian][Debian_site] Buster. Installation d'un pilote (driver), configuration du serveur XOrg, configuration des paramètres de la tablette pour les boutons, configuration multi-écran. Configuration et utilisation dans [Blender][Blender_site], [Krita][Krita_site], [OpenToonz][OpenToonz_site], Compiz, [StoryBoarder][StoryBoarder_site], [Zoom][Zoom_site], Microsoft [Teams][Teams_site], Google [Hangout][Hangout_site], [GoToMeeting][GoToMeeting_site], BigBlueButton, Open Broadcast Studio (OBS), Compiz ...

Vous pouvez trouver des liens vers les enregistrements vidéo et les supports
imprimables associés à la <a href="#supports-et-liens">fin de cet article</a>.

* TOC
{:toc}


# Vidéo

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/wofhUDzIUtU" frameborder="0" allowfullscreen></iframe></center>

# Mon besoin

Je travaille en télétravail à temps plein depuis plus de 10 ans, j'avais acheté une mini tablette
graphique à 15 € en grande surface pour tester. Je ne l'ai jamais vraiment utilisée, je ne l'ai
probablement jamais configurée correctement, ne sachant pas quoi attendre d'une tablette et
encore moins de celle-ci. J'ai décidé d'acheter une véritable tablette dont je pouvais être sûr du
niveau à attendre, à moi de la configurer correctement. 

J'ai plusieurs utilisations : 
- Annoter l'écran lorsque je fais des présentation à distance, quel que soit le logiciel ([Zoom][Zoom_site], [Teams][Teams_site],
  [GoToMeeting][GoToMeeting_site], Google [Hangout][Hangout_site], ...)
- Faire des schémas et animations 2D à partager ([Gimp][Gimp_site], [Krita][Krita_site], [OpenToonz][OpenToonz_site], [StoryBoarder][StoryBoarder_site])
- M'aider en modélisation 3D (Sculpter dans [Blender][Blender_site] 3D)
- Pas ou très peu de retouche photo ([Gimp][Gimp_site])

Par ailleurs, je n'utilise que Linux [Debian][Debian_site], elle doit donc impérativement être supportée par Linux et
ses options accessoires (boutons, molettes, ...) aussi, si possible. J'utilise un triple affichage 3 x
27 pouces FHD, et la tablette doit avoir une taille physique en rapport. 

# Pourquoi Huion Inspiroy WH1409

J'ai éliminé les tablettes à écran intégré, car j'ai déjà assez d'écrans et de cables. De plus, je n'ai
plus de sortie video disponible, il me faudrait acheter une carte graphique supplémentaire. La *[Gaomon][Gaomon_site]*
aurait pu convenir.

J'ai été frustré par la taille de ma première mini-tablette, il me faut donc au minimum une taille A5.
Mais vu la taille de mon affichage (même en limitant à un seul écran), cela risque de ne pas être
confortable. En plus, les formats A5 ne disposent souvent pas de boutons d'extension. 

Il est évident qu'avec une telle configuration, je n'ai pas une utilisation nomade, le sans-fil n'est
pas un critère, mais il faut qu'une connexion filiaire soit possible (moins de problèmes de
configuration et de latence).

Avec tous ces critères, il y a évidemment mon bonheur dans la marque *[Wacom][Wacom_site]*, mais je me suis fixé un
budget de 100€ max. Il reste donc principalement les *[XP-Pen][XP-Pen_site]*, *[Huion][Huion_site]* et *[Gaomon][Gaomon_site]*. Après quelques
recherches, lectures d'avis et d'articles. Principalement celui de [David Revoy][David Revoy_site], artiste
professionel avec une configuration similaire à la mienne, je me suis orienté sur le modèle *[WH1409][WH1409_site]* de
chez *[Huion][Huion_site]*.

Elle est grande, mais j'ai de la place sur mon bureau et elle peut éventuellement tenir dans un grand
sac à dos pour ordinateur. Elle dispose de 12 boutons programmables, même si je m'attendais à avoir des
difficultés à les utiliser d'après l'article de David. Elle se connecte avec un fil en USB ou sans fil
avec une clé fournie (jamais testée). Elle est fournie avec plein de mines de rechange. Le stylet gère
plus de 8000 niveaux de pression, mais il a aussi des défauts : il est actif et a besoin d'être
rechargé, il ne gère pas l'inclinaison, il n'a pas de gomme. Les défauts sont faibles, je n'ai pas vu un
seul avis se plaignant de l'autonomie d'une charge, je n'ai pas vraiment besoin de la gestion de
l'inclinaison et l'utilisation d'une touche gomme et d'une touche annulation à programmer sur la
tablette me semble bien plus ergonomique que de retourner le stylet pour gommer.

Commandée sur *[Amazon][Amazon_site]*, car *[CDiscount][CDiscount_site]* était beaucoup plus cher et livrait plus lentement, elle est
arrivée dans un triple emballage depuis un entrepôt Allemand. On peut déjà trouver des vidéos de
déballage/unboxing sur Internet, je ne le ferai donc pas.

# Installation sans pilote

Avec le noyau 4.19, la tablette est immédiatement reconnue et gérée comme un périphérique de pointage
par le système. Cependant, les 12 boutons sur la tablette ne sont pas programmables et correspondent à
une souris avec 16 boutons... Il va falloir configurer, lorsque c'est possible, chaque application. De
même, le seuil de pression, la courbe de pression, et d'autres paramètres de confort ne sont pas
configurables.

# Installation avec le pilote noyau Digimend et X11 Wacom

J'ai donc choisi d'utiliser le driver [Digimend][digimend] que j'utilisais déjà avec mon ancienne
tablette, pour faire reconnaitre celle-ci comme une tablette *[Wacom][Wacom_site]*, et disposer des fonctionnalités
supplémentaires de ce pilote. Dans l'historique des notes de version, on peut voir que la marque et le
modèle de ma tablette sont gérés depuis les 5 dernières versions, je m'attends donc à une certaine
maturité.

Pour installer ce driver noyau, il suffit de télécharger et d'installer le paquet *[Debian][Debian_site]*. Il va
installer, par ses dépendances, le pilote X11 pour *[Wacom][Wacom_site]* et les outils auxquels j'ajoute *xinput* :
``` bash
wget -c https://github.com/DIGImend/digimend-kernel-drivers/releases/download/v10/digimend-dkms_10_all.deb
sudo gdebi -n digimend-dkms_10_all.deb
sudo apt-get install xinput
```

Je force le déchargement des pilotes éventuellement déjà en mémoire :
```bash
modprobe -r hid-kye hid-uclogic
```

Après quelques secondes, tout fonctionne comme avant, mais la commande `xsetwacom list` ne détecte pas
de tablette *wacom* dans X11. Le stylet et la tablette sont pourtant bien trouvés par X11 comme on peut
le voir avec la commande `xinput`, mais pas à travers le pilote *wacom*.  Il faut indiquer à X11
d'utiliser le pilote *wacom* et non le pilote *evdev*. Pour cela, il faut utiliser le fichier de
configuration fourni par *Digimend* et le placer dans la configuration de X11 :
```bash
mkdir /etc/X11/xorg.conf.d
ln -s /usr/share/X11/xorg.conf.d/50-digimend.conf /etc/X11/xorg.conf.d/
```

Pas d'autre choix que de redémarrer X11 pour le prendre en compte. Le plus simple est de redémarrer
l'ordinateur, ça marchera pour tout le monde, sinon, il faut redémarrer le gestionnaire de connexion que
vous utilisez (*[lightdm][lightdm_site]* dans mon cas), attention, cette commande ferme brutalement votre session et vos
applications ouvertes sans sauvegarder :
```bash
systemctl restart lightdm.service
```

Suite à cela, `xsetwacom list` fonctionne et trouve le stylet, la tablette et un troisième périphérique
logique lié à cette tablette que je n'ai pas identifié : le *Touch Strip Pad*, mais dont je n'ai pas le
besoin. On constate que ces périphériques pris en charge par le driver *wacom* sont ensuite gérés par
X11 grâce à la commande `xinput`... Super ! Plus qu'à configurer.

# Configuration multi-écrans

Il faut savoir que la surface de la tablette couvre la totalité du bureau, le mien étant large de 3
écrans FHD. Cela signifie que je dois faire de tout petits déplacements horizontaux par rapport à mes
déplacements verticaux. C'est acceptable dans certains cas, mais pas très naturel. Je vais donc affecter
la tablette à un des trois écrans. Il y a plusieurs possibilités. J'utilise celle avec la matrice de
correspondance et j'ai configuré des icones de raccourci sur mon pannel [XFCE][XFCE_site].

## xinput et une matrice de conversion

C'est ma favorite car : je ne connais pas mes écrans par leur nom, mais par leur position. Je souhaite
affecter la tablette à celui de gauche, du milieu de droite ou à tout le bureau, peu importe leur nom et
il pourrait changer si je modifie mes branchements. Je n'ai pas d'écran au-dessus ou en-dessous, mais
cette méthode permet de les gérer aussi. Enfin, on peut effectuer des corrections de paralaxe ou de
proportions de déplacement. Enfin, le plus important, on peut, avec cette méthode, affecter la surface
de la tablette à une zone du bureau plus petite qu'un écran ou débordant sur plusieurs écrans.

Il suffit de connaître trois informations :
- le nom ou l'id du stylet, fourni par `xinput` (*HID 256c:006e stylus* dans mon cas)
- le pourcentage horizontal du bureau à partir duquel la surface de la tablette est associée
- le pourcentage horizontal de bureau sur lequel la surface de la tablette agit

J'ai trois écran :
- pour celui de gauche, il commence à 0% et s'étend sur 33%
  ```bash
  xinput set-prop "HID 256c:006e stylus" --type=float "Coordinate Transformation Matrix" 0.333333 0 0 0 1 0 0 0 1'
  ```
- pour celui du centre, il commence à 33% et s'étend sur 33%
  ```bash
  xinput set-prop "HID 256c:006e stylus" --type=float "Coordinate Transformation Matrix" 0.333333 0 0.333333 0 1 0 0 0 1'
  ```
- pour celui de droite, il commence à 66% et s'étend sur 33%
  ```bash
  xinput set-prop "HID 256c:006e stylus" --type=float "Coordinate Transformation Matrix" 0.333333 0 0.666666 0 1 0 0 0 1'
  ```
- pour le bureau complet, il commence à 0% et s'étend sur 100%
  ```bash
  xinput set-prop "HID 256c:006e stylus" --type=float "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1'
  ```

## xinput map-to-output

L'autre possibilité avec `xinput` est d'utiliser le nom des écrans. Dans mon cas, ils sont tous
connectés à une seule carte graphique en HDMI, DVI et Display Port. On peut récupérer les noms de
plusieurs manière, j'utilise `xrandr` :
```bash
root@toutatis:~# xrandr | grep connected
DVI-D-0 connected primary 1920x1080+1920+0 (normal left inverted right x axis y axis) 598mm x 336mm
HDMI-0 connected 1920x1080+0+0 (normal left inverted right x axis y axis) 598mm x 336mm
DP-0 connected 1920x1080+3840+0 (normal left inverted right x axis y axis) 598mm x 336mm
DP-1 disconnected (normal left inverted right x axis y axis)
```

Je peux donc utiliser donc les commandes `xinput` suivantes pour associer la tablette à un seul écran,
mais je n'ai pas de commande pour l'associer à plusieurs écrans, à une partie d'un écran ou à tout le bureau :
```bash
xinput map-to-output "HID 256c:006e stylus" "HDMI-0"
```
```bash
xinput map-to-output "HID 256c:006e stylus" "DVI-D--0"
```
```bash
xinput map-to-output "HID 256c:006e stylus" "DP-0"
```

## xsetwacom MapToOutput

Il est possible d'obtenir le même résultat avec la commande `MapToOutput` de `xsetwacom` qu'avec 
l'option `map-to-output` de `xinput`. Techniquement, la correspondance ne se fait pas au même niveau
dans l'enchainement des couches logicielles, mais le résultat est le même. Je ne l'utilise pas du tout,
mais c'est aussi possible.

# Configuration des boutons

Actuellement, les boutons du stylet sont configurés comme les trois boutons de la souris (gauche,
molette et droit). Personnellement, cela me convient.

Par contre, les boutons de la tablette sont configurés comme les 16 boutons d'une souris. J'aimerais
pouvoir les configurer et reconfigurer de manière complètement arbitraire pour m'adresser à mon
gestionnaire de fenêtres (Compiz) pour lancer des commandes, à [Blender][Blender_site], à [Krita][Krita_site], ... pour effectuer des
actions.

Je n'ai pas encore beaucoup d'expérience et je ne sais pas encore de quelle commande ou action je vais
avoir le plus besoin. Je prévois donc :
- un bouton undo (Ctrl-Z), un bouton redo (dépendant de l'application, soit Ctrl-Y ou Shift-Ctrl-Z)
- quatre boutons pour changer l'affectation de la surface à chaque écran ou au bureau

Un bouton peut remonter une séquence d'événement d'enfoncement ou de relachement d'une touche clavier ou d'un bouton
souris, éventuellement accompagné de modifieurs (Alt, Shift, Ctrl, ...). Par exemple, pour simuler
l'annulation de la dernière action dans la plupart des logiciels, il faut faire *Ctrl-Z*, ce qui
correspond dans la réalité à :

1. Appuyer sur *Ctrl* gauche ou droit
2. Appuyer sur *Z*
3. Relacher *Z*
4. Relacher *Ctrl*

Dans certains logiciels, il est possible de configurer l'action à effectuer en fonction de l'appui sur
un des boutons d'un périphérique de pointage spécifique. Ce n'est pas toujours possible d'avoir cette
logique et encore moins souvent de pouvoir choisir le périphérique. Parfois, on peut le faire dans le
gestionnaire de fenêtre ou de sessions, ou utiliser `xbindkeys` pour être indépendant du gestionnaire
utilisé. Je préfère demander au pilote de générer la séquence, quitte à avoir une configuration
spécifique du pilote pour chaque application.

Pour indiquer au pilote de faire *Undo* (la séquence décrite) lorsque j'appuie sur le bouton 1 de la
tablette (pas du stylet), je dois utiliser les modifieurs connus et listés par `xsetwacom --list
modifiers` et les symboles d'appui/relachement (+/-) :

```bash
xsetwacom --set 'HID 256c:006e Pad pad' Button 1 key +ctrl +z -z -ctrl
```

En revanche, sous *Cinelerra*, il y a plusieurs *Undo*, un sur *Z* et un sur *Shift-Z* :
```bash
xsetwacom --set 'HID 256c:006e Pad pad' Button 1 key +z -z
```
ou
```bash
xsetwacom --set 'HID 256c:006e Pad pad' Button 1 key +shift +z -z -shift
```

Pour le bouton *Redo*, sous certains logiciels (par exemple [Gimp][Gimp_site] ou LibreOffice), c'est *Ctrl-Y* :
```bash
xsetwacom --set 'HID 256c:006e Pad pad' Button 2 key +ctrl +y -y -ctrl
```

par contre, sous d'autres, ce sera *Shift-Ctrl-Z*, comme sous *[Krita][Krita_site]* ou *[Blender][Blender_site]*... 

```bash
xsetwacom --set 'HID 256c:006e Pad pad' Button 2 key +shift +ctrl +z -z -ctrl -shift
```

Bon, vous l'avez compris, il n'y a pas de standard, même pour les raccourcis de *Undo*/*Redo* ou de
*Copier*/*Couper*/*Coller* et je vais probablement devoir faire un fichier de configuration commun pour
les touches qui doivent toujours fonctionner indépendemment de l'application en cours d'utilisation
(affectation de la tablette à un écran) qui sera inclus depuis des fichiers de configuration propres à
l'application en cours d'utilisation. 

Pour exécuter les commandes de changement d'affectation de la tablette vues précédement, je considère
que ces commandes doivent être lancée lorsque j'appuie sur les boutons 13 à 16 du périphérique de
pointage *Tablette*. Je dois donc m'assurer que les quatres boutons physiques de ma tablette renvoient
bien un événement bouton de pointage correspondant :
```bash
xsetwacom --set 'HID 256c:006e Pad pad' Button 13 button 13
```
sans symbole *+* ou *-*, c'est une séquence appui-relachement qui se fait :
```bash
xsetwacom --get 'HID 256c:006e Pad pad' Button 13 
button +13 -13 
```
Ensuite, selon le gestionnaire de fenêtre ou de session utilisé, il faut demander l'exécution des
commandes *xinput* sur l'événement *bouton 13*. Cela dépend de votre gestionnaire, moi c'est *Compiz*,
dans la section *Commandes* de la configuration. On peut le faire avec l'outil `xbindkeys` également.

# Gestionnaire de fenêtre/session

Attention à bien concevoir vos cartographies de touches. Si la fonction d'annulation *Undo* se trouve
sur une touche dans une application et sur une autre dans une autre application, vous allez vous y
perdre. Les fonctions similaires dans plusieurs applications doivent se trouver sur les mêmes touches de
la tablette, sinon : boulettes garanties.

## Compiz

### Changements d'écran

Nous allons utiliser les quatres boutons du bas de la tablette pour cela. Le premier étend la surface de
la tablette sur tout le bureau pour une utilisation en remplacement de la souris, le second associe la
surface de la tablette au premier écran (gauche), le troisième à l'écran central et le dernier à l'écran
de gauche.

Il faut donc générer des événements enfoncement/relachement à ces boutons en évitant les éventuels
conflits. Rares sont les outils utilisant les boutons au delà du dixième. Je vais donc utiliser les
événements *bouton 13*, *bouton 14*, *bouton 15* et *bouton 16*, que je vais associer aux touches du bas
(portant le même numéro dans mon cas, mais ce n'est pas une obligation) :
```bash
xsetwacom --set 'HID 256c:006e Pad pad' Button 13 button 13
xsetwacom --set 'HID 256c:006e Pad pad' Button 14 button 14
xsetwacom --set 'HID 256c:006e Pad pad' Button 15 button 15
xsetwacom --set 'HID 256c:006e Pad pad' Button 16 button 16
```
Ces commandes doivent être placées dans un fichier exécutable à exécuter à la demande ou automatiquement lors du
démarrage des sessions.

Puis, dans l'outil graphique de configuration de *Compiz*, j'active le module *Commandes* et je saisis
les 4 commandes à exécuter :
- ```bash
  xinput set-prop "HID 256c:006e stylus" --type=float "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1'
  ```
- ```bash
  xinput set-prop "HID 256c:006e stylus" --type=float "Coordinate Transformation Matrix" 0.333333 0 0 0 1 0 0 0 1'
  ```
- ```bash
  xinput set-prop "HID 256c:006e stylus" --type=float "Coordinate Transformation Matrix" 0.333333 0 0.333333 0 1 0 0 0 1'
  ```
- ```bash
  xinput set-prop "HID 256c:006e stylus" --type=float "Coordinate Transformation Matrix" 0.333333 0 0.666666 0 1 0 0 0 1'
  ```

Enfin, dans l'onglet *Assignation des boutons* (de souris), j'assigne respectivement les boutons 13, 14,
15 et 16 aux commandes 0, 1, 2 et 3. 

![CompizConfig]

### Annotations interractives

<video autoplay muted controls loop>
  <source src="{{ "/assets/posts/" | append: page.uid | append:"/Demo.mp4" | relative_url }}" type="video/mp4">
Your browser does not support the video tag.
</video>

J'ai besoin de cette fonctionnalité quelque soit mon activité, mais rarement, je ne souhaite donc pas
monopoliser d'autres boutons de la tablette pour cela.

Dans l'outil de configuration de *Compiz*, j'active le module *Annotations* et je laisse la
configuration par défaut. Désormais, je peux activer les annotation en gardant les touches *Meta* et
*Alt* enfondées :
- Je dessine avec la pointe du stylet
- Je gomme en survolant la zone avec le bouton 3 du stylet enfoncé
- J'efface tout avec la touche *K* (*Meta+Alt+K*)

![CompizAnnoter]

Astuce : Le module *Montrer le curseur* peut être activé pour rendre le pointeur beaucoup plus facile à
suivre à l'écran lors des présentations à distance ou des session de capture d'écran grâce à la
combinaison *Meta+K*

![CompizCurseur]

## Pour les autres

### xbindkeys
`xbindkeys` associe une commande à exécuter à une combinaison de touches. L'installation du paquet doit
être suivie de la création d'un fichier de configuration par défaut `.xbindkeysrc` dans le répertoire
*home* :

```bash
sudo apt-get install -y xbindkeys
xbindkeys --defaults > ~/.xbindkeysrc
```

Il faut ensuite ajouter les lignes suivantes :
```
"xinput set-prop "HID 256c:006e stylus" --type=float "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1'"
  b:13

"xinput set-prop "HID 256c:006e stylus" --type=float "Coordinate Transformation Matrix" 0.333333 0 0 0 1 0 0 0 1'"
  b:14

"xinput set-prop "HID 256c:006e stylus" --type=float "Coordinate Transformation Matrix" 0.333333 0 0.333333 0 1 0 0 0 1'"
  b:15

"xinput set-prop "HID 256c:006e stylus" --type=float "Coordinate Transformation Matrix" 0.333333 0 0.666666 0 1 0 0 0 1'"
  b:16
```

Et faire en sorte que `xbindkeys` se lance au démarrage de la session grâce à son helper fourni dans le
paquet *Debian* : `xbindkeys_autostart`

### Gromit

Il suffit d'installer le pquet `gromit` et de le lancer au démarrage de la session, par défault, il
capture la touche *Pause* ou *Arrêt Défil.* du clavier pour activer/désactiver les annotations.
*Shift+Pause* efface l'écran, *Ctrl-Pause* masque/montre les annotations sans les perdre et *Alt-Pause*
quitte le programme. Il est possible de le configurer différemment. On peut assigner les raccourcis 
claviers de *Gromit* à des touches sur la tablette, par exemple.

```bash
sudo apt-get install gromit
```

# Applications

Je ne vais pas détailler la configuration de ces applications, ce sont celles que j'utilise un peu,
beaucoup, passionément et à la folie. Je vais me contenter d'indiquer le niveau de support que j'ai
obtenu et qui me convient.

## Gimp
*[Gimp][Gimp_site]* gère très bien la pression, la position, la vitesse et permet d'utiliser ces informations pour
modifier l'épaisseur, l'opacité, ... Il faut aller configurer les *Périphériques d'entrée*. 

Ensuite, attention, la configuration de l'outil courant est différente lorsque l'on utilise un
périphérique de pointage ou un autre. Il est possible d'avoir une gestion de la pression *Dynamic* avec
le stylet et *Off* avec la souris. Si on bouge la souris, on voit *Off*, alors que le stylet est bien en
*Dynamic*.  Je recommande d'utiliser exclusivement le stylet dans [Gimp][Gimp_site] et de ne pas passer de l'un à
l'autre sans s'être habitué à ce comportement.

## Krita
*[Krita][Krita_site]* gère également nativement la pression et permet de faire de jolis dessins. Il est possible de
vérifier le bon fonctionnement de la tablette dans le menu *Settings*/*Configure Krita*/*Tablet
settings*. On peut même y ajuster la courbe de réponse en pression.

## OpenToonz
La tablette fonctionne nativement avec *[opentoonz][opentoonz_site]*, il faut bien penser à régler l'épaisseur minimale et
maximale dans la barre d'outils sous les menus lorsque l'outil sélectionné le permet.
![OpenToonz]

## Storyboarder
*[StoryBoarder][StoryBoarder_site]* de *WonderUnit* n'est pas empaqueté dans les dépôts *[Debian][Debian_site]*. J'utilisais le fichier
AppImage jusqu'à ce que *WonderUnit* fournisse aussi un paquet *.deb*. C'est un logiciel OpenSource très
pratique pour écrire des storyboard. Il s'agit d'une application *Electron* (Javascript/NodeJS utilisant
le framework de Chrome/Chromium pour l'affichage comme une application native). Malheureusement, je n'ai
pas réussi à faire fonctionner la gestion de la pression pour le framework *Chrome*, pour *Chrome* et
toutes les applications *Electron*. J'ai donc un support qui permet de dessiner, comme avec la souris,
en plus confortable, mais sans la pression.

## Blender 3D
La configuration et l'utilisation de *[Blender][Blender_site]* est un sujet en soi. La tablette est reconnue nativement,
il faut bien penser à activer l'icone *gestion de la pression* en face des sliders le supportant.
Principalement en mode *sculpt*. Ceci dit, elle fonctionne dans tous les modes, la navigation en 3D est
très pratique, combinée aux touche *Ctrl* et *Shift*. Je recommande d'assigner *Undo*/*Redo* sur des
touches de la tablette, ainsi que *q* (menu rapide des favoris), *ESC* et *Tab* ou *Ctrl-Tab*.
<video autoplay muted controls loop>
  <source src="{{ "/assets/posts/" | append: page.uid | append:"/Blender.mp4" | relative_url }}" type="video/mp4">
Your browser does not support the video tag.
</video>

## Zoom, Teams, Hangout, GoToMeeting, BigBlueButton
À ma connaissance, aucun d'entre-eux ne gère la pression. Pour ceux qui disposent d'un mode annotation
ou d'un mode tableau blanc, le stylet est reconnu comme une souris et permet de dessiner
confortablement, pour les autres, il suffit de partager un écran avec un fond blanc ou une diapositive
et de dessiner dessus grâce à *Gromit* ou *Compiz*.

## FreeCAD
Je pense que la tablette est utile pour `freecad`, mais je ne l'ai pas encore testée dans ce contexte.
Dans tous les cas, avec les bon raccourcis sur les boutons, ce sera plus confortable.

## LibreOffice / OpenOffice
Encore une fois, je ne l'ai pas encore testé, mais ce sera au pire comme une super souris améliorée avec
des boutons raccourcis bien choisis. Je n'ai pas trouvé (en 30 secondes de recherche) comment prendre la
pression en compte. Mais, en allant dans *Affichage*/*Barre d'outils*/*Dessin*, et en sélectionnant
l'outil de dessin à main levée, on peut déjà bien dessiner.

## Audacity
Je n'ai pas encore testé, mais les raccourcis doivent pouvoir bien aider. Pour le côté pointage, je ne
suis pas certain que ce soit très utile. Mais ce n'est que mon opinion.

## LMMS

On doit pouvoir utiliser les boutons de raccourcis, si jamais... le clavier midi maître n'en comportait
pas assez ;) Mon APK-Mini dépasse déjà largement mes besoins et compétences ;)

## Natron
Encore un outil opensource merveilleux, non disponibles dans les dépôts *Debian*. C'est un logiciel de
compositing vidéo de niveau professionel, clone d'un logiciel commercial, et ... Français ! Les
raccourcis claviers sont bien pratiques, et le stylet permet le dessin des masques, le positionnement
des trackers, le *rotopainting* (pour faire disparaître la cousine Berthe de la vidéo du mariage, ou le
cousin Gaston qui était complètement bourré !)

## Cinelerra
Ici aussi, l'association des raccourcis peut être utile. `cinelerra` comporte, par exemple, plusieurs
variantes de copier/coller/supprimer/undo/redo (pour les contenu ou pour les courbes). Même sans la
gestion de la pression, le positionnement de la caméra ou du projecteur se fait bien au stylet. Le
dessin de masques est aussi pratique.

## OpenShot, Shotcut, Olive et autres
Je n'utilise plus `OpenShot`, il est toujours installé et je l'ai mis dans la liste. Je pense que la
tablette et le stylet peuvent servir, même sans gestion de la pression. Je n'utilise pas (encore) les
autres, pour l'instant. J'aime trop `cinelerra`. Mais l'utilisation doit être aussi utile.

# Supports et liens

| Lien | Description |
|---|---|
| [Video] | Enregistrement vidéo de la démonstration |

# Notes de bas de page

[digimend]: https://digimend.github.io/ "Projet Digimend"

[^1]: https://digimend.github.io/ 

[Video]: https://youtu.be/wofhUDzIUtU "Enregistrement vidéo de la démonstration"
[CompizConfig]: {{ "/assets/posts/" | append: page.uid | append:"/CompizConfig.png" | relative_url }} "Association de boutons"
[CompizAnnoter]: {{ "/assets/posts/" | append: page.uid | append:"/CompizAnnoter.png" | relative_url }} "Annotation Compiz"
[CompizCurseur]: {{ "/assets/posts/" | append: page.uid | append:"/CompizCurseur.png" | relative_url }} "Curseur Compiz"
[OpenToonz]: {{ "/assets/posts/" | append: page.uid | append:"/OpenToonz.png" | relative_url }} "OpenToonz"


[Zoom_site]: http://zoom.us
[Teams_site]: https://www.microsoft.com/fr-fr/microsoft-teams
[GoToMeeting_site]: https://www.goto.com/fr
[Hangout_site]: https://hangouts.google.com/
[Gimp_site]: https://www.gimp.org/
[Krita_site]: https://krita.org/fr/
[OpenToonz_site]: https://opentoonz.github.io/e/
[StoryBoarder_site]: https://wonderunit.com/storyboarder/
[Blender_site]: https://www.blender.org/
[Debian_site]: https://www.debian.org/index.fr.html
[Gaomon_site]: https://fr.gaomon.net/products/
[Wacom_site]: https://www.wacom.com/fr-fr
[XP-Pen_site]: https://www.xp-pen.fr/
[Huion_site]: https://www.huion.com/
[DavidRevoy_site]: https://www.davidrevoy.com/
[WH1409_site]: https://www.huion.com/pen_tablet/Huion/WH1409(8192).html
[Amazon_site]: https://www.amazon.fr/gp/product/B06XKXPJD8
[CDiscount_site]: https://www.cdiscount.com/arts-loisirs/beaux-arts/huion-wh1409-v2-tablette-graphique-sans-pile-en-mo/f-161010507-auc6934062472205.html
[Digimend_site]: https://digimend.github.io/
[Lightdm_site]: https://github.com/canonical/lightdm
[XFCE_site]: https://xfce.org/
