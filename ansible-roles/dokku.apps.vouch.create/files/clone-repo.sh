#!/usr/bin/env bash

if [[ $# -lt 1 || $# -gt 4 ]]; then
  echo "bad number args, expected 3-4 args: svc name, git url, remote hostname, [--force]"
  echo "or some other extra git arg instead of --force"
  exit 1
fi

set -eox pipefail;
# not -u, as GIT_ARG potentislly uses unset $4

if [ ! -d repos ] ; then
  mkdir repos
fi

export SVC_NAME=$1;
export GIT_REPO_URL=$2;
export REMOTE_HOST=$3;
export GIT_ARG=$4;

rm -rf repos/"${SVC_NAME}";
git clone "${GIT_REPO_URL}" repos/"${SVC_NAME}";
cd repos/"${SVC_NAME}";

set -x
git remote add dokku "dokku@${REMOTE_HOST}:${SVC_NAME}";
export GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
git push -v ${GIT_ARG} dokku master


