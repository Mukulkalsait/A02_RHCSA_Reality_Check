**LVM + Disk Management Cheatsheet**  
Save this as `lvm-disk-cheatsheet.md`

### Quick Command Reference Table

| Command                  | Full Meaning                              | What it does (normal use) |
|--------------------------|-------------------------------------------|---------------------------|
| `lsblk`                  | List Block devices                        | Shows disk/partition layout + mount points |
| `df -h`                  | Disk Free (human readable)                | Shows filesystem usage in GB |
| `pvdisplay`              | Physical Volume display                   | Shows PV details (size, free space) |
| `pvresize`               | Physical Volume resize                    | Makes LVM see new space after partition grow |
| `vgdisplay`              | Volume Group display                      | Shows VG total size + free space |
| `lvdisplay`              | Logical Volume display                    | Shows LV size, path, status |
| `lvextend -l +100%FREE`  | Logical Volume extend                     | Grows LV to use all free space in VG |
| `lvextend -r -l +100%FREE` | Logical Volume extend + resize filesystem | Grows LV **and** filesystem in one command |
| `resize2fs`              | Resize ext4 filesystem                    | Makes ext4 filesystem use the new bigger LV |
| `lvresize`               | Logical Volume resize                     | Modern way to grow/shrink LV |
| `lvreduce`               | Logical Volume reduce                     | Shrinks LV (dangerous – needs unmount) |
| `du -sh /*`              | Disk Usage (summary)                      | Shows which folders use the most space |

---

### Detailed Commands (Normal Use Only)

#### 1. `lsblk`
**Purpose**: Best way to see your entire disk layout at a glance.  
**Normal use**:
```bash
lsblk                    # simple view
lsblk -f                 # shows filesystem type + UUID
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,RM
```

#### 2. `df -h`
**Purpose**: Shows how much space is actually available on mounted filesystems.  
**Normal use**:
```bash
df -h                    # human readable
df -h /                  # only root filesystem
```

#### 3. `pvdisplay`
**Purpose**: Shows Physical Volume (the raw partition used by LVM).  
**Normal use**:
```bash
sudo pvdisplay           # full info
sudo pvdisplay -v        # more verbose
```

#### 4. `pvresize`
**Purpose**: After you grow a partition (with `cfdisk` etc.), tell LVM to use the extra space.  
**Normal use**:
```bash
sudo pvresize /dev/sda3
```

#### 5. `vgdisplay`
**Purpose**: Shows the Volume Group (the big pool of space).  
**Normal use**:
```bash
sudo vgdisplay
sudo vgdisplay -v
```

#### 6. `lvdisplay`
**Purpose**: Shows your Logical Volumes (the actual usable drives like `/`).  
**Normal use**:
```bash
sudo lvdisplay
```

#### 7. `lvextend` (most common command you just used)
**Purpose**: Grow a Logical Volume.  
**Normal use**:
```bash
# Grow to use ALL free space
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv

# Grow + resize filesystem in ONE command (recommended)
sudo lvextend -r -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
```

#### 8. `resize2fs`
**Purpose**: Grows (or shrinks) the **ext4** filesystem after you extended the LV.  
**Normal use**:
```bash
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv     # uses full LV size
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
```

#### 9. `lvresize` (modern alternative)
**Purpose**: Same as `lvextend` but shorter and supports shrink too.  
**Normal use (grow)**:
```bash
sudo lvresize -l +100%FREE -r /dev/ubuntu-vg/ubuntu-lv
```

#### 10. `lvreduce` (shrink – use with caution)
**Purpose**: Reduce LV size (you must shrink filesystem **first**).  
**Normal use** (example – shrink by 50 GB):
```bash
# First shrink filesystem (safe way)
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv 400G
# Then shrink LV
sudo lvreduce -L -50G /dev/ubuntu-vg/ubuntu-lv
```

#### 11. `du -sh` (bonus – very useful)
**Purpose**: Find which folders are eating your disk space.  
**Normal use**:
```bash
sudo du -sh /* | sort -hr          # top level folders
sudo du -sh /var/* | sort -hr      # check /var
```

---

**Pro Tips (copy-paste ready)**

```bash
# 1. Full status check (run this first)
sudo pvdisplay && sudo vgdisplay && sudo lvdisplay && df -h /

# 2. The one-liner you should remember forever
sudo lvextend -r -l +100%FREE /dev/ubuntu-vg/ubuntu-lv

# 3. After any change, always verify
df -h /
lsblk -f
```

You now have a complete, ready-to-use cheatsheet.  
Just copy everything above into a file called `lvm-cheatsheet.md` and keep it on your server (or your laptop).

Want me to add anything else (like `fdisk`, `parted`, or how to create new LVs)? Just tell me! 🚀
