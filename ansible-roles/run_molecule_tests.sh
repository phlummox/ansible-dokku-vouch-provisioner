#!/usr/bin/env bash

# install prerequisites for running a bunch of molecule tests,
# and then run and time them.

# args: expects one arg, a vagrant provider
# (probably either libvirt or virtualbox).

# expected env vars:
#   SHOULD_USE_VIRTUALENV - whether to install
#     pip packages into a virtualenv. Should equal string
#     "true" if so.
#   ANSIBLE_LIBRARY - path to ansible modules
#   ANSIBLE_ACTION_PLUGINS - path to ansible action plugins
#   PROVIDER_MEMORY - amount of memory for vagrant image
#   PLATFORM_BOX - name of the vagrant box to use for testing
#   VAGRANT_DOKKU_BOX - name of the vagrant box which include
#     pre-installed dokku
#   ROLES_TO_TEST - which roles to test
#   VERBOSITY - some verbosity args (or undefined/empty string)
#     which can be passed to molecule.
#   PYTHON3 - name of a python3 command to run (e.g. "python3.8")
#     (passed to `make py_prereqs`)

if [ "$#" -ne 1 ]; then
  printf 'Expected 1 arg, a vagrant provider.\n' >&2
  exit 1;
fi

MAGENTA='[35m'
RESET='[0m'

printf '%s== RUN_MOLECULE_TESTS==%s\n' "$MAGENTA" "$RESET"

echo PATH is: $PATH

run_role() {
  if [ "$#" -ne 2 ]; then
    printf 'Expected 2 args, a vagrant provider, and a role.\n' >&2
    exit 1;
  fi
  local provider=$1
  local role=$2
  set -x;

  if [ "$role" = "dokku.apps.clone-and-push" ]; then
    VERBOSITY="--debug -vvv"
  fi

  (cd "$role" && PROVIDER_NAME="$provider" PROVIDER_TYPE="$provider" molecule $VERBOSITY test --scenario-name default-scenario 2>&1 | sed "s/^/$role:/"; )
  set +x
}

run_all_roles() {
  if [ "$#" -ne 1 ]; then
    printf 'Expected 1 arg, a vagrant provider.\n' >&2
    exit 1;
  fi
  local provider=$1
  echo "running roles with provider '$provider' ..."
  for role in $ROLES_TO_TEST; do
    run_role "$provider" "$role";
  done
}


set -euo pipefail

# install molecule if needed
if which molecule; then
  echo molecule found on PATH;
else
  if [ "$SHOULD_USE_VIRTUALENV" = "true" ] ; then
    set -x
    (cd ../install-ansible; make env);
    set +x
    echo "sourcing activate ..."
    source ../install-ansible/activate;
  fi
  echo "installing python prereqs ..."
  set -x
  (cd ../install-ansible; make PYTHON3=$PYTHON3 py_prereqs);
  set +x
fi;

# add color - for some reason these env
# vars don't seem to be picked up from
# CI
export PY_COLORS=1
export ANSIBLE_FORCE_COLOR=1

set -vx
declare -p

#molecule --version;

if [ "$PLATFORM_BOX" = "$VAGRANT_DOKKU_BOX" ] ; then
  make install_vagrant_dokku_box;
fi

provider=$1
run_all_roles "$provider"

