
.PHONY: print_roles \
	run_tests_vbx			\
	run_tests_libvirt	\
	install_vagrant_dokku_box


# default version of python3 to use
# override using `make PYTHON3=<some-other-version>`
# to use another.
PYTHON3=python3.8

# run tests

SHELL=bash

ROLES_TO_TEST=$(shell find * -mindepth 0 -maxdepth 0 -type d | grep -v shared)
ROLES_TO_TEST=demo dokku.install dokku.configure dokku.apps.clone-and-push

# whether to use a virtualenv.
#
# Should be set to "true" if we should.
#
# If we detect we're in a CI, we _don't_ use virtualenv --
# instead, pip packages will get installed to ~/.local so
# we can cache them.
# (both GitHub and GitLab set the var "CI" to true")
SHOULD_USE_VIRTUALENV=$(shell if [ -z "$$CI" ] ; then echo true; else echo false; fi)

ANSIBLE_LIBRARY=$$PWD/../ansible-lib/modules
ANSIBLE_ACTION_PLUGINS=$$PWD/../ansible-lib/plugins/action

#VERBOSITY=--debug -vvv
#VERBOSITY=

TIMER=if which time; then export timer="`which time` -v"; else export timer=""; fi

# passed to molecule, specifies the no. of MB of memory
# the VM gets.
PROVIDER_MEMORY=768

# To speed up tests (e.g. if testing locally)
# you might want to create a vagrant box with dokku
# already installed -- that's one of the most time-consuming
# roles to execute.
# If so, can put a URL to fetch it from below.

VAGRANT_DOKKU_BOX=ubuntu_dokku_0.1
VAGRANT_DOKKU_BOX_FNAME=$(VAGRANT_DOKKU_BOX).box
#VAGRANT_DOKKU_BOX_URL=https://somehost.com/path/to/$(VAGRANT_DOKKU_BOX_FNAME)
VAGRANT_DOKKU_BOX_CHECKSUM_URL=$(VAGRANT_DOKKU_BOX_URL).md5

# What Virtualbox box to run tests on.
# generic/ubuntu2004 is avialable from the Vagrant Cloud,
# and comes in both libvirt and virtualbox flavours;
# or use some custom box.)
PLATFORM_BOX=generic/ubuntu2004

print_roles:
	@echo $(ROLES_TO_TEST)

install_vagrant_dokku_box:
	set -euo pipefail ; \
	if ! vagrant box list | grep $(VAGRANT_DOKKU_BOX) ; then \
		set -x; \
		checksum=`curl -L $(VAGRANT_DOKKU_BOX_CHECKSUM_URL) | awk '{ print $$1; }'` ; \
		echo $$checksum; \
		tmpdir=`mktemp -d vagrant-ubuntu-dokku-dld-XXXXXX`; \
		(cd $$tmpdir; \
			wget $(VAGRANT_DOKKU_BOX_URL) ; \
			actual_checksum=`cat $(VAGRANT_DOKKU_BOX_FNAME) | pv --size 2917M | md5sum | awk '{ print $$1; }'`; \
			[ "$$checksum" = "$$actual_checksum" ] ; \
			vagrant box add --name $(VAGRANT_DOKKU_BOX) --debug --provider libvirt --checksum $$checksum --checksum-type md5 --no-tty $$PWD/$(VAGRANT_DOKKU_BOX_FNAME) ; \
		); \
	else \
		echo "box already installed"; \
	fi

# run tests using virtualbox provider
run_tests_vbx:
	set -euo pipefail; \
	set -x; \
	export SHOULD_USE_VIRTUALENV="$(SHOULD_USE_VIRTUALENV)"; \
	export ANSIBLE_LIBRARY="$(ANSIBLE_LIBRARY)"; \
	export ANSIBLE_ACTION_PLUGINS="$(ANSIBLE_ACTION_PLUGINS)"; \
	export PROVIDER_MEMORY="$(PROVIDER_MEMORY)"; \
	export PLATFORM_BOX="$(PLATFORM_BOX)"; \
	export VAGRANT_DOKKU_BOX="$(VAGRANT_DOKKU_BOX)"; \
	export ROLES_TO_TEST="$(ROLES_TO_TEST)"; \
	export VERBOSITY="$(VERBOSITY)"; \
	export PYTHON3="$(PYTHON3)"; \
	$(TIMER); \
	$$timer ./run_molecule_tests.sh virtualbox

# run tests using libvirt provider
run_tests_libvirt:
	set -euo pipefail; \
	set -x; \
	export SHOULD_USE_VIRTUALENV="$(SHOULD_USE_VIRTUALENV)"; \
	export ANSIBLE_LIBRARY="$(ANSIBLE_LIBRARY)"; \
	export ANSIBLE_ACTION_PLUGINS="$(ANSIBLE_ACTION_PLUGINS)"; \
	export PROVIDER_MEMORY="$(PROVIDER_MEMORY)"; \
	export PLATFORM_BOX="$(PLATFORM_BOX)"; \
	export VAGRANT_DOKKU_BOX="$(VAGRANT_DOKKU_BOX)"; \
	export ROLES_TO_TEST="$(ROLES_TO_TEST)"; \
	export VERBOSITY="$(VERBOSITY)"; \
	export PYTHON3="$(PYTHON3)"; \
	$(TIMER); \
	$$timer ./run_molecule_tests.sh libvirt

