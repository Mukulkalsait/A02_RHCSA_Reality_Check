FROM rockylinux:9
ENV container podman

RUN dnf clean all && \ 
    dnf install -y  --allowerasing systemd openssh-server sudo firewalld \ 
    vim less curl iproute procps-ng && \
    dnf clean all
# ps top free uptime kill = procps-ng or procps (ng =next gen)


RUN mkdir -p /run/sshd

RUN useradd -m -s /bin/bash examuser-rocky && \ 
    echo "examuser-rocky:asdf123" | chpasswd && \ 
    usermod -aG wheel examuser-rocky


COPY ./config/sshd_config /etc/ssh/sshd_config

COPY ./scripts/init.sh /init.sh
RUN chmod +x /init.sh

CMD [ "/usr/sbin/init" ]


