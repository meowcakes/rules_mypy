from google.protobuf import timestamp_pb2, duration_pb2
from mypy_bazel.proto import foo_pb2

foo = foo_pb2.Foo(
    x=1,
    y=timestamp_pb2.Timestamp(seconds=5),
    z=duration_pb2.Duration(seconds=3),
)

bar = foo_pb2.Bar(
    foo=foo
)
