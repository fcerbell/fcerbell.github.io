---
uid: Debian112Base040Command-linecomforttools
title: Debian11, Base, Outils de confort en ligne de commande
description: Travailler en ligne de commande, ou terminal, n'est pas pénible... Dès lors qu'il est configuré pour répondre à vos besoins. Je décris ici ma configuration minimale pour la console sur tous les types de machine, recherche de fichiers, recherche dans l'historique à l'aide des flèches, multiplexage de session, assistance aux paquetages manquants, invite de commande puissante et configuration minimale de `vim`.
category: Informatique
tags: [ GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, Mlocate, Screen, AptFile, CommandNotFound, Prompt, Invite de commande, Historique croisé, History, Readline, Auto logout, Lougout, Timeout, Session timeout, Déconnexion automatique, Recherche historique, Vim ]
---

Travailler en ligne de commande, ou terminal, n'est pas pénible... Dès lors qu'il est configuré pour répondre à vos besoins. Je décris ici ma configuration minimale pour la console sur tous les types de machine :  recherche de fichiers, recherche dans l'historique à l'aide des flèches, multiplexage de session, assistance aux paquetages manquants, invite de commande puissante et configuration minimale de `vim`.

* TOC
{:toc}

# mlocate pour trouver des fichiers dans le système

`dpkg -S` est pratique pour trouver des fichiers dans le système... à condition que ces fichiers appartiennent à un paquetage
installé. Absolument inutile pour rechercher des fichiers qui ne font pas partie d'un paquetage `.deb`. `locate` remplit cette
tâche.
```bash
apt-get install -y mlocate
updatedb
```

# Screen pour multiplexer les connexions au terminal

**TODO Détecter les sessions screen en cours et les lister à la connexion dans le motd**

Je me connecte parfois à mes machines alors que je voyage en train ou en voiture, avec une connexion réseau faible et instable.
`screen` est mon outil favori pour gérer et garder ouvertes mes sessions de terminal, même en cas de déconnexion. Je pourrais
utiliser `tmux`, mais j'en ai moins l'habitude.
```bash
apt-get install -y screen
```

# command-not-found pour identifier les paquetages manquants

Qui n'a jamais saisi `netstat` et eu en retour le message d'erreur *command not found*, il faut ensuite identifier le paquetage
contenant la commande et l'installer. Avec `command-not-found`, si la commande n'est pas disponible, le message d'erreur tente de
corriger les éventuelles fautes de frappe et de suggérer les paquetages qui pourraient fournir cette commande. Un gain de temps
pour éviter de rompre un flux de pensée.

![netstat.gif]({{ "/assets/posts/en/Debian112Base040Command-linecomforttools/3aab67ea9ed8426cbff8a9ec31ff9d20.gif" | relative_url }})

```bash
apt-get install -y command-not-found apt-file
```

Cette mise à jour devrait avoir été exécutée pendant l'installation et sera exécutée à intervale régulier. Néanmoins, cela ne
coute rien de l'exécuter maintenant et cela permettra de rafraîchir automatiquement la base de données de command-not-found.
```bash
apt-file update
```

# Invite de commande, historique croisé et déconnexion automatique

Mon invite de commande affiche l'identifiant utilisateur, le nom de machine, le dossier courant mais aussi le niveau d'imbrication
de shell, le dernier code retour, la date et l'heure. Essayez-la et vous comprendrez pourquoi ces informations sont utiles.

Les niveaux d'imbrications vous permettent de mieux gérer vos variables d'environnement, une fois que vous les utiliserez. Le
dernier code retour met en évidence lorsqu'une commande a échoué. La date et l'heure horodatent automatiquement les commandes et
donnent une idée des temps d'exécution lorsque vous oubliez d'utiliser `time`.

Cette personnalisation sauvegarde et restaure automatiquement l'historique à chaque commande. Ainsi, dès que vous lancez une
commande dans un shell, elle est disponible dans l'historique de tous les autres shells sans devoir les relancer. Plus simplement,
cela donne presque un unique historique trans-sessions en temps-réel.

J'ajoute enfin un compteur qui déconnecte la session en cours de l'utilisateur (root) au bout de 10 minutes d'inactivité.

```bash
cat << EOF >> ~/.bashrc

export PS1='[ \[\033[1;36m\]\u@\h\[\033[0m\]\[\033[1;31m\] ShLvl:$SHLVL\[\033[0m\] \[\033[1;35m\]Cmd:\!\[\033[0m\]\[\033[1;34m\] Ret:$?\[\033[0m\] \[\033[1;33m\]\d \t\[\033[0m\] ]\n\[\033[1;32m\]\w\[\033[0m\] # '
export PROMPT_COMMAND="\${PROMPT_COMMAND:+\$PROMPT_COMMAND\$'\n'}history -a; history -c; history -r"
export TMOUT=600 # 10m auto logout
EOF
```

# Recherche dans l'historique readline avec les flèches du curseur

L'historique de `Readline` est merveilleur, il est utilisé dans chaque outil interractif, tel que les shells. Malgré l'efficacité
de sa fonction de recherche à l'aide de `Ctrl-R`, readline peut aussi rechercher dans l'historique pour compléter automatiquement
une commande. Si je souhaite réutiliser une de anciennes commandes `ssh`, je peux juste saisir `ssh` et naviguer parmis uniquement les
commandes commençant par `ssh` dans l'historique. À essayer et adopter !

![readline.gif]({{ "/assets/posts/en/Debian112Base040Command-linecomforttools/0ae2e83f456a4bd69fa8d5c93f906cbd.gif" | relative_url }})

```bash
cat << EOF >> ~/.inputrc
"\e[A": history-search-backward
"\e[B": history-search-forward
EOF
```

# vim et sa configuration

`vim` est le **seul** éditeur de texte. Il peut être personnalisé pour avoir de la colorisation syntaxique, des numéros de ligne,
une barre d'état, la surbrillance des recherches, les onglets, fenêtres, .... Installons-le.
```bash
apt-get install -y vim-nox vim-addon-manager vim-scripts
```

Voici ma configuration, trop longue pour tout décrire, mais il y a quelques commentaires.
```bash
mkdir -p ~/.vim/backup
cat << EOF >> ~/.vimrc
" Source a global configuration file if available
if filereadable("/etc/vim/vimrc")
    source /etc/vim/vimrc
endif

set nocompatible  " Use Vim defaults (much better!)
set autoindent
set autowrite  " Automatically save before commands like :next and :make
set background=dark
set backspace=2 " Allow backspacing over everything (eol,indent,start)
set hidden  " Hide buffers when they are abandoned
set ruler " show the cursor position all the time
set smartcase  " Do smart case matching
set scrolloff=10 " minimal number of line to keep at top/bottom when scrolling
set suffixes=.jpg,.png,.jpeg,.gif,.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf " low prio suffixes when tabbing
set fileformats=unix
set formatoptions=rtql
set mouse= " Enable mouse usage (all modes)
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set hlsearch " "highlight" le dernier motif de recherche
set ignorecase  " Do case insensitive matching
set incsearch  " Incremental search
set showmatch  " Show matching brackets.
set matchtime=2  " show matching brackets 2 secondes
set textwidth=0 "dont wrap words by defaults
set wrapmargin=8
set history=50 " 50 line of history
set autoread " Relecture automatique des fichiers modifiés en dehors de vim
set errorbells
set visualbell
set shortmess+=r " use "[RO]" for "[readonly]"
set showmode " display the current mode
set showcmd  " Show (partial) command in status line.
set modeline "Allow modeline in files to overwrite te vimrc settings
set whichwrap=b,s,<,>,[,] " Allow use of L/R arrow to navigate between lines
"set encoding=utf-8
"set fileencoding=utf-8
set statusline=%t%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [FENC=%{&fileencoding}]\ [POS=%04l,%04v]\ [%p%%]\ [LEN=%L]
set laststatus=2

colorscheme darkblue
set bg=dark

set number 
highlight LineNr ctermbg=black ctermfg=gray

set cursorline
"highlight CursorLine term=reverse cterm=reverse

highlight TabLine term=none cterm=none
highlight TabLineSel ctermbg=darkblue

" remember all of these between sessions, but only 10 search terms; also
" remember info for 10 files, but never any on removable disks, don't remember
" marks in files, don't rehighlight old search patterns, and only save up to
" 100 lines of registers; including @10 in there should restrict input buffer
" but it causes an error for me:
set viminfo=/10,'10,r/mnt/zip,r/mnt/floppy,f0,h,\"100

" Write backup files in ~/.vim/backup
if filewritable(expand("~/.vim/backup")) == 2
  " comme le répertoire est accessible en écriture,
  " on va l'utiliser.
  set backupdir=$HOME/.vim/backup
else
  if has("unix") || has("win32unix")
    " C'est c'est un système compatible UNIX, on
    " va créer le répertoire et l'utiliser.
    call system("mkdir $HOME/.vim/backup -p")
    set backupdir=$HOME/.vim/backup
  else
    set nobackup "Dont do backup files
  endif
endif

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
" Vim5 comes with syntaxhighlighting. If you want to enable syntaxhightlighting
" by default uncomment the next three lines.
if has("syntax")
  syntax on  " Default to no syntax highlightning
endif

if has("autocmd")
  " Uncomment the following to have Vim load indentation rules according to the
  " detected filetype. Per default Debian Vim only load filetype specific
  " plugins.
  filetype indent on
  filetype plugin on
  " Uncomment the following to have Vim jump to the last position when
  " reopening a file
  au BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g'\"" |
    \ endif
endif


""""""""""""""""""""""""""""""""""""""""""""""""""
"Mapping pour naviguer dans les lignes wrappées
""""""""""""""""""""""""""""""""""""""""""""""""""
map <A-DOWN> gj
map <A-UP> gk
imap <A-UP> <ESC>gki
imap <A-DOWN> <ESC>gkj

""""""""""""""""""""""""""""""""""""""""""""""""""
"Chargement des types de fichiers
""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd BufEnter *.txt set filetype=text " chargement du type de fichier pour le format txt
autocmd BufEnter *.todo set filetype=todo " chargement du type de fichier pour le format todo

EOF
```

# SMART monitoring

To be honest, I install this disk monitoring, but do not tune it or set alerts. It is completely useless in my tutorial, but I strongly suggest to install and invest time to configure it.
```bash
apt-get install -y smartmontools
sed -i 's/^#\(.*start_smartd.*\)/\1/' /etc/default/smartmontools
systemctl restart smartd
systemctl restart smartmontools
```

# Fin de la base

Maintenant, le système est prêt pour devenir soit un serveur, soit une station de travail. La configuration, la sécurité, ...
seront différentes en fonction de l'usage de la machine, mais à ce stade, toutes les installations et configurations communes à
tous les usages sont faites. Il reste à choisir ce que l'on veut en faire et utiliser la bonne série d'articles.

