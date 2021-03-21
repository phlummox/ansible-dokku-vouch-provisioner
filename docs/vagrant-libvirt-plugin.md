
# Installing the vagrant libvirt plugin

The default Vagrant provider is Virtualbox, but `libvirt`
might be faster and less resource-hungry on Linux.

In this directory is a Dockerfile, which shows what you
might need to build the libvirt plugin ... (probably we
don't actually need all that).

## Instructions

Clone this repo.

Build Docker image with:

```
$ docker build -f docs/vagrant-libvirt-plugin/Dockerfile \
     -t proxy:libvirt-test-0.1  .
```

then cd to top of repo, and run with:

```
$ docker -D run --rm  -it --net=host --privileged \
      -v $PWD:/opt/work \
      -v /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock \
      --workdir /opt/work \
      proxy:libvirt-test-0.1
```

Once in, should be able to:

```
$ /make-kvm-node.sh
$ cd ansible-config/roles/dokku.install/ && molecule --debug --verbose test --scenario-name libvirt-scenario
```

(Of course, you need to have kvm installed *outside* the container,
on the host; but still.)

Recall also it needs ipv6, you may need to amend
`/etc/default/grub` and then `sudo update-grub`
