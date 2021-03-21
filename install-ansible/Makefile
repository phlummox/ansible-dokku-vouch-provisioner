
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
	pip install --user --upgrade pip wheel; \
	pip install --user --upgrade pip-tools; \
	pip-compile requirements.in; \
	pip install --user -r requirements.txt

