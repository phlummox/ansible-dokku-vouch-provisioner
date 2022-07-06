
# default version of python3 to use
# override using `make PYTHON3=<some-other-version>`
# to use another.
PYTHON3=python3.8

env:
	$(PYTHON3) -m pip install --user --upgrade virtualenv pip wheel
	$(PYTHON3) -m venv env

ACTIVATE=\
	activate=env/bin/activate; \
	if [ -f "$$activate" ] ; then \
		. $$activate; \
	fi

# to regenerate requirements.txt:
# activate the env, and run
#	  `pip-compile requirements.in`

py_prereqs:
	set -ex; \
	$(ACTIVATE) ; \
	if [ -f "$$activate" ] ; then \
		pip_flags=""; \
	else \
		pip_flags="--user"; \
	fi; \
	$(PYTHON3) -m pip install $$pip_flags --upgrade pip wheel; \
	$(PYTHON3) -m pip install $$pip_flags --upgrade pip-tools; \
	pip-compile --version; \
	$(PYTHON3) -m pip install $$pip_flags -r requirements.txt

