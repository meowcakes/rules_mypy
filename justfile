pip-pin:
    bazel run //:requirements.update

pip-clean:
    rm -f requirements_lock.txt
    touch requirements_lock.txt

test:
    ./test.sh
