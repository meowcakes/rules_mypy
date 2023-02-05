Some code taken from https://github.com/bazel-contrib/bazel-mypy-integration

```sh
$ bazel test //mypy_bazel/python:foo_passes_mypy_test
...
Executed 1 out of 1 test: 1 test passes.
```

```sh
$ bazel test //mypy_bazel/python:foo_fails_mypy_test
...
==================== Test output for //mypy_bazel/python:foo_fails_mypy_test:
mypy_bazel/python/foo_fails.py:5: error: Argument "x" to "Foo" has incompatible type "str"; expected "int"  [arg-type]
mypy_bazel/python/foo_fails.py:6: error: Module has no attribute "Duration"  [attr-defined]
Found 2 errors in 1 file (checked 1 source file)
================================================================================
...
Executed 1 out of 1 test: 1 fails locally.
```
