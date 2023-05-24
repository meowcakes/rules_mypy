#!/usr/bin/env bash

source test/test_runner.sh
source test/test_helper.sh

runner=$(get_test_runner "${1:-local}")

test_foo_passes() {
    action_should_succeed test //test/python:foo_passes_mypy_test
}

test_foo_fails() {
    action_should_fail test //test/python:foo_fails_mypy_test
}

main() {
  $runner test_foo_passes
  $runner test_foo_fails
}

main "$@"
