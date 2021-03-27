#!/usr/bin/env bash

set -eou pipefail

BOX_TO_USE='generic/alpine312'
VM_NAME=sample-alpine-vm

set -x

vagrant box add --provider libvirt "$BOX_TO_USE"
qcow_file="$(ls ~/.vagrant.d/boxes/generic-VAGRANTSLASH-alpine312/*/libvirt/box.img | head -n 1)"

virt-install \
  --name $VM_NAME \
  --memory 256 \
  --vcpus 1 \
  --disk "$qcow_file" \
  --network network=default,model=virtio \
  --os-type=linux \
  --graphics none \
  --noautoconsole \
  --import

for ((i=0; i<5; i=i+1)) ; do
  echo $i
  sleep 3
done

vm_state="$(virsh domstate ${VM_NAME})"

# assert that state is running:
[ "$vm_state" = "running" ]

# try ssh-ing

vm_ip_addr="$(virsh domifaddr ${VM_NAME}  | awk '{ print $4; }' | tail -n +2)"

vm_dirs="$(sshpass -pvagrant ssh "vagrant@${vm_ip_addr}" ls / | wc -l)"

# assert files in root dir is at least 4 (say)
(( vm_dirs >= 4 ))

virsh destroy $VM_NAME
virsh undefined $VM_NAME

set +x
