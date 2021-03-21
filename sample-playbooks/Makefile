
# run tests

# need to fill this in!!
MY_DOKKU_HOST=

try_playbook:
	set -ex; \
	roles_dir=`readlink -f ../ansible-roles/`; \
	ANSIBLE_ROLES_PATH=$$roles_dir ./run_playbook.sh $(MY_DOKKU_HOST) my-playbook.yml`


