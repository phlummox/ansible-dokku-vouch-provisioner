dokku.apps.clone-and-push
=========================

Clone some git repo to the local host, and push to a dokku server.

Really just a wrapper around the `dokku_push` ansible module
and action plugin, to allow them to be tested.

Requirements
------------

Software packages requirements:

- git and bash must be installed on localhost.
- ssh probably needs to be installed on localhost,
  as the code hasn't been checked with a non-ssh
  transport.
- server has to have dokku (and its prerequisites)
  installed

Authentication requirements:

- Access to the git repo being cloned (if over git+ssh), and the git push
  of the repo onto the Dokku server, will be done using the
  (localhost) user's credentials (viz, their public ssh key).
- So for this to work, the user must *either* have passwordless
  access to their ssh key, or will have to provide a password at
  runtime.
- The ssh key has to be in `$HOME/.ssh/id_rsa.pub` of the
  user.

Side-effects:

- The (localhost) user's ssh public key is added to the
  `authorized_keys` of dokku @ the remote host.

NB:

- The git push currently uses ssh options

  `-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'`

  So if you want strict checking you'll need to amend the code.

Role Variables
--------------

- `app_name`: Name of the dokku app. Required.
- `repo_url`: URL for a git repo. Required.
- branch: what branch to push. Default "master"
- force (boolean): whether to add "--force" to the git args.
  Optional, default is false.


Example Playbook
----------------

```yaml
---
- hosts: somehost
  # (or "hosts: all", and specify on command line)
  become: true
  tasks:
    - dokku_push:
        app_name: "my-dokku-app"
        branch: "main"
        repo_url: "https://github.com/someuser/somerepo.git"
        force: false
```

