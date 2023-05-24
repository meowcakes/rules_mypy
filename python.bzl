"""
Defines macros for adding a mypy test target to a py_binary, py_library or py_test.
"""

load("@aspect_rules_py//py:defs.bzl", _py_binary = "py_binary", _py_library = "py_library", _py_pytest_main = "py_pytest_main", _py_test = "py_test")
load("@bazel_skylib//lib:sets.bzl", "sets")
load("@bazel_skylib//lib:shell.bzl", "shell")
load("@mypy_pypi//:requirements.bzl", "requirement")

VALID_EXTENSIONS = ["py", "pyi"]

_PYTEST_DEPS = [
    requirement("pytest"),
    requirement("pytest-timeout"),
]

def _sources_to_cache_map_triples(srcs):
    triples_as_flat_list = []
    for f in srcs:
        f_path = f.short_path
        triples_as_flat_list.extend([
            shell.quote(f_path),
            shell.quote("{}.meta.json".format(f_path)),
            shell.quote("{}.data.json".format(f_path)),
        ])
    return triples_as_flat_list

def _extract_srcs(srcs):
    direct_src_files = []
    for src in srcs:
        for f in src.files.to_list():
            if f.extension in VALID_EXTENSIONS:
                direct_src_files.append(f)
    return direct_src_files

def _mypy_test_impl(ctx):
    mypy_config_file = ctx.file.mypy_config
    src_files = []

    if hasattr(ctx.attr, "srcs"):
        src_files = _extract_srcs(ctx.attr.srcs)

    final_srcs_depset = depset(transitive = [depset(direct = src_files)])
    src_files = final_srcs_depset.to_list()
    if not src_files:
        return None

    runfiles = ctx.runfiles(files = src_files + [mypy_config_file])
    runfiles = runfiles.merge(ctx.attr.mypy_cli.default_runfiles)

    src_root_paths = sets.to_list(
        sets.make([f.root.path for f in src_files]),
    )

    exe = ctx.actions.declare_file(
        "%s_mypy_exe" % ctx.attr.name,
    )

    ctx.actions.expand_template(
        template = ctx.file._template,
        output = exe,
        substitutions = {
            "{CACHE_MAP_TRIPLES}": " ".join(_sources_to_cache_map_triples(src_files)),
            "{MYPY_EXE}": ctx.executable.mypy_cli.path,
            "{MYPY_INI_PATH}": mypy_config_file.path,
            "{MYPY_ROOT}": ctx.executable.mypy_cli.root.path,
            "{PACKAGE_ROOTS}": " ".join([
                "--package-root " + shell.quote(path or ".")
                for path in src_root_paths
            ]),
            "{SRCS}": " ".join([shell.quote(f.short_path) for f in src_files]),
            "{VERBOSE_BASH}": "set -x" if ctx.attr.verbose else "",
            "{VERBOSE_OPT}": "--verbose" if ctx.attr.verbose else "",
        },
        is_executable = True,
    )

    return DefaultInfo(executable = exe, runfiles = runfiles)

_mypy_test = rule(
    implementation = _mypy_test_impl,
    test = True,
    attrs = {
        "mypy_cli": attr.label(
            executable = True,
            cfg = "exec",
        ),
        "mypy_config": attr.label(
            default = Label("//:mypy_ini"),
            allow_single_file = True,
        ),
        "srcs": attr.label_list(allow_files = True),
        "verbose": attr.bool(default = False),
        "_template": attr.label(
            default = Label("//:mypy.bash.tpl"),
            allow_single_file = True,
        ),
    },
)

def _mypy_test_macro(name, **kwargs):
    # TODO(meowcakes): remove this py_binary and move the deps into the _mypy_test
    # TODO(meowcakes): put mypy into a toolchain
    _py_binary(
        name = name + "_mypy_bin",
        srcs = ["//:mypy.py"],
        main = "//:mypy.py",
        deps = kwargs.get("deps", []) + [requirement("mypy")],
        visibility = ["//visibility:private"],
    )

    _mypy_test(
        name = name + "_mypy_test",
        srcs = kwargs.get("srcs", []),
        mypy_cli = name + "_mypy_bin",
        verbose = kwargs.get("verbose", False),
        visibility = ["//visibility:private"],
    )

def py_library(name, **kwargs):
    """Creates a py_library target and an additional mypy test target with suffix `_mypy_test`."""
    _py_library(
        name = name,
        **kwargs
    )

    _mypy_test_macro(name, **kwargs)

def py_binary(name, **kwargs):
    """Creates a py_binary target and an additional mypy test target with suffix `_mypy_test`."""
    _py_binary(
        name = name,
        **kwargs
    )

    _mypy_test_macro(name, **kwargs)

def py_test(name, **kwargs):
    """Creates a py_test target and an additional mypy test target with suffix `_mypy_test`."""
    _py_test(
        name = name,
        **kwargs
    )

    _mypy_test_macro(name, **kwargs)

def py_pytest(name, **kwargs):
    """Runs a pytest test with mypy type checking.

    Creates a py_test target with a pytest entrypoint and an additional mypy
    test target with suffix `_mypy_test`.

    Adds pytest dependencies.

    Args:
      name: A unique name for this target.
      **kwargs: Arbitrary keyword arguments.
    """
    target = name + "_pytest_main"
    deps = kwargs.pop("deps", []) + _PYTEST_DEPS

    # This needs to see the original kwargs before we modify it below
    _mypy_test_macro(
        name = name,
        deps = deps,
        **kwargs
    )

    _py_pytest_main(name = target, chdir = kwargs.pop("chdir", None))

    _py_test(
        name = name,
        srcs = kwargs.pop("srcs", []) + [":" + target],
        deps = deps + [":" + target],
        main = ":" + target + ".py",
        **kwargs
    )
