# dokku + vouch proxy provisioning code

- ansible code to provision and configure a dokku server
  and set up a vouch proxy (<https://github.com/vouch/vouch-proxy>)
  on it.

Also:

- install-ansible:

  code to install ansible, in case it's not already installed.
  In a virtualenv, if desired.

- vagrant-test-image:

  A Vagrantfile for creating a libvirt Vagrant image for developing
  with.

## Current status

Experimental and in-progress.

Not yet suitable for public consumption, though anyone is
welcome to make use of the code if they find it useful.

## Prerequisites

python >= 3.7.

On versions of Ubuntu earlier than 20.04, you will likely need to
install an additional version of python.

The ansible-roles Makefile calls gnu `time`; on MacOS X, install it
with `brew install gnu-time` (and then fix your PATH so it can be
called as just `time` -- see the .github/workflow file).

### PATH value

The various makefiles may assume that $HOME/.local/bin
is on your PATH.

## Ansible roles in this repo

They're under `ansible_roles`. To use them, add them to your
ansible role path -- see below,
"Using the ansible roles if you already have ansible".

demo:

- a demo role, just to test if your environment is working ok.

dokku.install:

- set up dokku on a fresh vm

dokku.configure

- configure dokku - disable fallback site

dokku.apps.clone-and-push

- really just a wrapper around the `dokku_push` module
  and plugin, to allow them to be tested.

dokku.apps.vouch.create

- create or re-create the Vouch app.
- very un-idempotent.

## Ansible modules

Are in `ansible-lib/modules`.

See <https://docs.ansible.com/ansible/latest/dev_guide/developing_locally.html#adding-a-module-locally>
for how to ensure they're picked up.

### Action plugins

Are in `ansible-lib/plugins/action`.

See <https://docs.ansible.com/ansible/latest/dev_guide/developing_locally.html#adding-a-plugin-locally>
for how to ensure they're picked up -- viz.,
add the dir to `ANSIBLE_ACTION_PLUGINS`.

See the ansible docco for more on action plugins.

Basically:
- plugins can do/orchestrate things on the localhost *before* the
  task gets run on the target host, and can call other
  plugins or modules, or create and run tasks
- modules (unless this is changed with `delegate_to`) run on the
  remote host, and can't call other modules
- if you have a module and an action plugin with the same name,
  then when a playbook calls the module, the action plugin actually
  gets run first (and it may or may not call the module itself).

  As a result, often the module is a "stub", that just
  contains documentation for use by ansible-doc, no code.
- the `dokku_push` plugin has some links to more docco on all this.


## check that vagrant is working with virtualbox

In a fresh directory,

`vagrant init ubuntu/bionic64`

then

`vagrant up` and `vagrant ssh`.

Note that KVM and VirtualBox (allegedly) can't both be running -
we need to unload kvm kernel modules for VirtualBox to run.
(Tho they seems to both work on my ubuntu 18.04 system.)
See <https://www.dedoimedo.com/computers/kvm-virtualbox.html>

So try:


```
# use virsh list to get list of running VMs,
# virsh destroy to stop them.
$ sudo systemctl stop libvirtd
$ sudo systemctl stop libvirt-bin
$ sudo systemctl stop qemu-kvm
# might need `sudo lsof | grep /dev/kvm` to see if anything else using kvm
$ sudo modprobe -r kvm_intel
$ sudo modprobe -r kvm
```

Then will need to start all those again if required.

Then try "If you need to install ansible", below, except use
'virtualbox-scenario' instead of 'libvirt-scenario'.

## check that libvirt/qemu is working

```
$ wget http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/x86_64/alpine-virt-3.7.0-x86_64.iso
$ virt-install \
  --name alpine1 \
  --ram 256 \
  --disk path=/var/lib/libvirt/images/alpine1.img,size=8 \
  --vcpus 1 \
  --os-type linux \
  --os-variant generic \
  --network bridge:virbr0,model=virtio \
  --graphics none \
  --console pty,target_type=serial \
  --cdrom ./alpine-virt-3.7.0-x86_64.iso
```

See
<https://blog.ruanbekker.com/blog/2018/02/20/setup-a-kvm-hypervisor-on-ubuntu-to-host-virtual-machines/>

and note that `^]` (or `ctrl-]`??) escapes you from the kvm console.

Once alpine image running, can get into console using

```
$ sudo virsh console alpine1
```

and if you set up ssh properly,

`virsh net-dhcp-leases default` will show you the ip address of your
vm, and you can then ssh in.

## check that libvirt/qemu is working *for vagrant*

cd in to `vagrant_test_image`, and `make vagrant_up`.
If more detail needed, insert "`--debug`" as a an arg
to vagrant in the Makefile.

Troubleshooting:

See https://github.com/vagrant-libvirt/vagrant-libvirt/issues/598
if error occurs like

```
Error saving the server: Call to virDomainDefineXML failed: invalid argument: could not find capabilities for domaintype=kvm
```

See also <https://old.reddit.com/r/linuxadmin/comments/ezrnnh/libvirt_has_no_kvm_capabilities_even_though/>
for some good diagnostics to run.

## If you need to install ansible

```
# install ansible
$ currdir=$PWD
$ cd install-ansible && make env && . activate && make py_prereqs
# check it's working
$ ansible --version
$ cd $currdir
$ cd ansible-roles/demo/ && molecule test  --scenario-name libvirt-scenario
```

(between `molecule` and `test` can add `--debug --verbose`
if desired)

## Running tests

See the Makefile within `ansible-roles` for useful targets:

- `run_tests_vbx` will run tests using Ansible's Vagrant/Virtualbox provider
- `run_tests_libvirt` will use the Vagrant/libvirt provider.

The Makefile plus scripts will install ansible and other
Python packages if they're not installed. By default,
they're installed into a virtualenv in install-ansible/env;
if the environment variable "CI" is set to the string "true",
they're installed globally.

## Using the ansible roles if you already have ansible

- Clone the repo, or otherwise put `ansible_roles` in a
  known place. We will assume they're at /path/to/my/ansible-roles

- We assume you have some target host called `my-dokku-host`,
  which is to be provisioned.

- Write a simple playbook which `include`s the roles you want to
  run. We will assume it's in a file `my-playbook.yml`.
  This one just runs the demo role:

  ```
  ---
  - hosts: all
    become: yes
    become_method: sudo
    tasks:
      - name: Run the demo role
        include_role:
          name: demo
  ```

  (could later add:

  ```
      - name: Run the dokku.install role
        include_role:
          name: dokku.install
        vars:
          DOKKU_SERVER_HOST_NAME: my-dokku-fqdn
  ```

  )

- Run playbook with:

  `ANSIBLE_ROLES_PATH=/path/to/my/ansible-roles ansible-playbook -i "my-dokku-host," my-playbook.yml`

## Sample playbooks

See the sample-playbooks dir.


## Using a vagrant box for dev and testing

**simple:**

cd in to `vagrant_test_image`, and `make vagrant_up`.

To get some lines you can past into your ~/.ssh/config
to easily ssh into it, run `vagrant ssh-config` once
it's up.

**works well when iterating over role and test development:**

`cd` into ansible-roles/SOME-ROLE, and then
do similar to what the `run_tests` targets do; except instead of
`molecule test`, type `molecule converge`; that will bring up a
test instance.

`molecule verify` runs the tests, `molecule destroy`
brings down the image, `molecule converge` re-runs the
tasks for the role.


# Troubleshooting

## If vagrant/molecule complains "domains already exist"

You could try running `ansible-cleanup.sh`.

## If libvirt/qemu complains about "couldn't allocate memory" or somesuch

You could try running:

```
$ sync
$ echo 3 | sudo tee /proc/sys/vm/drop_caches
```

(This doesn't actually change a kernel setting, at all,
but directs the kernel to drop some caches.)

(See docco at
<https://github.com/torvalds/linux/blob/v5.4/Documentation/admin-guide/sysctl/vm.rst#drop_caches>,
or whatever your kernel version is.  \
Mentioned as a fix at <https://stackoverflow.com/a/60604376/6818792>.  \
See also
<https://forum.proxmox.com/threads/memory-allocation-failure.41441/>,
which suggests that even if you have enough memory, you might not have
enough *contiguous* memory.)

<!--
  vim: ts=2 sw=2 tw=72 :
-->
