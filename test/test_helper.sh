#!/usr/bin/env bash

action_should_succeed() {
	# runs the tests locally
	set +e
	TEST_ARG=$@
	OUTPUT=$(bazel $TEST_ARG)
	RESPONSE_CODE=$?
	if [ $RESPONSE_CODE -eq 0 ]; then
		exit 0
	else
		# Bazel may report useful error information to stdout.
		if [[ -n $OUTPUT ]]; then
			echo -e "$OUTPUT"
		fi
		echo -e "${RED} \"bazel $TEST_ARG\" should have passed but failed. $NC"
		exit -1
	fi
}

action_should_fail() {
	# runs the tests locally
	set +e
	TEST_ARG=$@
	OUTPUT=$(bazel $TEST_ARG)
	RESPONSE_CODE=$?
	if [ $RESPONSE_CODE -eq 0 ]; then
		echo -e "${RED} \"bazel $TEST_ARG\" should have failed but passed. $NC"
		exit -1
	else
		exit 0
	fi
}
