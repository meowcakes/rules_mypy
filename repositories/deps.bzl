"""Fetch dependencies."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def deps():
    """Fetch dependencies."""

    http_archive(
        name = "rules_proto",
        sha256 = "dc3fb206a2cb3441b485eb1e423165b231235a1ea9b031b4433cf7bc1fa460dd",
        strip_prefix = "rules_proto-5.3.0-21.7",
        urls = [
            "https://github.com/bazelbuild/rules_proto/archive/refs/tags/5.3.0-21.7.tar.gz",
        ],
    )

    http_archive(
        name = "com_github_grpc_grpc",
        urls = [
            "https://github.com/grpc/grpc/archive/0bf4a618b17a3f0ed61c22364913c7f66fc1c61a.tar.gz",
        ],
        strip_prefix = "grpc-0bf4a618b17a3f0ed61c22364913c7f66fc1c61a",
        sha256 = "1e5fac6475c737120f03f6994de1cedad97933a8db22cc016449a3f41d148cc7",
    )

    http_archive(
        name = "bazel_skylib",
        sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
        ],
    )

    http_archive(
        name = "rules_proto_grpc",
        sha256 = "fb7fc7a3c19a92b2f15ed7c4ffb2983e956625c1436f57a3430b897ba9864059",
        strip_prefix = "rules_proto_grpc-4.3.0",
        urls = ["https://github.com/rules-proto-grpc/rules_proto_grpc/archive/4.3.0.tar.gz"],
    )

    http_archive(
        name = "rules_python",
        sha256 = "8c15896f6686beb5c631a4459a3aa8392daccaab805ea899c9d14215074b60ef",
        strip_prefix = "rules_python-0.17.3",
        url = "https://github.com/bazelbuild/rules_python/archive/refs/tags/0.17.3.tar.gz",
    )

    http_archive(
        name = "aspect_rules_py",
        sha256 = "66da30b09cf47ee40f2ae1c46346cc9a412940965d04899bd68d06a9d3380085",
        strip_prefix = "rules_py-0.1.0",
        url = "https://github.com/aspect-build/rules_py/archive/refs/tags/v0.1.0.tar.gz",
    )
