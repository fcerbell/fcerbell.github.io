---
uid: Debian112Preparation040Command-linecomforttools
title: Debian11, Preparation, Command line comfort tools
description: Working from command line is not a pain... as soon as it is configured to fit your needs. This is my minimal console setup with file search, history search with arrows, connection multiplexing, missing packages help, powerfull prompt and `vim` minimal configuration.
category: Computers
tags: [ Debian11 Preparation, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, Mlocate, Screen, AptFile, CommandNotFound, Enhanced prompt, Prompt, Cross history, History, Readline, Auto logout, Logout, Timeout, Session timeout, History search, Search, Vim ]
---

Working from command line is not a pain... as soon as it is configured to fit your needs. This is my minimal console setup : file search, history search with arrows, connection multiplexing, missing packages help, powerfull prompt and `vim` minimal configuration.

* TOC
{:toc}

# mlocate to find files in the file system

`dpkg -S` is fine to find files in the filesystems... as long as they are belonging to an installed package. Useless to find files that do not belong to a `.deb` package. `locate` fills this gap.
```bash
apt-get install -y mlocate
updatedb
```

# Screen to multiplex terminal connections

**TODO Detect running sessions and list them at connection in the motd**

I sometimes connect to my servers while traveling in a train or in a car, with very weak and unstable network connection. `screen` is my favorite tool to manage and keep my command line sessions open, even when I'm disconnected. I could use `tmux` but I'm less used to it.
```bash
apt-get install -y screen
```

# command-not-found to identify missing packages

Who never typed `netstat` and got the *command not found* error. Then, I had to find which package provides the command, to install it. With `command-not-found`, if the command is missing, the error message tries to fix any posible typo in my command and to suggest packages that provide these commands. This saves time.

![netstat.gif]({{ "/assets/posts/en/Debian112Preparation040Command-linecomforttools/3aab67ea9ed8426cbff8a9ec31ff9d20.gif" | relative_url }})

```bash
apt-get install -y command-not-found apt-file
```

This update should be executed during the installation and will be executed on a regular basis. Nevertheless, it is painless to execute it now and it will also automatically refresh the command-not-found database.
```bash
apt-file update
```

# Bash prompt, cross history and auto-logout

My prompt displays the user, the hostname, the curent folder, but also the nested shell level, the last return code and the date/time. Just try it and you'll understand why these informations are useful.

The nested shell level enables you to better manage your environment variables, once used to it. The last return code makes obvious when a command failed. The date and time automatically timestamps your commands and give you an idea of the execution times when you forgot to use the `time` command.

This customization also save and reload the history at each command. Thus, as soon as you type a command in a shell, it is available in the history of all the other opened shells without relogin. Basically, I have nearly one single real-time cross-session history.

I also add a 10 minutes timeout for sessions on my root accounts.

```bash
cat << EOF >> ~/.bashrc

export PS1='[ \[\033[1;36m\]\u@\h\[\033[0m\]\[\033[1;31m\] ShLvl:$SHLVL\[\033[0m\] \[\033[1;35m\]Cmd:\!\[\033[0m\]\[\033[1;34m\] Ret:$?\[\033[0m\] \[\033[1;33m\]\d \t\[\033[0m\] ]\n\[\033[1;32m\]\w\[\033[0m\] # '
export PROMPT_COMMAND="\${PROMPT_COMMAND:+\$PROMPT_COMMAND\$'\n'}history -a; history -c; history -r"
export TMOUT=600 # 10m auto logout
EOF
```

# Smart readline history search with up/down arrows

`Readline`'s history is wonderfull, used everywhere in every interractive tool, including the shells. Despite the search feature with `Ctrl-R` is very good, readline can search in the history to auto-complete a command from the history. If I want to reuse one of my very old previous `ssh` commands, I can type `ssh` and navigate with the up/down keys only in the lines begining with `ssh`. Try it, you'll keep it, for sure.

![readline.gif]({{ "/assets/posts/en/Debian112Preparation040Command-linecomforttools/0ae2e83f456a4bd69fa8d5c93f906cbd.gif" | relative_url }})

```bash
cat << EOF >> ~/.inputrc
"\e[A": history-search-backward
"\e[B": history-search-forward
EOF
```

# vim and its configuration

`vim` is the **only** terminal editor. It can be customized to have color, line numbers, syntax hilighting, custom status bar, search highlight... Lets install it.
```bash
apt-get install -y vim-nox vim-addon-manager vim-scripts
```

Here is my configuration, too long to describe in detail, but it is commented in-line.
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

# End of base

Now, the system is ready to become either a server or a workstation. The configuration, security, ... will be different depending on the usage, but at this stage, I made all the common stuff. Let's choose what you want to do with your machine and jump to the relevant post serie.

