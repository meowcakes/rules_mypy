"Public API"

load("@bazel_skylib//lib:shell.bzl", "shell")
load("@bazel_skylib//lib:sets.bzl", "sets")
load("@aspect_rules_py//py:defs.bzl", _py_binary = "py_binary", _py_library = "py_library")
load("@pypi//:requirements.bzl", "requirement")

# Switch to True only during debugging and development.
# All releases should have this as False.
DEBUG = False

VALID_EXTENSIONS = ["py", "pyi"]

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
            "{MYPY_EXE}": ctx.executable.mypy_cli.path,
            "{MYPY_ROOT}": ctx.executable.mypy_cli.root.path,
            "{CACHE_MAP_TRIPLES}": " ".join(_sources_to_cache_map_triples(src_files)),
            "{PACKAGE_ROOTS}": " ".join([
                "--package-root " + shell.quote(path or ".")
                for path in src_root_paths
            ]),
            "{SRCS}": " ".join([shell.quote(f.short_path) for f in src_files]),
            "{VERBOSE_OPT}": "--verbose" if DEBUG else "",
            "{VERBOSE_BASH}": "set -x" if DEBUG else "",
            "{MYPY_INI_PATH}": mypy_config_file.path,
        },
        is_executable = True,
    )

    return DefaultInfo(executable = exe, runfiles = runfiles)

_mypy_test = rule(
    implementation = _mypy_test_impl,
    test = True,
    attrs = {
        "_template": attr.label(
            default = Label("//mypy_rules:mypy.bash.tpl"),
            allow_single_file = True,
        ),
        "mypy_config": attr.label(
            default = Label("//:mypy.ini"),
            allow_single_file = True,
        ),
        "mypy_cli": attr.label(
            executable = True,
            cfg = "exec",
        ),
        "deps": attr.label_list(),
        "srcs": attr.label_list(allow_files = True),
    },
)

def py_library(name, **kwargs):
    _py_library(
        name = name,
        **kwargs,
    )

    mypy_bin_name = name + "_mypy_bin"
    _py_binary(
        name = mypy_bin_name,
        srcs = ["//mypy_rules:mypy.py"],
        main = "//mypy_rules:mypy.py",
        deps = kwargs.get("deps", []) + [requirement("mypy")],
        visibility = ["//visibility:private"],
    )

    _mypy_test(
        name = name + "_mypy_test",
        srcs = kwargs.get("srcs"),
        mypy_cli = mypy_bin_name,
        visibility = ["//visibility:private"],
    )
