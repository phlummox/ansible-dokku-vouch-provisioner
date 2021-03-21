#!/usr/bin/env bash

set -eou pipefail

roles="$(cd ansible-roles/; for role in `make print_roles`; do echo ansible-roles/$role; done)"

skippables="--exclude ansible-roles/dokku.apps.list -x yaml,role-name"
ansible-lint $skippables  --force-color -p sample-playbooks/*yml $roles

