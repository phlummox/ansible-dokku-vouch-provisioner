
# usage

`make env` will create a virtual env, then
`make py_prereqs` will install all tools and dependencies
(ansible and molecule, mostly).

Actually, after running `make env`, you might need to `. activate`
first, `make` doesn't seem to source the activate script well.

## requirements.txt

pinned versions are used in requirements.txt.

To re-generate, activate the env, and run

```
$ pip-compile requirements.in
```




