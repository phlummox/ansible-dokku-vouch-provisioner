#!/usr/bin/env bash

set -euo pipefail
set -x

# ensure some local module exists
export ANSIBLE_LIBRARY=$PWD/ansible-lib/modules
export ANSIBLE_ACTION_PLUGINS=$PWD/ansible-action-plugins

# should display doc:
ansible-doc -t module dokku_push | cat

#pytest -r a --cov=. --cov-report=html --fulltrace --color yes test/units/modules/.../test/my_test.py

# if you clone ansible, and source the hacking/env-thing,
# you can run
#
# ansible/hacking/test-module -m ansible-modules/dokku_push.py arg1 arg2
#
# to quickly run module without a playbook

git clone https://github.com/ansible/ansible.git

(cd ansible; git checkout v2.10.6)

sed -i '1,1 s/python\>/python3/' ansible/hacking/test-module

head ansible/hacking/test-module

source ansible/hacking/env-setup

# pass some bogus arguments for checking
ansible/hacking/test-module -m ansible-lib/modules/dokku_push.py -a "app_name=my_app_name  repo_url=http://www.google.com" --check

