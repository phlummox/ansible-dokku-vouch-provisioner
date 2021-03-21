#!/usr/bin/env bash

set -eou pipefail

set -x
vagrant global-status --prune
set +x

libvirt_vms=`virsh list --all | tail -n +3 | awk '{ print $2; }'`

for vm in $libvirt_vms; do
  set -x
  virsh destroy $vm || true;
  virsh undefine $vm || true;
  set +x
done

libvirt_vols=`virsh vol-list default | tail -n +3 | awk '{ print $2; }'`

for vol in $libvirt_vols; do
  set -x
  virsh vol-delete $vol;
  set +x
done

set -x
rm -rf ~/.cache/molecule
rm -rf ~/.ansible

sudo systemctl restart libvirt-bin
sudo systemctl restart libvirt-guests

