-module(fibtail).
-export([fib/1]).


fib(N) ->
    fib(N, 0, 1).

fib(0, Acc, _) ->
    Acc;

fib(Current, Acc1, Acc2) ->
    fib(Current-1, Acc1+Acc2, Acc1).
