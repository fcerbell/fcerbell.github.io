---
uid: Debian112Preparation020SSHinstallationandconfiguration
title: Debian11, Préparation, Installation et configuration de SSH
description: Assurons nous que `ssh` est bien configuré. Sécurisons-le pour interdire toute connexion directe basée sur un mot de passe. Seule une authentification par défi de clé privée/publique est autorisée
category: Informatique
tags: [ Préparation Debian11, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Serveur, Installation, SSH, Mot de passe, Clé, Authentification, Prohibit-password ]
date: 2021-05-20 00:02:00
---

Assurons nous que `ssh` est bien configuré. Sécurisons-le pour interdire toute connexion directe basée sur un mot de passe. Seule une authentification par défi de clé privée/publique est autorisée

* TOC
{:toc}

# Pré-requis

## Chargement des variables dans l'environnement

Nous avons besoin du nom d'utilisateur nommé, enregistré dans le fichier de configuration par l'article [Installation et
configuration de Sudo](/Debian112Preparation010Sudoinstallationandconfiguration-fr/). Assurons-nous que les variables d'environnement
soient bien chargées :
```bash
source /root/config.env
```

# Configuration du serveur SSH

Je force le protocole *SSHv2* (et interdit *SSHv1*), interdit les connexions root à l'aide d'un mot de passe (uniquement avec une
paire de clé), demande la création d'un fichier de PID pour aider la supervision plus tard et conserve les noms de machine en
clair dans le fichier `known_hosts` (sans les masquer). Le processus de masquage des noms de machine est probablement plus sûr en
cas de compromission d'un compte ou de la machine, mais c'est une véritable plaie lorsque des machines changent d'IP et qu'il faut
modifier ce fichier.
```bash
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

# Régénération des paires de clé du serveur et de root

La machine devrait déjà avoir une paire de clés. Dans certains cas, principalement lorsque le nom de la machine a été modifié, il
faut régénérer les paires. Si vous avez utilisé un fournisseur de service pour installer automatiquement le système, pouvez lui
faire assez confiance ? Pas moi ! Certains prenent les clés du serveur pour permettre à leur support de se connecter à vos
machines et pour vous *aider*. Actuellement aucune autre machine ne dépend de ces clés (sauf celle depuis laquelle vous vous
connectez), il est donc sûr de les régénérer.
Le compte *root* ne dispose pas encore de clés. J'en génère, elles ne seront probablement jamais utilisées, mais cela permet aussi
d'ininitaliser le répertoire `/root/.ssh`.
```bash
ssh-keygen -q -f "/etc/ssh/ssh_host_dsa_key" -t dsa -N ''
ssh-keygen -f /root/.ssh/id_rsa -q -N ""
```

# Ajout de la clé du serveur de sauvegarde au compte root

Si un robot de sauvegarde doit prendre cette machine en charge, il aura besoin de s'y connecter en tant que root, sans mot de
passe, pour accéder à chaque fichier du système.

**Cette clé est spécifique à mes serveurs de sauvegarde. Ne l'utilisez par à moins que vous ne souhaitiez me donner les pleins
pouvoir sur votre nouvelle machine !**

```bash
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDX94WcZhrCjWXffCckgeEROTB0PnvpOxlFm/scvxTfTlh0sNV4KTrfHWrClDdBus6e7JL2VIltJBDdDHgetTaOK6HnHkmwoHFq+xm8TYqHQc3dzD8YMhjmFLRwHNDMadvy/oLrcae+e/moGUVdfsnjNbX2tjGMlld8ZwGUXPysvB70S+VpKgZ2e24xTvFNdPaTIDGky3EOeCI54iRXyAsHvKV0xFQJQf+FiiUQYoo2wCNsCgIqXD1ue0mpId8vjD7OCBBQE/T5sl+PWOUYxMEjVt9QmtLxunjC948c5RJLo96Gjg5bhwRJD7bHAKvgH984AeNnKuHMhN9P8f8bantP OMV' >> /root/.ssh/authorized_keys
```

# Ajout de ma clé personelle au compte root

Je souhaite aussi pouvoir me connecter directement en tant que *root*, sans mot de passe, à l'aide de ma clé privée personnelle.
Cela peut sembler être une mauvaise pratique mais je suis le seul administrateur. Ce serait stupide de forcer une connexion à un
compte nommé uniquement dans le but de basculer en *root* et cela augmenterait la surface d'attaque avec un compte supplémentaire.
De mon point de vue, comme il n'est pas possible de se connecter à root anonymement (uniquement à l'aide d'une clé privée
autorisée), je considère cette méthode plus sûr, je peux me tromper. Au final, que je passe en direct ou à travers un utilisateur
nommé, l'authentification se fait sur une clé SSH.

![sshroot.gif]({{ "/assets/posts/en/Debian112Preparation020SSHinstallationandconfiguration/4cf189e22d33461c9840d9931d7e85a8.gif" | relative_url }})

**Cette clé est spécifique à mes serveurs de sauvegarde. Ne l'utilisez par à moins que vous ne souhaitiez me donner les pleins
pouvoir sur votre nouvelle machine !**

```bash
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAtM8LzekUr46wvVNWoYzxPuKVTv7yFp+Aa/a1vKAendFa3xsMZz6Pp0Xn8U5ZYbTpqqVeM8O+ETqjtpBVk+7+C516DwB+R/cKulTjy061fBPZvTp5pIKm4+NQXNBhwjmQs//nWJ54PlDS5mHuj9NalX07b2OBztrvLjPzf/m4sB0= Francois Cerbelle' >> /root/.ssh/authorized_keys
```

# Ajout de ma clé personnelle au compte utilisateur

Je vais bientôt verrouiller le mot de passe du compte utilisateur, j'aurai donc besoin de m'y connecter sans mot de passe, à
l'aide de ma clé privée. Je l'ajoute donc aux clés autorisées.
Ceci n'est nécessaire que si vous conservez un compte utilisateur nommé dans le système.

![sshuser.gif]({{ "/assets/posts/en/Debian112Preparation020SSHinstallationandconfiguration/3e5241515925425a8591419eda31e0b1.gif" | relative_url }})

**Cette clé est spécifique à mes serveurs de sauvegarde. Ne l'utilisez par à moins que vous ne souhaitiez me donner les pleins
pouvoir sur votre nouvelle machine !**

```bash
[ ! -z "${UN}" ] && (
mkdir /home/${UN}/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAtM8LzekUr46wvVNWoYzxPuKVTv7yFp+Aa/a1vKAendFa3xsMZz6Pp0Xn8U5ZYbTpqqVeM8O+ETqjtpBVk+7+C516DwB+R/cKulTjy061fBPZvTp5pIKm4+NQXNBhwjmQs//nWJ54PlDS5mHuj9NalX07b2OBztrvLjPzf/m4sB0= Francois Cerbelle' >> /home/${UN}/.ssh/authorized_keys
chown -R ${UN}.${UN} /home/${UN}
)
```

