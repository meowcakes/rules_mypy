"""Contains code that should pass a mypy test."""

from test.proto.v1 import foo_pb2

from google.protobuf import duration_pb2, timestamp_pb2

foo = foo_pb2.Foo(
    x=1,
    y=timestamp_pb2.Timestamp(seconds=5),
    z=duration_pb2.Duration(seconds=3),
)

bar = foo_pb2.Bar(foo=foo)
