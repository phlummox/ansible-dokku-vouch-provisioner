demo
=========

Demo role

Requirements
------------

none

Role Variables
--------------

none

Dependencies
------------

Doesn't depend on any other roles.

Example Playbook
----------------

Assume the `ansible_roles` directory is at `path/to/ansible_roles`.

And that rather than an inventory, we're just running the role
on the server `my-dokku-server`.

And that we have a simple playbook, my-playbook.yml:


```
---
- hosts: all
  become: yes
  become_method: sudo
  tasks:
    - name: Include the demo role
      include_role:
        name: demo
```

Then can run with:

```
$ ANSIBLE_ROLES_PATH=path/to/ansible_roles ansible-playbook -i "my_dokku_server," ./my-playbook.yml
```

If we want to avoid using an env var, and provide nicer output, we
can create an `ansible.cfg` file:


```
[defaults]
stdout_callback = yaml
roles_path = path/to/ansible_roles
timeout = 30
```

Run demo tests
--------------

cd into this directory, and

`molecule test [--debug --verbose]  --scenario-name default-scenario`



<!--
  vim: tw=72 :
-->
