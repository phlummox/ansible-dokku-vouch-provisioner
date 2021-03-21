dokku.apps.vouch.create
=========

Create (or rebuild) a Vouch dokku app on
some host running Dokku. Internal port used is 9090.

Includes a "clone-repo.sh" script (which we probably should
share with other roles), which clones a repo from a git url to a dir
on the *localhost* (i.e.  where ansible is being invoked), then
pushes it to our dokku host.

args for it are:
 dokku app name, git url, dokku hostname, [--force]

Where other git flags could be inserted before --force.


Requirements
------------

Dokku and letsencrypt plugin should be installed.

Role Variables
--------------

Optional variables:

- appname: default value, "vouch". Name of the app.
- `use_letsencrypt`: whether to use letsencrypt at all, default true
- `letsencrypt_type`: either "staging" or "default",
  default value is "staging"
- `vouch_testing`: a string, "true" or "false"; passed
  to vouch via the `VOUCH_TESTING` env var. If true,
  vouch goes into testing mode, and shows all redirects
  as links, without doing them. Default value is "false".
- `vouch_loglevel`: a string, passed as `VOUCH_LOGLEVEL`.
  Default value is "info".
- `vouch_whitelist`: A string, viz. a comma-separated list
  of whitelisted email addresses. Default value is empty string.

also,

Compulsory variables:

- `contact_email`: a string. No default value, MUST be supplied.
- `oauth_provider_secret`: a multiline string. No default value, MUST be
  supplied.

  Expect something like:

  ```
  OAUTH_PROVIDER=google
  OAUTH_CLIENT_ID=1220-blah-blah.apps.googleusercontent.com
  OAUTH_CLIENT_SECRET=8YDxxxxxxxxxxxxxxxxxxxxA
  ```

Notes: for `vouch_loglevel`:
at debug level, logs for nginx-auth-server might include
passwords in clear text, I think.

Dependencies
------------

Should have installed and configured vouch.

Example Playbook
----------------

Something like:

```
---
- hosts: all
  become: yes
  become_method: sudo
  tasks:
    - name: Run the dokku.apps.vouch.create role
      include_role:
        name: dokku.apps.vouch.create
      vars:
        letsencrypt_type: "staging"
        vouch_whitelist: "john.smith@gmail.com,sarah-jane.smith@gmail.com"
        contact_email: "me@mydomain.com"
        oauth_provider_secret: |
          OAUTH_PROVIDER=google
          OAUTH_CLIENT_ID=1220-blah-blah.apps.googleusercontent.com
          OAUTH_CLIENT_SECRET=8YDxxxxxxxxxxxxxxxxxxxxA
```

