#!/usr/bin/env bash

set -x

####
#
# ansible-build script
#
# This is just a wrapper around ansible-playbook, that sets a few env vars
# (e.g. ANSIBLE_ROLES_PATH, COLOR variables) before
# passing arguments on to ansible-playbook.
#
# Oh, and checks to see if appropriate Python packages (ansible, molecule)
# have been installed, and installs them if not.
#
###

# whether to use a virtualenv.
#
# Should be set to "true" if we should.
#
# If we detect we're in a CI, we _don't_ use virtualenv --
# instead, pip packages will get installed to ~/.local so
# we can cache them.
# (both GitHub and GitLab set the var "CI" to true")
#
# But on e.g. a local PC, we probably want to use
# a virtualenv rather than installing things to the
# user's ~/.local.
SHOULD_USE_VIRTUALENV="$(if [ -z "$CI" ] ; then echo true; else echo false; fi)"

set -euo pipefail

export PATH=~/.local/bin:$PATH

# install molecule if needed
if which molecule; then
  echo molecule found on PATH;
elif [ "$SHOULD_USE_VIRTUALENV" = "true" ] ; then
  set -x
  (cd ../install-ansible; make env);
  set +x
  echo "sourcing activate ..."
  source ../install-ansible/activate;
else
  echo "installing python prereqs ..."
  set -x
  (cd ../install-ansible; make py_prereqs);
  set +x
fi;

export ANSIBLE_ROLES_PATH=$PWD/../ansible-roles

PY_COLORS=1 ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 \
  ansible-playbook "$@"

