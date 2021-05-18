---
uid: multiprotocoliotinfra
title: Multiprotocol IoT infrastructure
description:
category: Home automation
tags: [ ZWave, MySensors, MQTT, Mosquitto, NodeRED, Domoticz, NodeJS, IoT, Raspberry, home automation ]
---

I made my first home automation system 6 years ago, in 2014 and had
little choices in terms of hardware and software. Now, things changed and
I can redesign it to better suit my needs with about 100 connected
sensors and actuators, domoticz as the user interface, MQTT to centralize
MySensors and Zwave meshed network events, NodeRED as an MQTT ETL, Redis
Streams, Redis Timeseries and Redis PubSub as a storage... Everything on
a Raspberry Pi 3. Lets have a look at the prototype.

You can find links to the related video recordings and printable materials at
the <a href="#materials-and-links">end of this post</a>.

* TOC
{:toc}

# Video

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/xZhq5jgKFmQ" frameborder="0" allowfullscreen></iframe></center>

# Hardware

In 2014, I bought a 60 years old house and I had to refurbish everything,
ceilings, walls, electricity (the fuses were in the plugs and the wires
in steel tubes). The house was big, with thick walls,

## Server

The server, had to run on a Raspberry Pi 2 at this time. I upgraded it to
a Raspberry Pi 3 later. At the end, I designed [my own Home automation
server 3D printed case][Thingiverse][^1] to host the raspberry Pi, a
power supply and a Raspberry LiPo battery. Thus, I was able to unplug the
server without shutdown, move from a room to another room, plug it back
or not. It had wifi connection. Perfect to make tests.

## Devices

I needed a wireless technology, I did not want to hard wire things. I
wanted the system to be fault tolerant and the house to behave as a
normal house when the system is off (or removed). Thus, it had to be
wireless. I also had thick walls and a big house, thus the network had to be
meshed. 

### ZWave gateway and nodes

There were not so many meshed wireless network technologies : Zwave,
proprietary but robust and Zigbee, quite young at this time. I chose
ZWave. 

The devices were very expensive (60€ per device), and I needed a lot of
them. The gateway had to run on a Raspberry and Z-wave.me sells a ZWave
Raspberry Pi hat. 

I bought and installed :
- Qubino 1 or 2 relays modules behind each light switch
- AEON and Fibaro wall plugs
- Fibaro door and window sensors
- Danfoss Living connect radiator thermostats
- Fibaro and AEON multisensors (IR, Lux, Temperature, Humidity) in each
  room
- Qubino shutter (blinds) modules

### MySensors gateway and nodes

As the time went, I discovered Arduinos and the [MySensors
open-source/open-hardware project][MySensors][^3]. I built a LAN gateway
and some devices such as [my weather and swimming pool
station][MyWeather][^4]. I ended by designing [My iown PCB design of a tiny
MySensors node][MySNode][^2]. 

### RFXCOM RFX433trx and Chacon devices

I also discovered the wonderfull RFXCom RFX433trx multi-protocol
transmitter and decoder. Thus, I added it to my system, to open it to a
lot of hardware. I began with connected fire alarms. Unfortunately,
Chacon does not return its state. I can only send "fire-and-forget"
commands. Anyway, I can include Chacon devices.

# Software

Everything has to fit in the Raspberry Pi.

## Raspbian

I chose to install a minimal Raspbian (Debian 10 "Buster" based) as a
base system. I don't have any keyboard, mouse or display connected to the
server, it had to support unattended installation.

I chose a 8GB SDCard to have some headroom, despite it could fit in a
4GB. And I'm a pure Linux guy, so I'll create the SDCard from a Debian 10
(Buster) GNU/Linux machine.

First, I downloaded the last Raspbian unattended installer from
[https://github.com/debian-pi/raspbian-ua-netinst/releases] :

`wget -c https://github.com/debian-pi/raspbian-ua-netinst/releases/download/v1.1.2/raspbian-ua-netinst-v1.1.2.img.xz`

I copied it on an sdcard as root. I double checked the exact name of my
SD card device, if you make any error here, you will destroy and loose
data.

```sh
xzcat /home/fcerbell/Téléchargements/raspbian-ua-netinst-v1.1.2.img.xz > /dev/sdh
```

I created an unattended configuration file to customize a little bit the
installation. I replaced the default "pi" hostname by "raspbian10-base",
I created a default user "pi" with password "pi". The default
installation does not have any regular user, only "root", and the default
openSSH does not allow access to root. Quite embarrassing for an
unattended installation without a local keyboard, mouse and display...
Given that I need to install software as a regular user, I'll need to
create him later, so I created him at installation, without any
privileges. I also customized the boot parameters to have a better fsck
(this will be an headless appliance).

```sh
mount /dev/sdh1 /mnt
cat <<EOF >> /mnt/installer-config.txt
hostname=raspbian10-base
username=pi
userpw=pi
cmdline="dwc_otg.lpm_enable=0 console=tty1 elevator=deadline fsck.repair=yes"
EOF
umount /mnt 
```

I plugged the SDCard in the RPi, booted it and let the install run (can
take up to one hour depending on your internet connection and the RPi
model). But you don't need any keyboard and display connected to the RPi.

I found the RPi IP address from my DHCP server. Pinged my RPi. As soon as
the RPi does not answer anymore, the system is halted, the green led
should not blink anymore neither, and power cycle it.

Now, I can connect with SSH on the Raspberry Pi, with the "pi" user and
"pi" password !  I can switch to root with "su" (password: "raspbian"):

```sh
ssh pi@192.168.1.5
su -
```

Ok, now, the system is bootstrapped, I can execute some generic
post-installation customization to have a simmilar commandline user
experience on all my servers.

### Configuration questions

Whatever you choose to install, a VM or a bare-metal machine, you have to
choose at least:

- the hostname
- the unprivileged username
- a static IP address (mandatory for servers, optional for workstations/laptops)

You'll need this information several times. Instead to change the code, I
want to cut-and-paste it, I parametrized the code blocks. I ask questions
at the begining of the installation and save the answers in environment
variables. Given that I need to reboot several times, I save these
variables in a file. This file will be sourced by the other steps to
avoid asking again and again the same information and avoid mistakes.

You need to `ssh` into your machine and `su -` yourself to `root`. If you
don't know what it means, you can still read, bookmark this page and come
back later, but please do not try to apply on public servers

```sh
read -p "Public IP address: " IP
```
```sh
read -p "Hostname: " HOSTNAME
```
```sh
USERNAME=pi
```
```sh
cat << EOF > /root/variables.env
export IP=$IP
export HOSTNAME=$HOSTNAME
export USERNAME=$USERNAME
EOF
```

### Raspberry BIOS settings
I manually updated the Raspberry *BIOS* settings in the
`/boot/config.txt` file to use less shared memory for the graphic card.
This server is headless.
```sh
echo '[all]' >> /boot/config.txt
echo '#arm_freq=1000' >> /boot/config.txt
echo '#core_freq=500' >> /boot/config.txt
echo '#sdram_freq=600' >> /boot/config.txt
echo '#over_voltage=6' >> /boot/config.txt
echo 'gpu_mem=16' >> /boot/config.txt
```

### Networking

I did not change anything here, I left the wired network interface on
DHCP, but I locked it to a fixed IP on my DHCP server.


### Wireless network

I configured the wifi network to auto connect on boot. I installed the
required softwares and firmwares and generated a hashed copy of my wifi
password :

```sh
apt-get install -y firmware-brcm80211 wpasupplicant iw wireless-tools
echo 'UltraSecretPassword' | wpa_passphrase Freebox-AEA6A1
```

Then, I added the Wifi interface and its configuration in the network
configuration file, with the hashed password :

```sh
cat >> /etc/network/interfaces << EOF
auto wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
wpa-ssid "Freebox-AEA6A1"
wpa-psk UltraSecretPasswordHashed
EOF
reboot
```

I rebooted to check that the modules and firmware are correctly loaded at
boot time and that the configuration is fine.


### Update hostname

First, I reload the saved installation variables, maybe I just rebooted,
or I just reconnected to a fresh shell. I'll need these variables to
configure `sudo`.

```sh
source /root/variables.env
```

I chose a generic hostname during the unatended installation to customize
it now in the relevant files :
```sh
sed -i 's/raspbian10-base/'${HOSTNAME}'/g' \
/etc/ssh/ssh_host_ed25519_key.pub \
/etc/ssh/ssh_host_ecdsa_key.pub \
/etc/ssh/ssh_host_rsa_key.pub \
/etc/hosts \
/etc/hostname
```

### Disable swap

I don't need swap, I'll do my best to avoid this. Anyway, if a system
begins to swap, it is not good and it will probably be so busy that I'll
have to hard reboot it, even more when the system has very low resources
such as a Raspberry.

```sh
sed -i 's/UUID.*swap/#&/' /etc/fstab 
swapoff -a
```

### Package and system update

Ok, now, it is time to update the packages lists, and to apply all the
available upgrades.

```sh
apt-get update && apt-get upgrade -y 
```

### Raspbian configuration and security

Given that I installed a very minimal unattended unofficial Raspbian, I
don't have all the specific things, Even if I don't use all of them, Iall
install them. But I will not use `raspi-config`, I already changed the
hostname, configured the network, configured the *BIOS*, ... I'll
continue that way and will configure manually the locales and the
timezone.

```sh
dpkg-reconfigure locales
dpkg-reconfigure tzdata
apt-get install -y raspi-config raspi-copies-and-fills sudo curl pi-bluetooth
```

### Aptitude installation

I like `aptitude` on my servers. I am used to it, mainly *search*,
*show*, *why* commands. Then, I don't like the blinky and verbose `apt`
output.

```sh
apt-get -y update
apt-get -y install aptitude
```

### System update

Ok, fine, now, it is time to apply my repositories preferences and to
upgrade the system accordingly.

```sh
apt-get -y update &&
apt-get -y upgrade &&
apt-get -y dist-upgrade &&
apt-get clean
```

### Reboot

The upgrade may have changed the linux kernel, in such a case, a `reboot`
is needed to use this new kernel. Custom module compilation use DKMS,
DKMS will use `uname` to guess which linux-header to compile the module
with. Thus I prefer to reboot now and not to forget later.

### Sudo

First, I reload the saved installation variables, maybe I just rebooted,
or I just reconnected to a fresh shell. I'll need these variables to
configure `sudo`.

```sh
source /root/variables.env
```

Let's install `sudo`.

```sh
apt-get install -y sudo
```

Allow the unprivileged user to run any command, with password. At this
stage, the user still has a password-protected account. Password login
will be disabled after the SSH configuration.

```sh
adduser ${USERNAME} sudo
```

Allow user to run any command without password (he will have password
disabled later)

```sh
echo "${USERNAME} ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}
```


### SSH server configuration

Force *SSHv2* (disable *SSHv1*), forbid direct root connection with a
password (only with key-pair), create a PID file to make monitoring
easier, and keep hostnames clear in the `known_hosts` file (do not hash).
Hashing the hostnames is probably more secure in case of intrusion, but
it is a pain when you change your other machines IP addresses.

```sh
# Disable SSHv1
echo "" >> /etc/ssh/sshd_config
echo "Protocol 2" >> /etc/ssh/sshd_config
# Disable direct root connections
sed -i 's/#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
# Configure a PID file
sed -i 's~#\?PidFile /var/run/sshd.pid~PidFile /var/run/sshd.pid~' /etc/ssh/sshd_config
# Do not hash hostnames in known_hosts files
sed -i 's/\(Hash.*\)yes$/\1no/' /etc/ssh/ssh_config
# Restart the daemon
systemctl restart ssh
```

The machine should already have an ssh key pair. In some cases, mainly if
you changed the hostname, you need to regenerate a key pair. If you used
a service provider to automatically install the system, can you trust him
enough ? I don't. Some of them took the server keys to enable their
support to connect to your machine and to "help" you. Currently, no other
machine depends on the eventually existing host key, so I can safely
regenerate it. 

Root do not have a key-pair yet. I create one, which will probably never
be used, and it also initialize the `/root/.ssh` folder structure.

```sh
ssh-keygen -q -f "/etc/ssh/ssh_host_dsa_key" -t dsa -N ''
ssh-keygen -f /root/.ssh/id_rsa -q -N ""
```

If a backup robot need to backup this server, it needs to connect as
root, password-less (key challenge based) to be able to backup any file
from the filesystems.

**This key is specific for my backup server. Don't use it or you'll give
me full access to your machine**

```sh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDX94WcZhrCjWXffCckgeEROTB0PnvpOxlFm/scvxTfTlh0sNV4KTrfHWrClDdBus6e7JL2VIltJBDdDHgetTaOK6HnHkmwoHFq+xm8TYqHQc3dzD8YMhjmFLRwHNDMadvy/oLrcae+e/moGUVdfsnjNbX2tjGMlld8ZwGUXPysvB70S+VpKgZ2e24xTvFNdPaTIDGky3EOeCI54iRXyAsHvKV0xFQJQf+FiiUQYoo2wCNsCgIqXD1ue0mpId8vjD7OCBBQE/T5sl+PWOUYxMEjVt9QmtLxunjC948c5RJLo96Gjg5bhwRJD7bHAKvgH984AeNnKuHMhN9P8f8bantP OMV' >> /root/.ssh/authorized_keys
```

I will soon lock the unprivileged user's password, I need to be able to
connect passwordless with my private key. I add my public key to the
authorized keys file.

**This key is specific for my backup server. Don't use it or you'll give
me full access to your machine**

```sh
mkdir /home/${USERNAME}/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAtM8LzekUr46wvVNWoYzxPuKVTv7yFp+Aa/a1vKAendFa3xsMZz6Pp0Xn8U5ZYbTpqqVeM8O+ETqjtpBVk+7+C516DwB+R/cKulTjy061fBPZvTp5pIKm4+NQXNBhwjmQs//nWJ54PlDS5mHuj9NalX07b2OBztrvLjPzf/m4sB0= Francois Cerbelle' >> /home/${USERNAME}/.ssh/authorized_keys
chown -R ${USERNAME}.${USERNAME} /home/${USERNAME}
```

I also want to be able to open a direct *root* connection passwordless
with my private key. This is a bad practice, but I'm the only admin.

**This key is specific for me. Don't use it or you'll give me full access to your machine**

```sh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAtM8LzekUr46wvVNWoYzxPuKVTv7yFp+Aa/a1vKAendFa3xsMZz6Pp0Xn8U5ZYbTpqqVeM8O+ETqjtpBVk+7+C516DwB+R/cKulTjy061fBPZvTp5pIKm4+NQXNBhwjmQs//nWJ54PlDS5mHuj9NalX07b2OBztrvLjPzf/m4sB0= Francois Cerbelle' >> /root/.ssh/authorized_keys
```

### Message of the day

Now, it is time to have some light and fun settings, but useful
nevertheless ! A dynamic status message of the day with server health
information. I like to have a summary of what is installed, what is the
health of the server, what needs to be done, ... immediately when I
connect. Furthermore, it is very useful if you need to share a screenshot
with someone else.

I like these useless banners, there are a lot of choices : `figlet`,
`toilet`, `cowsay` ... and the old `banner`. I will also need `lsb`-tools
to fetch the linux distribution details.

```sh
apt-get install -y figlet toilet lsb-release
```

First part is to generate a banner with the hostname to avoid any mistake
on the server, and to display the current Linux distribution details.

```sh
cat << EOF > /etc/update-motd.d/00-header
#!/bin/sh
[ -r /etc/lsb-release ] && . /etc/lsb-release
if [ -z "\$DISTRIB_DESCRIPTION" ] && [ -x /usr/bin/lsb_release ]; then
    # Fall back to using the very slow lsb_release utility
    DISTRIB_DESCRIPTION=\$(lsb_release -s -d)
fi
figlet -f pagga -w 100 \$(hostname)
printf "\n"
printf "Welcome to %s.\n" "\$DISTRIB_DESCRIPTION"
uname -snrvm
printf "\n"
EOF
chmod +x /etc/update-motd.d/00-header
rm /etc/update-motd.d/10-uname
```

Then, I like to have the date and time, the load average, the memory and
swap usage and a summary of the running processes.

```sh
cat << EOF > /etc/update-motd.d/10-sysinfo
#!/bin/sh
date=\`date\`
load=\`cat /proc/loadavg | awk '{print \$1}'\`
root_usage=\`df -h / | awk '/\\// {print \$(NF-1)}'\`
memory_usage=\`free -m | awk '/Mem:/ { total=\$2 } /buffers\\/cache/ { used=\$3 } END { printf("%3.1f%%", used/total*100)}'\`
swap_usage=\`free -m | awk '/Swap/ { printf("%3.1f%%", "exit !\$2;\$3/\$2*100") }'\`
users=\`users | wc -w\`
time=\`uptime | grep -ohe 'up .*' | sed 's/,/\\ hours/g' | awk '{ printf \$2" "\$3 }'\`
processes=\`ps aux | wc -l\`
ip=\`ip addr | grep inet.*enp | sed 's/.*inet //;s/\\/.*//'\`
echo "System information as of: \$date"
echo
printf "System load:\t%s\tIP Address:\t%s\n" \$load \$ip
printf "Memory usage:\t%s\tSystem uptime:\t%s\n" \$memory_usage "\$time"
printf "Usage on /:\t%s\tSwap usage:\t%s\n" \$root_usage \$swap_usage
printf "Local Users:\t%s\tProcesses:\t%s\n" \$users \$processes
echo
EOF
chmod +x /etc/update-motd.d/10-sysinfo
```

Finally, I generate a list of the packages that need to be upgraded and I
empty the default `/etc/motd` static file. I'll populate it later with
the list of installed services.

```sh
cat << EOF > /etc/update-motd.d/20-upgrades
#!/bin/sh
number=\`apt list --upgradable 2> /dev/null | grep 'upgradable'  | wc -l\`
printf "Available updates : %s\\n" \$number
if [ \$number -gt 0 ]; then
    printf "\\033[1;31mSystem needs %s updates\\033[0m\\n" \$number
    apt list --upgradable
else
    printf "\\033[1;32mSystem is uptodate\\033[0m\\n"
fi
echo
EOF
chmod +x /etc/update-motd.d/20-upgrades
echo > /etc/motd
```

### Misc customizations

Working from command line is not a pain... as soon as it is configured to
fit your needs. This is my minimal console setup : file search, history
search with arrows, missing packages help, powerfull prompt and `vim`
minimal configuration.

`dpkg -S` is fine to find files in the filesystems... as long as they are
belonging to an installed package. Useless to find files that do not
belong to a `.deb` package. `locate` fills this gap.

```sh
apt-get install -y mlocate
updatedb
```

I sometimes connect to my servers while traveling in a train or in a car,
with very weak and unstable network connection. `screen` is my favorite
tool to manage and keep my command line sessions open, even when I'm
disconnected. I could use `tmux` but I'm less used to it.

```sh
apt-get install -y screen
```

Who never typed `netstat` and got the *command not found* error. Then, I
had to find which package provides the command, to install it. With
`command-not-found`, if the command is missing, the error message tries
to fix any posible typo in my command and to suggest packages that
provide these commands. This saves time.

```sh
apt-get install -y command-not-found apt-file
apt-file update
update-command-not-found
```

My prompt displays the user, the hostname, the curent folder, but also
the nested shell level, the last return code and the date/time. Just try
it and you'll understand why these informations are useful.

The nested shell level enables you to better manage your environment
variables, once used to it. The last return code makes obvious when a
command failed. The date and time automatically timestamps your commands
and give you an idea of the execution times when you forgot to use the
`time` command.

This customization also save and reload the history at each command.
Thus, as soon as you type a command in a shell, it is available in the
history of all the other opened shells without relogin. Basically, I have
nearly one single real-time cross-session history.

```sh
cat << EOF >> ~/.bashrc

export PS1='[ \[\033[1;36m\]\u@\h\[\033[0m\]\[\033[1;31m\] ShLvl:$SHLVL\[\033[0m\] \[\033[1;35m\]Cmd:\!\[\033[0m\]\[\033[1;34m\] Ret:$?\[\033[0m\] \[\033[1;33m\]\d \t\[\033[0m\] ]\n\[\033[1;32m\]\w\[\033[0m\] # '
export PROMPT_COMMAND="\${PROMPT_COMMAND:+\$PROMPT_COMMAND\$'\n'}history -a; history -c; history -r"
export TMOUT=600 # 10m auto logout
EOF
```

`Readline`'s history is wonderfull, used everywhere in every interractive
tool, including the shells. Despite the search feature with `Ctrl-R` is
very good, readline can search in the history to auto-complete a command
from the history. If I want to reuse one of my very old previous `ssh`
commands, I can type `ssh` and navigate with the up/down keys only in the
lines begining with `ssh`. Try it, you'll keep it, for sure.

```sh
cat << EOF >> ~/.inputrc
"\e[A": history-search-backward
"\e[B": history-search-forward
EOF
```

**`vim` is the only serious** terminal editor. It can be customized to
have color, line numbers, syntax hilighting, custom status bar, search
highlight... Here is my configuration, too long to describe in detail,
but it is commented in-line.

```sh
apt-get install -y vim-nox vim-addon-manager vim-scripts
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

### Razberry hat installation

- 'console=ttyAMA0,115200' and 'kgdboc=ttyAMA0,115200 and 'console=serial0,115200' are already removed from kernel command line (/boot/cmdline.txt) at bootstrap
- removing '*:*:respawn:/sbin/getty ttyAMA0' from /etc/inittab
`sed -i 's/.*AMA0.*/#&/' /etc/inittab`
- add udev rule for persistent device name
`echo 'KERNEL=="ttyAMA0",SYMLINK+="ttyUSB20", MODE="0666"' > /etc/udev/rules.d/09-tty.rules`
- Disable Bluetooth (conflicting with Razberry)
`echo 'dtoverlay=pi3-disable-bt' >> /boot/config.txt`
`reboot`

## NodeJS

I could install a packaged *NodeJS* and *npm* but *Node-RED* will remove
them at install time, later in this script, to have recent versions.
Thus, I directly install recent versions, with the basic development
tools to compile some code.

```sh
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
sudo apt-get install -y nodejs gcc g++ make build-essential git lsb-release pkg-config
```

## Mosquitto MQTT

https://oneguyoneblog.com/2017/06/20/mosquitto-mqtt-node-red-raspberry-pi/

Let's install the MQTT broker *mosquitto* from the default Raspbian
packages, secure it with a password for each possible connection
(messages to/from the ZWave network, to/from *Node-Red*, to/from the
commandline for test and debug, and to/from *Domoticz*). I can not lock
the process and listen only on *localhost* because I'll have the
*MySensors* meshed network connected through the IP network.

```sh
sudo apt-get install -y mosquitto mosquitto-clients
sudo touch /etc/mosquitto/passwd
sudo mosquitto_passwd -b /etc/mosquitto/passwd zwave zwave2020
sudo mosquitto_passwd -b /etc/mosquitto/passwd nodered nodered2020
sudo mosquitto_passwd -b /etc/mosquitto/passwd cli cli2020
sudo mosquitto_passwd -b /etc/mosquitto/passwd domoticz domoticz2020
sudo chgrp mosquitto /etc/mosquitto/passwd
sudo chmod 640 /etc/mosquitto/passwd
cat << EOF | sudo tee -a /etc/mosquitto/conf.d/default.conf
allow_anonymous false
password_file /etc/mosquitto/passwd
EOF
sudo systemctl restart mosquitto
```

## OpenZWave

### Library

https://github.com/OpenZWave/open-zwave

I can now install the latest OpenZWave release from source. It is
sometimes difficult to find the very last stable release of a software,
compiled for ARM, from a reliable and trustable source... 

```sh
git clone https://github.com/OpenZWave/open-zwave.git
cd open-zwave/
make
sudo make install
sudo ldconfig
MinOZW /dev/ttyUSB20
cd
```

### Control Panel

The control panel is End-of-Life, but it is an easy way and better way to
check that everything is working fine, compared to *MinOZW*. Furthermore,
I can factory reset the ZWave chip (list of devices is stored in the
proprietary chip), set a network security key, add/remove some nodes for
testing... This is only for testing.

```sh
sudo apt-get install -y libmicrohttpd-dev libudev-dev
git clone --depth 1 https://github.com/OpenZWave/open-zwave-control-panel
cd open-zwave-control-panel/
make
./ozwcp
cd
```
http://192.168.1.5:8090/

### ZWave2MQTT gateway

https://github.com/OpenZWave/Zwave2Mqtt

Now, it is time for more serious things. This piece of software will
replace the *Control Panel* for most easy tasks (Add/remove nodes, manage
the nodes, ...) and can make a bridge between the ZWave meshed network
and the MQTT broker ! I include a default configuration for me, you can
adapt it for your need in the Web UI, once installed.

```sh
git clone https://github.com/OpenZWave/Zwave2Mqtt
cd Zwave2Mqtt
npm install
npm run build
cat <<EOF >> store/settings.json
{"mqtt":{"disabled":false,"name":"Mosquitto","host":"192.168.1.6","_ca":"","ca":"","_cert":"","cert":"","_key":"","key":"","port":1883,"reconnectPeriod":5000,"prefix":"Razberry","qos":0,"auth":true,"username":"zwave","password":"zwave2020"},"gateway":{"values":[],"type":0,"payloadType":1},"zwave":{"port":"/dev/ttyAMA0","saveConfig":true,"logging":false,"autoUpdateConfig":true,"pollInterval":5000,"commandsTimeout":30}}
EOF
npm start
```
http://192.168.1.6:8091/

## NodeRed

https://nodered.org/docs/getting-started/raspberrypi

If you followed the previous steps, everything is prepared and the
installation script should be executed smoothly without any warning or
question.

```sh
bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)
sudo systemctl enable nodered.service
sudo systemctl start nodered.service
```
http://192.168.1.6:188/

I suggest to install node-red-dashboard and to use this flow to test that
Node-Red can send commands and receive messages.

## Domoticz

https://www.sigmdel.ca/michel/ha/domo/domo_03_fr.html

```sh
curl -sSL install.domoticz.com | sudo bash
sudo sed -i 's%#\(DAEMON_ARGS="$DAEMON_ARGS -log /tmp/domoticz.txt"\)%\1%' /etc/init.d/domoticz.sh
sudo systemctl daemon-reload
sudo systemctl restart domoticz
```


## Redis

I chose to install the community edition, I don't need high-availability,
scalability, ... And I chose the packaged version :

```sh
sudo apt-get install -y redis-server
```

Then, I updated some settings in the configuration file :

```sh
echo 'bind 0.0.0.0' | sudo tee -a /etc/redis/redis.conf
echo 'protected-mode no' | sudo tee -a /etc/redis/redis.conf
```

# Next steps

Now, everything is installed, The next steps are to configure *nodered* :
- listen to the ZWave network events in the MQTT broker, translate them in domoticz format and publish them in domoticz topic
- listen to domoticz events from the domoticz topic, translate them in
  zwave format and publish them in the right zwave topic
- listen to the zwave events from the MQTT broker and write them in
  different formats in Redis


# Materials and Links

| Link | Description |
|---|---|
| [Video] | Demonstration screencast recording |

# Footnotes

[Thingiverse]: https://www.thingiverse.com/thing:2770235 "Home automation center"
[^1]: [https://www.thingiverse.com/thing:2770235][Thingiverse]

[MySNode]: https://www.openhardware.io/view/684/MySensors-Low-power-Multi-function-node-on-CR2032 "MySensors customized node"
[^2]: [https://www.openhardware.io/view/684/MySensors-Low-power-Multi-function-node-on-CR2032][MySNode]

[MySensors]: https://www.mysensors.org/ "MySensors web site"
[^3]: [https://www.mysensors.org/][MySensors]

[MyWeather]: https://www.thingiverse.com/thing:2936265 "My weather station"
[^4]: [https://www.thingiverse.com/thing:2936265/][MyWeather]

[exercicesdeck_slidesonly]: {{ "/assets/posts/" | append: page.uid | append:"/exercicesdeck_slidesonly.pdf" | relative_url }} "Exercices slidedeck without notes"
[Video]: https://youtu.be/xZhq5jgKFmQ "Demonstration video recording"
