% producer.erl
-module(producer).
-export([start/0, loop/0]).

start() ->
    spawn(fun ?MODULE:loop/0).

loop() ->
    consumer ! work,
    timer:sleep(100),
    loop().
