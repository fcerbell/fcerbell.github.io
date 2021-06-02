---
uid: Debian112Preparation020SSHinstallationandconfiguration
title: Debian11, Preparation, SSH installation and configuration
description: Ensure that `ssh` is configured. Secure it to forbid any direct password-based connection. Only key-challenge authentication is allowed.
category: Computers
tags: [ Debian11 Preparation, GNU Linux, Linux, Debian, Debian 10, Debian 11, Buster, Bullseye, Server, Installation, SSH, Password, Passwordless, Key-pair, Authentication, Prohibit-password ]
date: 2021-05-20 00:02:00
---

Ensure that `ssh` is configured. Secure it to forbid any direct password-based connection. Only key-challenge authentication is allowed.

* TOC
{:toc}

# Prerequisites

## Load the variables in the environment

We need to load the named username defined in the configuration file during the [Sudo installation and configuration](/Debian112Preparation010Sudoinstallationandconfiguration-en/) post. Ensure that the configuration variables are loaded in the environment.
```bash
source /root/config.env
```

# SSH server configuration

Force *SSHv2* (disable *SSHv1*), forbid direct root connection with a password (only with key-pair), create a PID file to make monitoring easier, and keep hostnames clear in the `known_hosts` file (do not hash). Hashing the hostnames is probably more secure in case of intrusion, but it is a pain when you change your other machines IP addresses.
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

# Regenerate machine and root's SSH keys

The machine should already have an ssh key pair. In some cases, mainly if you changed the hostname, you need to regenerate a key pair. If you used a service provider to automatically install the system, can you trust him enough ? I don't. Some of them took the server keys to enable their support to connect to your machine and to "help" you. Currently, no other machine depends on the possibly existing host key, so I can safely regenerate it. 
Root do not have a key-pair yet. I create one, which will probably never be used, and it also has the benefit to initialize the `/root/.ssh` folder structure.
```bash
ssh-keygen -q -f "/etc/ssh/ssh_host_dsa_key" -t dsa -N ''
ssh-keygen -f /root/.ssh/id_rsa -q -N ""
```

# Add the backup server's key to root's authorized_keys

If a backup robot need to backup this server, it needs to connect as root, password-less (key challenge based) to be able to backup every file from the filesystems.

**This key is specific for my backup server. Don't use it unless you want to give me full access to your machine**

```bash
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDX94WcZhrCjWXffCckgeEROTB0PnvpOxlFm/scvxTfTlh0sNV4KTrfHWrClDdBus6e7JL2VIltJBDdDHgetTaOK6HnHkmwoHFq+xm8TYqHQc3dzD8YMhjmFLRwHNDMadvy/oLrcae+e/moGUVdfsnjNbX2tjGMlld8ZwGUXPysvB70S+VpKgZ2e24xTvFNdPaTIDGky3EOeCI54iRXyAsHvKV0xFQJQf+FiiUQYoo2wCNsCgIqXD1ue0mpId8vjD7OCBBQE/T5sl+PWOUYxMEjVt9QmtLxunjC948c5RJLo96Gjg5bhwRJD7bHAKvgH984AeNnKuHMhN9P8f8bantP OMV' >> /root/.ssh/authorized_keys
```

# Add my public key to the root's authorized keys

I also want to be able to open a direct *root* connection passwordless with my private key. This can be seen as a bad practice, but I'm the only admin. It would be stupid to force me to connect to an named account before switching to root and it would increase the attacking surface with an extra user account. From my point of view, given that no anonymous root connection will be possible (only with SSH keys), and it reduces the attack surface, thus I consider this is more secure. I might be wrong.

![sshroot.gif]({{ "/assets/posts/en/Debian112Preparation020SSHinstallationandconfiguration/4cf189e22d33461c9840d9931d7e85a8.gif" | relative_url }})

**This key is specific for me. Don't use it unless you want to give me full access to your machine**

```bash
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAtM8LzekUr46wvVNWoYzxPuKVTv7yFp+Aa/a1vKAendFa3xsMZz6Pp0Xn8U5ZYbTpqqVeM8O+ETqjtpBVk+7+C516DwB+R/cKulTjy061fBPZvTp5pIKm4+NQXNBhwjmQs//nWJ54PlDS5mHuj9NalX07b2OBztrvLjPzf/m4sB0= Francois Cerbelle' >> /root/.ssh/authorized_keys
```

# Add my public key to the user's authorized keys

I will soon lock the named user's password, I need to be able to connect passwordless with my private key. I add my public key to the authorized keys file.
This is only needed if you need to keep named user's system account.

![sshuser.gif]({{ "/assets/posts/en/Debian112Preparation020SSHinstallationandconfiguration/3e5241515925425a8591419eda31e0b1.gif" | relative_url }})

**This key is specific for me. Don't use it unless you want to give me full access to your machine**

```bash
[ ! -z "${UN}" ] && (
mkdir /home/${UN}/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAtM8LzekUr46wvVNWoYzxPuKVTv7yFp+Aa/a1vKAendFa3xsMZz6Pp0Xn8U5ZYbTpqqVeM8O+ETqjtpBVk+7+C516DwB+R/cKulTjy061fBPZvTp5pIKm4+NQXNBhwjmQs//nWJ54PlDS5mHuj9NalX07b2OBztrvLjPzf/m4sB0= Francois Cerbelle' >> /home/${UN}/.ssh/authorized_keys
chown -R ${UN}.${UN} /home/${UN}
)
```

