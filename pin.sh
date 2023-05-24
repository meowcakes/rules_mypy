#!/usr/bin/env bash

bazel run //:requirements.update
bazel run //:requirements_testing.update
