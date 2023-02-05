#!/usr/bin/env bash

{VERBOSE_BASH}
set -o errexit
set -o nounset
set -o pipefail

main() {
  local output
  local status
  local mypy

  root="{MYPY_ROOT}/"
  mypy="{MYPY_EXE}"

  if [ ! -f $mypy ]; then
    mypy=${mypy#${root}}
  fi

  set +o errexit
  output=$($mypy {VERBOSE_OPT} --bazel {PACKAGE_ROOTS} --config-file {MYPY_INI_PATH} --cache-map {CACHE_MAP_TRIPLES} --explicit-package-bases -- {SRCS} 2>&1)
  status=$?
  set -o errexit

  if [[ $status -ne 0 ]]; then
    echo "${output}"
    exit 1
  fi

}

main "$@"
