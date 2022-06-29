
env:
	python3.8 -m pip install --user --upgrade virtualenv pip wheel
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
	python3.8 -m pip install $$pip_flags --upgrade pip wheel; \
	python3.8 -m pip install $$pip_flags --upgrade pip-tools; \
	pip-compile --version; \
	pip-compile requirements.in; \
	python3.8 -m pip install $$pip_flags -r requirements.txt

