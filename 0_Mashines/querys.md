✅ 1. Why systemd shows “degraded”

    _  Inside containers, systemd cannot start certain services because: 
    _  There’s no real hardware (no tty, no storage devices, no udev) 
    _  Security namespaces block some kernel APIs 
    _  Some services require privileged mode 
    _  Services like systemd-networkd, NetworkManager, firewalld cannot fully run unless configured explicitly 
    _  So systemd marks the machine “degraded” because a few units are failing — this is expected for containers. 
    _  You only care about: 
    _  sshd → running ✔️ 
    _  systemd-networkd → running or not required (podman gives eth0) 
    _  firewalld → only works in Rocky/RHEL container, not needed in Arch 
    _  systemd-resolved → running ✔️ 
    _  This is exactly what your logs show. 
