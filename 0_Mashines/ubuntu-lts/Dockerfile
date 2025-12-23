FROM ubuntu:22.04

ENV container podman
#Y: disable hardware-related services (udev, dbus-hw, mounts, real tty management) and not to panic if kernel features are missing
#without it 
#
# - System has not been booted with systemd as init system
# - Failed units: systemd-udevd, systemd-logind

RUN apt update && \
    apt install -y --no-install-recommends systemd systemd-sysv openssh-server sudo \
    vim curl iproute2 procps && \
    apt-get clean
# --no-install-recommends => systemd-doc/timesync, man, locale stuff, polkit, udev extras
#
# with install we got cache here 
# /var/lib/apt/lists/*
# /var/cache/apt/*
# so apt-get clean 


# ssh .pid file kept here 
# some contianer nnot create this folder so :
RUN mkdir -p /var/run/sshd

#user 
RUN useradd -m -s /bin/bash examuser-ubuntu && \
    echo "examuser-ubuntu:asdf123" | chpasswd && \
    usermod -aG sudo examuser-ubuntu

COPY config/sshd_config /etc/sshd/ssh_config

# ssh_config = client config
# sshd_config = server config
#
# We want server settings like:
#
#  - PasswordAuthentication yes
#  - PermitRootLogin no
#
# So this must go to: /etc/ssh/sshd_config.

COPY ./scripts/init.sh /init.sh
RUN chmod +x /init.sh
# this script never automatically runs unless we do => podman exec -it ubuntu-lts /init.sh
#
# or 
#
# Option 3: Create a systemd service that runs at boot 
# | [Unit]
# | Description=Run custom init script
# |
# | [Service]
# | Type=simple
# | ExecStart=/init.sh
# |
# | [Install]
# | WantedBy=multi-user.target
#
# and enable it with RUN systemctl enable custom-init.service



# This starts systemd as the first process.
# PID 1 = systemd
# Systemd: never exits automatically, runs background services, manages sshd, manages logs, handles signals, So the container stays alive forever, like a real VM.
# Exactly what we want.

CMD [ "/sbin/init" ]
