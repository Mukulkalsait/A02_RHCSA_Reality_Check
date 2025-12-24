#!/bin/bash

echo "========================================================="
echo "        UNIVERSAL LINUX BASE IMAGE INSPECTOR"
echo "========================================================="
echo

# 1) OS INFO
echo "👉 OS INFORMATION"
[ -f /etc/os-release ] && cat /etc/os-release || echo "No /etc/os-release found"
echo

# 2) WHO IS PID 1?
echo "👉 PID 1 / INIT PROCESS"
ps -p 1 -o pid,comm,args
echo

# 3) SYSTEMD LOCATION CHECK
echo "👉 SYSTEMD PATH CHECKS"
readlink -f /sbin/init 2>/dev/null && echo "Found /sbin/init → $(readlink -f /sbin/init 2>/dev/null)"
readlink -f /usr/sbin/init 2>/dev/null && echo "Found /usr/sbin/init → $(readlink -f /usr/sbin/init 2>/dev/null)"
which systemd 2>/dev/null && echo "systemd binary → $(which systemd 2>/dev/null)"
which systemctl 2>/dev/null && echo "systemctl binary → $(which systemctl 2>/dev/null)"
echo

# 4) SYSTEMD VERSION
echo "👉 SYSTEMD VERSION"
systemd --version 2>/dev/null || echo "systemd not available"
echo

# 5) SSHD EXPECTED LOCATIONS
echo "👉 SSHD DIRECTORIES"
echo "/run/sshd exists?          " $([ -d /run/sshd ] && echo YES || echo NO)
echo "/var/run/sshd exists?      " $([ -d /var/run/sshd ] && echo YES || echo NO)
echo "/etc/ssh/sshd_config exists?" $([ -f /etc/ssh/sshd_config ] && echo YES || echo NO)
echo

# 6) CGROUP VERSION
echo "👉 CGROUP INFORMATION"
grep cgroup /proc/filesystems
cat /proc/cgroups 2>/dev/null
echo "cgroup mounts:"
mount | grep cgroup
echo

# 7) NETWORK INTERFACES
echo "👉 NETWORK DEVICES"
ip -o link show 2>/dev/null | awk -F': ' '{print $2}' || echo "ip not available"
echo

# 8) PACKAGE MANAGER DETECTION
echo "👉 PACKAGE MANAGER"
command -v apt >/dev/null 2>&1 && echo "APT found (Debian/Ubuntu)"
command -v dnf >/dev/null 2>&1 && echo "DNF found (Rocky/RHEL/Fedora)"
command -v microdnf >/dev/null 2>&1 && echo "microdnf found (UBI)"
command -v yum >/dev/null 2>&1 && echo "YUM found (older RHEL/CentOS)"
command -v pacman >/dev/null 2>&1 && echo "Pacman found (Arch)"
command -v apk >/dev/null 2>&1 && echo "APK found (Alpine)"
echo

# 9) CPU & RAM
echo "👉 CPU / MEMORY"
grep "model name" /proc/cpuinfo 2>/dev/null | head -n 1
grep "MemTotal" /proc/meminfo 2>/dev/null
echo

# 10) DEFAULT SHELL
echo "👉 DEFAULT SHELL"
echo "$SHELL"
echo

echo "========================================================="
echo "               INSPECTION COMPLETE 🎉"
echo "========================================================="
