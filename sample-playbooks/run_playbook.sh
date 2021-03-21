#!/usr/bin/env bash

if [ "$#" -ne 2 ]; then
  echo "expected 2 args, a host and a playbook"
  exit 1
fi

function cleanup {
  echo "cleaning up"
  rm -rf tmp-debug.log
  kill %1
  pkill -f 'tail -f tmp-debug.log'
}

set -euo pipefail
set -x
trap cleanup EXIT
trap cleanup ERR

TARGET_HOST=$1
PLAYBOOK=$2

# allow use of job control:
set -m

#VERBOSENESS="-v"
VERBOSENESS=""

rm -f tmp-debug.log
touch tmp-debug.log && tail -f tmp-debug.log &

## make an inventory
##inventory_file=`mktemp --suffix .yml tmp_dokku_proxy_inventory_XXXXXX`

ansible-playbook ${VERBOSENESS} -i "${TARGET_HOST}," ${PLAYBOOK}

