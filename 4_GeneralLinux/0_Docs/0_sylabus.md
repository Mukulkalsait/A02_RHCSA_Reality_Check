Good. This is the *right* mindset. I’ll do this in a **structured, admin-first way**, not SRE-marketing talk.

I’ll answer in **three layers**:

1. **Complete Linux Admin syllabus (what to study + depth)**
2. **Answers to all your exam questions (with real explanations)**
3. **What extra you must know that exams won’t ask but admins must**

No comfort talk. Just facts.

---

# 1️⃣ LINUX ADMIN → SRE: WHAT YOU MUST STUDY (AND HOW DEEP)

Think of Linux knowledge in **layers**.

---

## 🔹 LAYER 0: UNIX / Linux BASICS (MANDATORY)

> This is where your gaps are right now.

### A. Files & Permissions (VERY IMPORTANT)

You must know **cold**:

| Topic                      | Depth                  |
| -------------------------- | ---------------------- |
| File types (`- d l c b s`) | What they mean         |
| Permission bits            | rwx math               |
| Octal permissions          | Convert mentally       |
| `umask`                    | Default permissions    |
| Special bits               | setuid, setgid, sticky |
| `chmod`, `chown`, `chgrp`  | Recursive behavior     |
| Hard vs soft links         | inode behavior         |
| Deletion (`unlink`)        | open file deletion     |

📌 This alone covers **30–40% of admin MCQs**

---

### B. Shell Behavior (YOU GOT TRICKED HERE)

You must know:

| Topic               | Why                       |
| ------------------- | ------------------------- |
| Globbing (`* ? []`) | `cp *` confusion          |
| Expansion order     | why commands behave oddly |
| Quoting rules       | `" "` vs `' '`            |
| Exit codes          | scripting & debugging     |
| Redirection         | `> >> < 2>`               |

---

### C. Filesystem Internals (ADMIN LEVEL)

| Topic      | Depth                 |
| ---------- | --------------------- |
| Inodes     | limits, deletion      |
| Block size | performance           |
| Mounts     | persistent vs runtime |
| FS types   | ext4, xfs             |
| Max files  | inode exhaustion      |

---

## 🔹 LAYER 1: CORE ADMIN TOOLING

> This is where admins live.

### A. Disk & Storage

| Topic               | Must Know            |
| ------------------- | -------------------- |
| `lsblk`, `df`, `du` | capacity             |
| `mount`, `umount`   | recovery             |
| `fsck`              | corruption           |
| `dd`                | disk ops (DANGEROUS) |
| MBR vs GPT          | boot                 |
| RAID levels         | 0,1,5,6,10           |

---

### B. Process & System

| Topic               | Depth              |
| ------------------- | ------------------ |
| `ps`, `top`, `htop` | process            |
| signals             | SIGTERM vs SIGKILL |
| systemd             | services           |
| logs                | journald           |

---

### C. Users, Groups, Quotas

| Topic                        | Why                |
| ---------------------------- | ------------------ |
| `/etc/passwd`, `/etc/shadow` | auth               |
| Groups                       | permission control |
| Disk quotas                  | multi-user systems |

---

## 🔹 LAYER 2: NETWORKING (ADMIN LEVEL)

| Topic               | Must Know       |
| ------------------- | --------------- |
| TCP 3-way handshake | exams + reality |
| Ports               | services        |
| DNS basics          | failures        |
| `ss`, `netstat`     | debugging       |

---

## 🔹 LAYER 3: SRE (AFTER ADMIN)

Only after all above:

* Monitoring
* Alerting
* Reliability
* Performance
* Automation

📌 **You cannot skip admin layer and become real SRE**

---

# 2️⃣ ANSWERS TO YOUR EXAM QUESTIONS (WITH EXPLANATION)

---

### **Q1. `umask 000 && touch filename` → permissions?**

* Default file permission: **666**
* umask **000** blocks nothing

✅ Result:

```
-rw-rw-rw-   (0666)
```

---

### **Q2. System call that removes a file in UNIX?**

✅ **`unlink()`**

Important:

* File disappears from directory
* Data stays until last process closes it

---

### **Q3. Octal for `-rwxr-sr--`**

Break it:

| Part  | Meaning          |
| ----- | ---------------- |
| Owner | rwx → 7          |
| Group | r-s → 5 + setgid |
| Other | r-- → 4          |

Setgid = **2**

✅ **2754**

---

### **Q4. TCP 3-way handshake**

1. SYN
2. SYN-ACK
3. ACK

---

### **Q5. What limits max files in filesystem?**

✅ **Number of inodes**

Not disk size.

---

### **Q6. Show date 20 days from now**

```bash
date -d "20 days"
```

---

### **Q7. Directory has `a` and `b`, you run `cp *`**

❌ ERROR:

```
cp: missing destination file operand
```

Because `cp` needs **source + destination**

---

### **Q8. Command to set user/group quotas**

✅ `edquota`

Also:

* `quota`
* `quotaon`

---

### **Q9. Remove all directories (multi-select)**

Correct:

* ✅ `rm -rf *`
* ✅ `rmdir *` (only if empty)

Wrong:

* ❌ `rm -d *`
* ❌ `rmdir -rf *`

---

### **Q10. RAID 0+1**

* RAID-0 stripes
* Then mirrored

Performance + redundancy
Less common than RAID-10

---

### **Q11. Clear MBR of `/dev/sda`**

```bash
dd if=/dev/zero of=/dev/sda bs=512 count=1
```

💀 **Destructive command**

---

# 3️⃣ THINGS EXAMS DON’T ASK BUT ADMINS MUST KNOW

These WILL hit you in real life:

* Disk full but `df` shows free → inode exhaustion
* Deleted log still eating space → open file
* `rm -rf /` accidents → why `--preserve-root`
* Service up but port closed → firewall
* User can’t write → group permissions
* RAID degraded → rebuild procedure

---

# FINAL TRUTH (NO SUGARCOATING)

* Your **Linux usage ≠ Linux administration**
* You skipped classical UNIX theory → now visible
* This is **normal and fixable**
* You’re **not behind**, you’re **unstructured**

If you want, next I can:

* Build a **7-day Linux Admin recovery plan**
* Or make a **cheat-sheet for all MCQ-style traps**
* Or convert this into **hands-on labs**

Just say which one.
