load("@rules_proto//proto:defs.bzl", "proto_library")
load("@aspect_rules_py//py:defs.bzl", "py_library")
load("@rules_proto_grpc//:defs.bzl", "ProtoPluginInfo", "proto_compile_attrs", "proto_compile_impl")

python_proto_compile = rule(
    implementation = proto_compile_impl,
    attrs = dict(
        proto_compile_attrs,
        _plugins = attr.label_list(
            providers = [ProtoPluginInfo],
            default = [
                Label("@rules_proto_grpc//python:python_plugin"),
                Label("//mypy_rules:mypy_plugin"),
            ],
            doc = "List of protoc plugins to apply",
        ),
    ),
    toolchains = [str(Label("@rules_proto_grpc//protobuf:toolchain_type"))],
)

python_grpc_compile = rule(
    implementation = proto_compile_impl,
    attrs = dict(
        proto_compile_attrs,
        _plugins = attr.label_list(
            providers = [ProtoPluginInfo],
            default = [
                Label("@rules_proto_grpc//python:python_plugin"),
                Label("@rules_proto_grpc//python:grpc_python_plugin"),
                Label("//mypy_rules:mypy_plugin"),
                Label("//mypy_rules:grpc_mypy_plugin"),
            ],
            doc = "List of protoc plugins to apply",
        ),
    ),
    toolchains = [str(Label("@rules_proto_grpc//protobuf:toolchain_type"))],
)

def _py_proto_library_no_compile(name, compile_name, srcs, deps, visibility):
    proto_library(
        name = name + "_proto_library",
        srcs = srcs,
        deps = deps,
        visibility = ["//visibility:private"],
    )

    native.genrule(
        name = name + "_py_typed",
        srcs = [],
        outs = ["py.typed"],
        cmd = "touch $@",
        visibility = ["//visibility:private"],
    )

    py_library(
        name = name,
        srcs = [compile_name],
        data = [name + "_py_typed"],
        deps = ["@com_google_protobuf//:protobuf_python"],
        visibility = visibility,
    )

def py_proto_library(name, srcs, deps, visibility = None):
    _py_proto_library_no_compile(name, name + "_python_proto_compile", srcs, deps, visibility)

    python_proto_compile(
        name = name + "_python_proto_compile",
        protos = [name + "_proto_library"],
        output_mode = "NO_PREFIX_FLAT",
        visibility = ["//visibility:private"],
    )

def py_grpc_library(name, srcs, deps, visibility = None):
    _py_proto_library_no_compile(name, name + "_python_grpc_compile", srcs, deps, visibility)

    python_grpc_compile(
        name = name + "_python_grpc_compile",
        protos = [name + "_proto_library"],
        output_mode = "NO_PREFIX_FLAT",
        visibility = ["//visibility:private"],
    )
