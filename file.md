FROM debian:latest
# SHELL ["/bin/bash","-c"] bash willnot work
RUN apt update -y && \
    apt upgrade -y
RUN apt install -y sudo procps iproute2 net-tools vim curl 
RUN sudo useradd -m -s /bin/bash trainee -G sudo
RUN mkdir -p /lab/projects && \
    chown -R trainee:trainee /lab && \
    chmod 700 /lab
USER root
WORKDIR /lab/projects
CMD ["sleep","3600"]


persistence fo file 

Perfect question. This is **real infra thinking** 👌
You’re right: **right now your container is stateless**. Once it’s deleted → **lab data gone**.

There are **TWO correct, DevOps-grade ways** to add persistence.
I’ll explain **what to change**, **why**, and **exact commands**.

---

# 🧠 FIRST: CLEAR CONCEPT (VERY IMPORTANT)

Dockerfile **cannot** make storage persistent by itself.

> 🔴 Persistence is decided at **runtime**, not build time.

Dockerfile only **declares** where data *should live*.
The **container engine** decides whether that path is:

* ephemeral ❌
* persistent ✅

---

# ✅ METHOD 1 (RECOMMENDED): VOLUME + `-v` / `--mount`

## 🔹 Step 1: Declare volume in Dockerfile (BEST PRACTICE)

Add **this single line** near the end:

```dockerfile
VOLUME ["/lab/projects"]
```

### Updated Dockerfile (cleaned + fixed)

```dockerfile
FROM debian:latest

RUN apt update -y && apt upgrade -y

RUN apt install -y \
    sudo vim iproute2 net-tools curl procps

RUN useradd -m -s /bin/bash trainee && \
    echo "trainee ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir -p /lab/projects && \
    chown -R trainee:trainee /lab && \
    chmod 700 /lab

WORKDIR /lab/projects

VOLUME ["/lab/projects"]

CMD ["sleep","3600"]
```

⚠️ Note:

* `sudo` **inside Dockerfile is wrong** (build runs as root anyway)
* Fixed it properly

---

## 🔹 Step 2: Run container with persistent volume (Podman)

### Named volume (BEST for labs)

```bash
podman volume create labdata
```

```bash
podman run -dt \
  --name lab1 \
  -v labdata:/lab/projects \
  podmaninstallation_container:latest
```

Now:

* Delete container ❌ → data stays ✅
* Recreate container → same lab data

---

## 🔹 Verify persistence

```bash
podman exec -it lab1 bash
touch testfile.txt
exit
```

```bash
podman rm -f lab1
```

```bash
podman run -dt --name lab1 -v labdata:/lab/projects IMAGE
```

➡️ `testfile.txt` is still there 🔥

---

# ✅ METHOD 2: Bind Mount (HOST DIRECTORY)

Best when you want **GitHub sync / screen recording clarity**

```bash
mkdir -p ~/devops-labs/lab1
```

```bash
podman run -dt \
  --name lab1 \
  -v ~/devops-labs/lab1:/lab/projects \
  IMAGE
```

Now:

* Host ↔ Container shared
* Perfect for **proof-of-work videos**

---

# ⚠️ METHOD YOU SHOULD NOT USE (FOR LABS)

❌ Relying on container filesystem
❌ Writing data outside declared volumes
❌ Expecting Dockerfile to “save data”

Say this line in video 👇

> “Container mhanje disposable,
>
> data mhanje valuable.”

---

# 🧪 MULTIPLE LABS FROM SAME IMAGE (YOUR CORE IDEA)

```bash
podman volume create lab_user
podman volume create lab_net
podman volume create lab_storage
```

```bash
podman run -dt --name lab_user    -v lab_user:/lab/projects IMAGE
podman run -dt --name lab_net     -v lab_net:/lab/projects IMAGE
podman run -dt --name lab_storage -v lab_storage:/lab/projects IMAGE
```

🔥 **Same image, different RHCSA labs**

---

# 🎯 EXAM + JOB READY LINE (USE THIS)

> “Image ekda build kara,
>
> labs vegle vegle volume madhe chala.”

---

If you want next:

* `podman generate systemd` (auto-start labs)
* Volume backup & restore
* Snapshot-style lab reset
* RHCSA task mapping to volumes

Just say the word.

