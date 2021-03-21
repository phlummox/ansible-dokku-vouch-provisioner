
# Create provisioned dokku images

This directory contains a packer file (plus supporting files)
to create:

- a qemu qcow2 image of an Ubuntu 20.04 box, provisioned
  with dokku
- a Vagrant box, made from the qemu image
- md5sum of the Vagrant pox

## For more docco

See https://github.com/hashicorp/packer/issues/3959
for making qcow out of qcow using packer.

See <https://www.packer.io/docs/builders/qemu#disk_image>
for docco from hashicorp on qemu builders.

See also for setting up your own equivalent of a
private Vagrant Cloud, with versioned boxes,
<https://github.com/hollodotme/Helpers/blob/master/Tutorials/vagrant/self-hosted-vagrant-boxes-with-versioning.md>

## Some packer tips

Format for specifying Vagrant box metadata:

if you look in the `info.json` file for a generic/XXX box,
you can see:

```
 "Author": "Ladar Levison",
 "Website": "https://roboxes.org/",
 "Artifacts": "https://vagrantcloud.com/generic/",
 "Repository": "https://github.com/lavabit/robox/",
```

Also, the lavabit/robox github repo has plenty of sample
packer files (tho in the older JSON format unfortunately).

For another source, see the repo at
<https://github.com/jakobadam/packer-qemu-templates>

## Running a qemu box

Once have got a qcow2 image, should be able to run it with libvirt
using something like:

```
$ virt-install --name my-good-name --graphics none --memory 1024 --vcpus 2 --disk /path/to/my-img.qcow2,bus=sata --import --network default
```

(Docco for virt-install says it would be helpful to pass
`--os-variant ubuntu16.04` or similar, but we're using ubuntu20.04,
which it doesn't have a record of. So we do without.)

After a while, some message saying "^]" is the escape code
comes up; since there's no actuall _installing_ we need to do,
just hit ctrl-] and leave.

After a while the new vm will DHCP itself an ip address, and
you can type `virsh net-dhcp-leases default` to see what it is.
And then 'ssh vagrant@some.ip.address', with password 'vagrant',
will get you in.

You should also be able to run a qcow image with `qemu-system-x86_64`, tho
note any changes you make will be permanent; something like:

```
$ qemu-system-x86_64 -name ubuntu-dokku \
                    -display none \
                    -nographic \
                    -netdev user,id=user.0,hostfwd=tcp::2233-:22 \
                    -device virtio-net,netdev=user.0 \
                    -drive file=/path/to/image.qcow2,if=virtio,cache=writeback,discard=ignore,format=qcow2 \
                    -machine type=pc,accel=kvm \
                    -smp cpus=2,sockets=2 \
                    -m 1024M \
```

## Running a vagrant box

Invoke vagrant to add the box we've created:

```
$ vagrant box add --name ubuntu-dokku /path/to/my/box-file.box
```

We can then (best to do this in a fresh directory):

```
$ vagrant init ubuntu-dokku
$ vagrant up --provider libvirt
$ vagrant ssh
```

If we wanted nicer versioning, we could make ourselves
a local Vagrant cloud-like: see

<https://github.com/hollodotme/Helpers/blob/master/Tutorials/vagrant/self-hosted-vagrant-boxes-with-versioning.md#4-using-a-box-catalog-for-versioning>

We'd make a directory, e.g. MyVagrantBoxes, and in it create
a file `ubuntu-dokku.json` with some metadata in it about the box,
and in Vagrantfiles, we can then add a line

```
  config.vm.box_url = "file://~/MyVagrantBoxes/ubuntu-dokku.json"
```

if we want to use those boxes.


