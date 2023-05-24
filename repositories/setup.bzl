"""Setup dependencies."""

load("@aspect_rules_py//py:repositories.bzl", "rules_py_dependencies")
load("@com_github_grpc_grpc//bazel:grpc_deps.bzl", "grpc_deps")
load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")
load("@rules_proto_grpc//:repositories.bzl", "rules_proto_grpc_repos", "rules_proto_grpc_toolchains")
load("@rules_proto_grpc//python:repositories.bzl", rules_proto_grpc_python_repos = "python_repos")
load("@rules_python//python:pip.bzl", "pip_parse")

def setup(python_interpreter_target = None, requirements_file = "@rules_mypy//:requirements_lock.txt"):
    """Setup dependencies.

    Args:
        python_interpreter_target: The python interpreter target to use for installing pypi deps.
        requirements_file: The requirements file containing mypy, mypy-protobuf and types-protobuf pip packages to use.
    """

    rules_proto_grpc_toolchains()

    rules_proto_grpc_repos()

    rules_proto_dependencies()

    rules_proto_toolchains()

    rules_proto_grpc_python_repos()

    grpc_deps()

    rules_py_dependencies()

    pip_parse(
        name = "mypy_pypi",
        python_interpreter_target = python_interpreter_target,
        requirements = requirements_file,
    )
