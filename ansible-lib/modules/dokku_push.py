#!/usr/bin/python

# Copyright: (c) 2021, phlummox
# MIT license

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = r'''
---
module: dokku_push
short_description: clone a git repo and push to target
description:
    - Longer description of the module.
    - You might include instructions.
version_added: "2.10.6"
author: "phlummox"
options:
    app_name:
        description:
            - Name of the dokku app.
        required: true
        default: null
        #choices:
        #  - enable
        #  - disable
        type: str
    repo_url:
        description:
            - URL of the git repo to be cloned and pushed.
        required: true
        default: null
        type: str
    branch:
        description:
            - what branch to push
        required: false
        default: "master"
        type: str
    force:
        description:
            - Whether to add "--force" to the git args.
        required: false
        default: false
        type: bool
notes:
    - Other things consumers of your module should know.
requirements:
    - list of required things.
'''

EXAMPLES = '''
- name: Ensure foo is installed
  modulename:
    name: foo
    state: present
'''

RETURN = '''
foo:
    description: a completely bogus return value
    returned: success
    type: string
    sample: /path/to/file.txt
'''

from ansible.module_utils.basic import AnsibleModule
import subprocess as sp

def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        app_name=dict(type='str', required=True),
        repo_url=dict(type='str', required=True),
        force=dict(type='bool', required=False, default=False),
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()

