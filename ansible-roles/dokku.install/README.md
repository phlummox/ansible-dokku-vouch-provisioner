dokku.install
=========

Install dokku and do some minimal setup.

Installs letsencrypt plugin if not exist, ensures we don't have a
"default web app" that can leak thru, sets up ssh keys for `dokku`
user based on `root`.

Set timezone to Australia/Perth.

Requirements
------------

Requires that the host be running Ubuntu 20.04, pretty much.

Also requires that an ssh server and python be installed,
so ansible can get started.

Role Variables
--------------

- `DOKKU_SERVER_HOST_NAME`: hostname to use

Dependencies
------------

Doesn't depend on any other roles.

Example Playbook
----------------

Sample inventory -- a vagrant instance you've got up and running, w/ ssh
configured so that password login is ok on port 2211:

my-playbook.yml:

```
---
- hosts: proxy_server
  # or could just use "hosts: all"
  become: yes
  become_method: sudo
  tasks:
    - name: Include the dokku.install role
      include_role:
        name: dokku.install
      vars:
        DOKKU_SERVER_HOST_NAME: my-proxy-server
```

my-inventory.yml:

```
all:
  hosts:
    proxy_server:
      ansible_host: "somehost.lan"
      ansible_port: 2211
      ansible_ssh_user: 'vagrant'
      ansible_password: 'vagrant'
      ansible_ssh_extra_args: '-o StrictHostKeyChecking=no'
```

ansible.cfg:

```
[defaults]
stdout_callback = yaml
roles_path = roles
timeout = 30
```

Then can run with:

```
$ ansible-playbook -v -i ./my-inventory.yml ./my-playbook.yml
```


<!--
  vim: tw=72 :
-->
