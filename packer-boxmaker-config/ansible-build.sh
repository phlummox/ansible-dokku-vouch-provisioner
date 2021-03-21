#!/usr/bin/env bash

set -ex

source ../install-ansible/env/bin/activate

export ANSIBLE_ROLES_PATH=$PWD/../ansible-roles

ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook "$@"
