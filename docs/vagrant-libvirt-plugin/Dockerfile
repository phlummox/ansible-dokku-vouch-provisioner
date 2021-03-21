
FROM ubuntu:xenial@sha256:e02d30494327090a50e9a6575c018d067428ae3abdcadb208e9ecd9cb496cf98

RUN apt-get clean && \
  apt-get update

RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install \
    -y --no-install-recommends \
        apt-transport-https         \
        bridge-utils                \
        build-essential             \
        bzip2                       \
        ca-certificates             \
        curl                        \
        git                         \
        kvm                         \
        libguestfs-tools            \
        libvirt-bin                 \
        locales                     \
        make                        \
        qemu-kvm                    \
        software-properties-common  \
        sudo                        \
        tar                         \
        unzip                       \
        wget                        \
        xz-utils                    \
        zip

# As of ubuntu 18.04, libvirt-bin still works
# but is marked as transitional -- the replacement
# package is libvirt-clients.

ARG VAGRANT_VERSION=2.2.14
ENV VAGRANT_VERSION=${VAGRANT_VERSION}

RUN \
  curl -L https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb > vagrant.deb && \
  apt install ./vagrant.deb

RUN \
  DEBIAN_FRONTEND=noninteractive apt-get install \
    -y --no-install-recommends \
        libvirt-dev       \
        libxml2-dev       \
        libxslt-dev       \
        ruby-dev          \
        zlib1g-dev

RUN \
  CONFIGURE_ARGS="with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib" \
    vagrant --debug plugin install --verbose \
        vagrant-libvirt

# Normally, don't run update-alternatives like this, as that
# may break Ubuntu tools (like apt ones) that
# rely on a different version of python3.
# But here we don't care as we won't use them.
RUN \
  add-apt-repository ppa:deadsnakes/ppa && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
        python3.6               \
        python3.6-dev           \
        libffi-dev              \
        libssl-dev && \
  update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1

COPY .ci-scripts/get-pip.py /tmp
COPY ansible-config/requirements.txt /tmp

RUN \
      python3 /tmp/get-pip.py && \
      pip3 install -r /tmp/requirements.txt

RUN \
  echo "#!/usr/bin/env bash" > /make-kvm-node.sh  && \
  echo '\
#!/bin/bash \n\
set -ex     \n\
\n\
# Create the kvm node (requires --privileged)\n\
if [ ! -e /dev/kvm ]; then\n\
   mknod /dev/kvm c 10 $(grep '\''\\<kvm\\>'\'' /proc/misc | cut -f 1 -d'\'' '\'')\n\
fi\n\
\n\
# If we have a BRIDGE_IF set, add it to /etc/qemu/bridge.conf\n\
if [ -n "$BRIDGE_IF" ]; then\n\
   echo "allow $BRIDGE_IF" >/etc/qemu/bridge.conf\n\
   # Make sure we have the tun device node\n\
   if [ ! -e /dev/net/tun ]; then\n\
      mkdir -p /dev/net\n\
      mknod /dev/net/tun c 10 $(grep '\''\\<tun\\>'\'' /proc/misc | cut -f 1 -d'\'' '\'')\n\
   fi\n\
fi\n\
#exec /usr/bin/kvm $@\n\
  ' \
  >> /make-kvm-node.sh && \
    chmod a+rx /make-kvm-node.sh

RUN \
      ansible --version

ENV PATH=/root/.local/bin:$PATH

RUN \
  mkdir -p /root/.local/bin && \
  locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

