workspace(name = "rules_mypy")

load("//repositories:deps.bzl", "deps")

deps()

load("@rules_python//python:repositories.bzl", "python_register_toolchains")

python_register_toolchains(
    name = "python3_10",
    python_version = "3.10",
)

load("@python3_10//:defs.bzl", "interpreter")
load("//repositories:setup.bzl", "setup")

setup(python_interpreter_target = interpreter)

load("//repositories:install.bzl", "install")

install()
