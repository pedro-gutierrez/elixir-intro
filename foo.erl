-module(foo).
-export([foo/0, foo/1]).

foo() -> foo(0).
foo(N) when is_number(N) -> {foo, N};
foo(Fun) -> {foo, Fun()}.
