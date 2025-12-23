FROM archlinux:latest

ENV container podman

# RUN pacman -Sy --noconfirm && \
#     pacman -Rdd --noconfirm systemd-sysvcompat && \
#     pacman -S --noconfirm systemd openssh sudo vim curl less iproute2 procps-ng && \
#     pacman -Scc --noconfir

RUN pacman -Syu --noconfirm
RUN pacman -Sy --noconfirm systemd openssh sudo vim curl less iproute2 procps-ng
# S = install |  y = update |  --noconfirm no need of Y 
RUN mkdir -p /run/sshd


RUN useradd -m -s /bin/bash examuser-arch && \
    echo "examuser-arch:asdf123" | chpasswd

COPY ./config/sshd_config /etc/ssh/sshd_config
COPY ./scripts/init.sh /init.sh
RUN chmod +x /init.sh

RUN systemctl enable sshd

CMD [ "/usr/lib/systemd/systemd" ]


# systemd pathys in all dextros
#
# | OS         | systemd binary                                          |
# | ---------- | ------------------------------------------------------- |
# | Ubuntu     | `/sbin/init` → symlink → `/lib/systemd/systemd`         |
# | Debian     | `/sbin/init`                                            |
# | Rocky      | `/usr/sbin/init` → symlink → `/usr/lib/systemd/systemd` |
# | UBI / RHEL | `/usr/sbin/init`                                        |
# | Arch       | `/usr/lib/systemd/systemd`                              |
# to find => bash >
# $ which systemctl
# $ readlink -f /sbin/init
# $ readlink -f /usr/sbin/init
# $ readlink -f /sbin/init 2>/dev/null
# $ readlink -f /usr/sbin/init 2>/dev/null
# $ which systemd 2>/dev/null
# $ which systemctl 2>/dev/null
# $ systemctl --version
# $ ls -l /usr/lib/systemd/systemd
# $ ls -l /sbin/init
# $ ls -l /usr/sbin/init
#
# R: to use this commands 
# podman run -it --privileged --rm <image> /bin/bash
# then 
# ps -p 1 -o comm=
#
# 1> = redirect stdout
# 2> = redirect stderr
# /dev/null = a "black hole" where all data disappears.
#
# So:
#
# 👉 2>/dev/null
# Means:
# Hide if errors but keep real output.
# #
# Use it when: ❌ You expect some commands to fail and ✔️ You don’t want to show ugly errors.
