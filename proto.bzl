"""
Defines macros for compiling python proto/grpc libraries with type information.
"""

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
                Label("//:mypy_plugin"),
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
                Label("//:mypy_plugin"),
                Label("//:grpc_mypy_plugin"),
            ],
            doc = "List of protoc plugins to apply",
        ),
    ),
    toolchains = [str(Label("@rules_proto_grpc//protobuf:toolchain_type"))],
)

def py_proto_library(name, protos, visibility = None):
    python_proto_compile(
        name = name + "_python_proto_compile",
        protos = protos,
        output_mode = "NO_PREFIX_FLAT",
        visibility = ["//visibility:private"],
    )

    py_library(
        name = name,
        srcs = [name + "_python_proto_compile"],
        deps = ["@com_google_protobuf//:protobuf_python"],
        visibility = visibility,
    )

def py_grpc_library(name, protos, visibility = None):
    python_grpc_compile(
        name = name + "_python_grpc_compile",
        protos = protos,
        output_mode = "NO_PREFIX_FLAT",
        visibility = ["//visibility:private"],
    )

    py_library(
        name = name,
        srcs = [name + "_python_grpc_compile"],
        deps = ["@com_google_protobuf//:protobuf_python"],
        visibility = visibility,
    )
