
env:
	pip install --user --upgrade virtualenv pip wheel
	virtualenv env

ACTIVATE=\
	activate=env/bin/activate; \
	if [ -f "$$activate" ] ; then \
		. $$activate; \
	fi

py_prereqs:
	set -ex; \
	$(ACTIVATE) ; \
	if [ -f "$$activate" ] ; then \
		pip_flags=""; \
	else \
		pip_flags="--user"; \
	fi; \
	pip install $$pip_flags --upgrade pip wheel; \
	pip install $$pip_flags --upgrade pip-tools; \
	pip-compile requirements.in; \
	pip install $$pip_flags -r requirements.txt

