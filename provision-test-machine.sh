#!/usr/bin/env bash

set -x

mkdir -p ~/.local/bin
echo 'export PATH=${HOME}/.local/bin:${PATH}' >> ~/.bashrc
export PATH=${HOME}/.local/bin:${PATH}

if [ -z "$VAGRANT_VERSION" ] ; then
  VAGRANT_VERSION="2.2.14"
fi

if [ -z "$LIBVIRT_PLUGIN_VERSION" ] ; then
  LIBVIRT_PLUGIN_VERSION="0.0.1"
fi

if [ -z "$CI" ] ; then
  CI=""
fi


set -eou pipefail

sudo apt-get update

VAGRANT_URL="https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb"
dir=`mktemp -d tmp-downloaded-vagrant-deb-XXXXX`
curl -L "${VAGRANT_URL}" > $dir/vagrant.deb
sudo apt install $PWD/$dir/vagrant.deb

sudo apt install -y --no-install-recommends \
    curl                        \
    gcc                         \
    libvirt-bin                 \
    libvirt-dev                 \
    make                        \
    openssh-client              \
    pv                          \
    python3.8-dev               \
    python3.8-distutils         \
    qemu-kvm                    \
    qemu-utils                  \
    sshpass                     \
    time                        \
    virtinst                    \
    wget                        \
    xz-utils                    \
    zip

sudo systemctl start libvirtd
SYSTEMD_COLORS=1 systemctl --no-pager status libvirtd  | cat

sudo adduser $USER libvirt
sudo adduser $USER kvm

# script got via
#   curl https://bootstrap.pypa.io/get-pip.py
# as at 2022-06-29
python3.8 .ci-scripts/get-pip.py

python3.8 -m pip install --user --upgrade \
    pip         \
    pip-tools   \
    virtualenv  \
    wheel

: "check tool versions"

gcc     --version
python3.8 -m pip    --version
python3 --version
ssh     -V
vagrant --version
virsh   --version

: "install libvirt plugin for vagrant"


LIBVIRT_PLUGIN_URL="https://github.com/phlummox/vagrant-in-vagrant/releases/download/v${LIBVIRT_PLUGIN_VERSION}/vagrant.d.tgz"

curl -L "${LIBVIRT_PLUGIN_URL}" | tar x -z -C ~

vagrant plugin list | grep vagrant-libvirt

: "test libvirt plugin for vagrant"

# args:
#  - test_box: Vagrant box to use for testing (e.g. generic/ubuntu1804)
#  - lv_driver: libvirt driver to use (either "kvm" or "qemu")
libvirt_test () {
  local test_box=$1
  local lv_driver=$2
  vagrant box add --provider libvirt $test_box || true

  cat > Vagrantfile <<EOF
  Vagrant.configure("2") do |config|
    config.vm.box         = "$test_box"
    config.vm.provider :libvirt do |lv|
      lv.driver = '${lv_driver}'
    end
  end
EOF

  sudo su -l $USER -c "set -ex; export CI=$CI; export PATH=$PATH; cd $PWD; pwd; id; ls -al /var/run/libvirt/libvirt-sock; vagrant up --no-provision --debug --provider libvirt; vagrant ssh -- ls  / | grep boot"
}

# When running on GitHub CI -- use vagrant-in-vagrant
# as our test box here, seems to work best.
# Else if running elsewhere (e.g. on a desktop machine),
# we're probably already running in vagrant-in-vagrant,
# so use a plain box so as not to get network conflict.
#
# (also on GitHub CI, can't use kvm)
if [ "$CI" = "true" ]; then
  test_box=phlummox/vagrant-in-vagrant;
  lv_driver=qemu;
else
  test_box=generic/ubuntu1804;
  lv_driver=kvm;
fi

tmpdir="$(mktemp -d libvirt-test-XXXXXX)";
cd "$tmpdir";
libvirt_test $test_box $lv_driver

