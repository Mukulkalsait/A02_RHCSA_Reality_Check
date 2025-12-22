
Great — locked in:

* **SSH password login: YES**
* **2 simulated disks per container: YES**
* **Make sure disks do NOT consume real local storage: YES → use sparse files (0 bytes used).**

Now I will explain **exactly how disks work** so you never face storage problems, then I’ll generate **all Dockerfiles + scripts + compose** in clean code blocks.

---

# 🧡 READ THIS BEFORE THE FILES

## ✔ How the “disks” work (safe, no storage risk)

We will create the disks using **sparse files**, like:

```
truncate -s 2G disk1.img
truncate -s 2G disk2.img
```

### Sparse file = looks 2GB but actually takes **0 MB** on host storage

Used space grows **only when you write data inside the image**.

Example:

```
du -h disk1.img → 0B
ls -lh disk1.img → 2.0G (virtual size)
```

So your laptop will not fill up.

### These will be mounted inside each container as:

```
/mnt/disk1
/mnt/disk2
```

And you can:

* mkfs
* mount
* fdisk
* LVM (pvcreate → vgcreate → lvcreate)

Everything works normally.

---

# 📁 Final Folder Structure Reminder

```
rhcsa-lab/
│
├── docker-compose.yml
│
├── ubuntu-lts/
│   ├── Dockerfile
│   ├── scripts/init.sh
│   └── config/sshd_config
│
├── rocky/
│   ├── Dockerfile
│   ├── scripts/init.sh
│   └── config/sshd_config
│
├── arch/
│   ├── Dockerfile
│   ├── scripts/init.sh
│   └── config/sshd_config
│
├── rhel-ubi/
│   ├── Dockerfile
│   ├── scripts/init.sh
│   └── config/sshd_config
│
└── shared/
    ├── authorized_keys
    ├── default-user.env
    ├── motd
```

---

# 🚀 NOW THE FILES

Below are all files exactly as required.

---

# ===============================

# 📄 **docker-compose.yml**

# ===============================

```yaml
version: "3.9"

services:

  ubuntu:
    container_name: ubuntu-lts
    build: ./ubuntu-lts
    privileged: true
    volumes:
      - ./shared/authorized_keys:/root/.ssh/authorized_keys:ro
      - ./disks/ubuntu/disk1.img:/mnt/disk1
      - ./disks/ubuntu/disk2.img:/mnt/disk2
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    environment:
      - container=podman
    command: ["/usr/sbin/init"]
    ports:
      - "2201:22"

  rocky:
    container_name: rocky
    build: ./rocky
    privileged: true
    volumes:
      - ./shared/authorized_keys:/root/.ssh/authorized_keys:ro
      - ./disks/rocky/disk1.img:/mnt/disk1
      - ./disks/rocky/disk2.img:/mnt/disk2
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    environment:
      - container=podman
    command: ["/usr/sbin/init"]
    ports:
      - "2202:22"

  arch:
    container_name: arch
    build: ./arch
    privileged: true
    volumes:
      - ./shared/authorized_keys:/root/.ssh/authorized_keys:ro
      - ./disks/arch/disk1.img:/mnt/disk1
      - ./disks/arch/disk2.img:/mnt/disk2
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    environment:
      - container=podman
    command: ["/usr/lib/systemd/systemd"]
    ports:
      - "2203:22"

  ubi:
    container_name: rhel-ubi
    build: ./rhel-ubi
    privileged: true
    volumes:
      - ./shared/authorized_keys:/root/.ssh/authorized_keys:ro
      - ./disks/ubi/disk1.img:/mnt/disk1
      - ./disks/ubi/disk2.img:/mnt/disk2
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    environment:
      - container=podman
    command: ["/usr/sbin/init"]
    ports:
      - "2204:22"

networks:
  default:
    name: rhcsa_net
```

---

# ===============================

# 📄 **shared/motd**

# ===============================

```text
Welcome to RHCSA Multi-OS Lab (Podman)
Practice. Break. Fix. Repeat.
```

---

# ===============================

# 📄 SSH Config (same for all)

# ===============================

### Place in:

* `ubuntu-lts/config/sshd_config`
* `rocky/config/sshd_config`
* `arch/config/sshd_config`
* `rhel-ubi/config/sshd_config`

```text
Port 22
PermitRootLogin no
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
AllowTcpForwarding yes
```

---

# ===============================

# 📁 UBUNTU-LTS

# ===============================

# 📄 ubuntu-lts/Dockerfile

```Dockerfile
FROM ubuntu:22.04

ENV container podman

RUN apt-get update && \
    apt-get install -y systemd systemd-sysv openssh-server sudo \
    vim curl less iproute2 procps && \
    apt-get clean

# SSH fix
RUN mkdir -p /var/run/sshd

# User
RUN useradd -m -s /bin/bash examuser-ubuntu && \
    echo "examuser-ubuntu:exam123" | chpasswd && \
    usermod -aG sudo examuser-ubuntu

COPY config/sshd_config /etc/ssh/sshd_config
COPY scripts/init.sh /init.sh
RUN chmod +x /init.sh

CMD ["/sbin/init"]
```

# 📄 ubuntu-lts/scripts/init.sh

```bash
#!/bin/bash
echo "Ubuntu container booting with systemd"
```

---

# ===============================

# 📁 ROCKY

# ===============================

# 📄 rocky/Dockerfile

```Dockerfile
FROM rockylinux:9

ENV container podman

RUN dnf clean all && \
    dnf install -y systemd openssh-server sudo firewalld \
    vim less curl iproute procps-ng && \
    dnf clean all

RUN mkdir -p /run/sshd

RUN useradd -m -s /bin/bash examuser-rocky && \
    echo "examuser-rocky:exam123" | chpasswd && \
    usermod -aG wheel examuser-rocky

COPY config/sshd_config /etc/ssh/sshd_config
COPY scripts/init.sh /init.sh
RUN chmod +x /init.sh

CMD ["/usr/sbin/init"]
```

# 📄 rocky/scripts/init.sh

```bash
#!/bin/bash
echo "Rocky Linux booting..."
```

---

# ===============================

# 📁 ARCH

# ===============================

# 📄 arch/Dockerfile

```Dockerfile
FROM archlinux:latest

ENV container podman

RUN pacman -Sy --noconfirm systemd openssh sudo vim curl less iproute2 procps-ng

RUN mkdir -p /run/sshd

RUN useradd -m -s /bin/bash examuser-arch && \
    echo "examuser-arch:exam123" | chpasswd

COPY config/sshd_config /etc/ssh/sshd_config
COPY scripts/init.sh /init.sh
RUN chmod +x /init.sh

CMD ["/usr/lib/systemd/systemd"]
```

# 📄 arch/scripts/init.sh

```bash
#!/bin/bash
echo "Arch container booting..."
```

---

# ===============================

# 📁 RHEL UBI

# ===============================

# 📄 rhel-ubi/Dockerfile

```Dockerfile
FROM registry.access.redhat.com/ubi9/ubi-init

ENV container podman

RUN microdnf install -y openssh-server sudo firewalld \
    vim less curl iproute procps-ng && \
    microdnf clean all

RUN mkdir -p /run/sshd

RUN useradd -m -s /bin/bash examuser-ubi && \
    echo "examuser-ubi:exam123" | chpasswd && \
    usermod -aG wheel examuser-ubi

COPY config/sshd_config /etc/ssh/sshd_config
COPY scripts/init.sh /init.sh
RUN chmod +x /init.sh

CMD ["/usr/sbin/init"]
```

# 📄 rhel-ubi/scripts/init.sh

```bash
#!/bin/bash
echo "RHEL UBI container booting..."
```

---

# ===============================

# 📁 Disk Creation (Important)

# ===============================

Create sparse disks:

```bash
mkdir -p disks/ubuntu disks/rocky disks/arch disks/ubi

truncate -s 2G disks/ubuntu/disk1.img
truncate -s 2G disks/ubuntu/disk2.img

truncate -s 2G disks/rocky/disk1.img
truncate -s 2G disks/rocky/disk2.img

truncate -s 2G disks/arch/disk1.img
truncate -s 2G disks/arch/disk2.img

truncate -s 2G disks/ubi/disk1.img
truncate -s 2G disks/ubi/disk2.img
```

These use **0 MB actual disk** until you write data inside.

---

# 🚀 READY FOR LAB LAUNCH

Build all images:

```
podman-compose build
```

Start all OS:

```
podman-compose up -d
```

SSH into them:

```
ssh -p 2201 examuser-ubuntu@localhost
ssh -p 2202 examuser-rocky@localhost
ssh -p 2203 examuser-arch@localhost
ssh -p 2204 examuser-ubi@localhost
```

---

If everything looks good →
**Next: I’ll generate the video script where we introduce this entire lab setup.**
