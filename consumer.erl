% consumer.erl
-module(consumer).
-export([start/0]).

start() ->
    spawn(fun() -> loop([]) end).

loop(Items) ->
    receive
        switch ->
            % will explain later
            ?MODULE:loop(Items);

        {From, total} ->
            From ! {total, length(Items)},
            loop(Items);
        Other ->
            loop([Other|Items])
    end.
