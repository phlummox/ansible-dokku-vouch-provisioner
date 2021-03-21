config shared amongst roles -- at the moment, it's all testing
config.

For instance roles share the following:

- They all use Goss in exactly the same way (`goss-verify.yml`)
- They all use the same molecule.yml file (though it's configurable
  with env vars, to allow different Vagrant providers or base boxes
  or amounts of memory to be used)
- They all include `tests/test_01_default.yml`, a "basic" test
  that should always pass.
