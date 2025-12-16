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
