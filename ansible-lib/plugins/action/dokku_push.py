# Copyright: (c) 2021, phlummox
# MIT license

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.plugins.action import ActionBase
import ansible.vars.hostvars as hostvars
from ansible.errors import AnsibleError
from ansible.playbook.play_context import PlayContext
from ansible import constants as C
#import ansible.plugins.connection.local as local
# includes C.LOCALHOST
from ansible.module_utils._text import to_bytes, to_native, to_text
from ansible.plugins.loader import connection_loader
import tempfile
import yaml
import os, os.path
import sys

REQUIRED_ARGS = [ "app_name", "repo_url" ]

DO_DEBUG = False
#DO_DEBUG = True

# useful example of plugin calling other modules:
#   ansible/lib/ansible/plugins/action/template.py
# extremely useful example of action plugin:
#   https://gist.github.com/ju2wheels/408e2d34c788e417832c756320d05fb5
# less good example of calling module, seems dated:
#   https://stackoverflow.com/questions/56619745/correct-way-to-invoke-the-copy-module-with-module-param-content

def current_users_key():
  home = os.environ["HOME"]
  rsa_pub = os.path.join(home, '.ssh/id_rsa.pub')
  with open(rsa_pub) as infile:
      return infile.read()


def mk_push_args(repo_dir, remote_host, dokku_app_name, branch="master", should_force=False):
  """construct args to an ansible.builtin.shell action.

  args:

  - repo_dir: dir we should chdir into before pushing
  - remote_host: the host we're adding as a git remote
      and pushing to
  - dokku_app_name: dokku app name to use
  - should_force: whether to force push

  returns:

  - a dict of args, that can be set on a task.

  e.g.

      new_task = self._task.copy()
      new_task.args = mk_push_args("/tmp/xxx", "myhost.mydomain.au",
        "my-dokku-app")

  """

  # script should: cd in to tmp dir, add remote, and push
  # to be more robust, we really need to see
  # if there are any other ssh args ansible is using.
  if should_force:
    force_arg = "--force"
  else:
    force_arg = ""

  # pipe output to a temp file so
  # if necessary we can get progress...
  script = f"""
    set -euo pipefail
    set -x
    tmplog=`mktemp dokku-git-push-tmp-XXXXXX`;
    git remote add dokku 'dokku@{remote_host}:{dokku_app_name}'
    export GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
    git push --progress -v {force_arg} dokku {branch} 2>&1 | tee $tmplog
  """

  return dict(
    _raw_params=script,
    _uses_shell=True,
    executable="/bin/bash",
    chdir=repo_dir
    )

class DebugTempDir():
  def __init__(self, suffix=None, prefix=None, dir=None):
    self.name = tempfile.mkdtemp(suffix, prefix, dir)

  def __enter__(self):
    return self.name

  def __exit__(self, exc, value, tb):
    pass

# Action module for cloning to localhost, then
# pushing to dokku.
# We _could_ just clone this on the host itself,
# and push to localhost, after setting appropriate
# keys - might be easier.

class ActionModule(ActionBase):
  def run(self, tmp=None, task_vars=None):
    if task_vars is None:
        task_vars = dict()
    result = super(ActionModule, self).run(tmp, task_vars)

    # update result with plausible default vals
    result.update(
            dict(
                changed=False,
                failed=False,
                msg='',
                skipped=False
            )
        )

    self._supports_check_mode = True

    remote_host = task_vars["ansible_ssh_host"]

    print("retrieving user's ssh key", file=sys.stderr)
    # get current user's ssh key..,
    try:
      ssh_key = current_users_key()
    except IOError as exc:
      result['failed'] = True
      result['msg'] = "Could not read user's ssh key, error was: %s" % to_native(exc)
      return result
    print("retrieved user's ssh key", file=sys.stderr)

    print("ensuring ssh key is authed by dokku @ remotehost",
          file=sys.stderr)
    # ... and ensure key is on dokku@target -
    # call the ansible.posix.authorized_key module
    auth_key_module_args=dict(
        user='dokku',
        state='present',
        key=ssh_key,
        manage_dir=False
    )

    auth_key_result = self._execute_module(
            module_name='ansible.posix.authorized_key',
            module_args=auth_key_module_args,
            task_vars=task_vars,
            tmp=tmp
    )
    if not DO_DEBUG:
      del auth_key_result["invocation"]
    result["auth_key_result"] = auth_key_result
    print("key auth checked",
          file=sys.stderr)

    if "changed" in auth_key_result and auth_key_result["changed"]:
      result["changed"] = True
    if "failed" in auth_key_result and auth_key_result["failed"]:
      result["failed"] = True
      return result

    try:
      args            = self._task.args
      dokku_app_name  = args["app_name"]
      repo_url        = args["repo_url"]
    except KeyError as exc:
      result["failed"] = True
      result["msg"] = ("Expected to receive required args (%s), " +
          "but got: %s. Exception was: %s.") % (", ".join(REQUIRED_ARGS),
                                                args,
                                                to_text((exc,)))
      return result

    if "force" in args:
      should_force    = args["force"]
    else:
      should_force    = False

    if "branch" in args:
      branch    = args["branch"]
    else:
      branch    = "master"

    print("\n\nbranch from module args:", branch, file=sys.stderr)


    # we clone into a temp dir
    pref = "ansible_dokku_push_plugin-" + dokku_app_name + "-"

    if DO_DEBUG:
      tmpclass = DebugTempDir
    else:
      tmpclass = tempfile.TemporaryDirectory

    ### TODO: REMOVE THIS
    # change to using normal tmpdir class
    tmpclass = DebugTempDir

    with tmpclass(prefix=pref) as tmpdirname:
      print("\n\ntmp dir:", tmpdirname, file=sys.stderr)

      result["tmp_dir"] = tmpdirname

      # most straightforward way to clone would be
      # to use subprocess or GitPython
      # (https://pypi.org/project/GitPython/)
      #  But we will try using ansible.builtin.git,
      # executing it as a module, from a builtin.shell task
      # which uses a 'local'-type connection.

      print("cloning to localhost", file=sys.stderr)

      new_task = self._task.copy()
      new_task.args = mk_push_args(tmpdirname, remote_host,
                                    dokku_app_name, branch, should_force)

      # no idea how to correctly "delegate_to localhost", but
      # this seems to work
      new_ctx = self._play_context.copy()
      new_ctx.become = False
      new_ctx.connection = "local"
      ctxstr = yaml.dump(self._play_context, Dumper=yaml.Dumper)
      print("new_ctx", ctxstr, file=sys.stderr)

      local_con = self._shared_loader_obj.connection_loader.get('local',
          new_ctx,
          sys.stdin)
      shell_action = self._shared_loader_obj.action_loader.get('ansible.builtin.shell',
        task=new_task,
        connection=local_con,
        play_context=new_ctx,
        loader=self._loader,
        templar=self._templar,
        shared_loader_obj=self._shared_loader_obj)

      # use the delegated ansible.builtin.shell task
      # to run `git` locally.
      git_module_args=dict(
          repo=repo_url,
          dest=tmpdirname,
          force=should_force,
          accept_hostkey=True
      )

      git_result = shell_action._execute_module(
            module_name='ansible.builtin.git',
            module_args=git_module_args,
            task_vars=task_vars,
            tmp=tmp
        )

      if not DO_DEBUG:
        del git_result["invocation"]

      result["git_result"] = git_result
      print("clone done, checking success", file=sys.stderr)

      if "failed" in git_result and git_result["failed"]:
        result["failed"] = True
        return result

      # do the push
      print("pushing to remote host, args =", new_task.args,
              file=sys.stderr)
      push_res = shell_action.run(task_vars=task_vars)
      print("push done, checking success", file=sys.stderr)

      if not DO_DEBUG and "invocation" in push_res:
        del push_res["invocation"]
      result["push_result"] = push_res

      if "failed" in push_res and push_res["failed"]:
        result["failed"] = True

      result.update(push_res)

      # TODO: by default, a shell command will say
      # it _always_ changed things.
      # We can examine the output of stderr to see if it really did:
      #   "Everything up-to-date" may suggest nothing changed.

    return result

# vim: syntax=python :
