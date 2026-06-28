ARG BASE_IMAGE=quay.io/fedora/fedora-bootc:44
FROM ${BASE_IMAGE}

#Update base image
RUN dnf update && dnf clean all

#General Packages
RUN dnf install -y \
    git \
    fastfetch \
    skopeo \
    distrobox \
    osbuild-composer \
    composer-cli \
    && dnf clean all

#Installing and starting cockpit ui
RUN dnf install -y \
    cockpit \
    cockpit-podman \
    cockpit-selinux \
    cockpit-image-builder \
    && dnf clean all \
    && systemctl enable cockpit.socket osbuild-composer.socket
# Add caddy cert to trusted certs for HTTPS
COPY root.crt /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust

#Setting up users

RUN useradd -m -G wheel brotcon26 \
    && passwd -l brotcon26 \
    && mkdir -p /home/brotcon26/.ssh \
    && chown brotcon26:brotcon26 /home/brotcon26/.ssh \
    && chmod 700 /home/brotcon26/.ssh
    #&& loginctl enable-linger brotcon26
    
#No password sudo -> using ssh key auth only
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' \
      > /etc/sudoers.d/wheel-nopasswd


COPY --chown=brotcon26:brotcon26 --chmod=600 \ 
    ssh_pubkeys /home/brotcon26/.ssh/authorized_keys

COPY ssh_key_only /etc/ssh/sshd_config.d/nopasswd.conf

# Add cockpit user
RUN useradd -m -G wheel eomer && echo 'eomer:password' | chpasswd