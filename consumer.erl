% consumer.erl
-module(consumer).
-export([start/0]).

start() ->
    spawn(fun() -> loop([]) end).

loop(Items) ->
    receive
        {From, total} = Cmd ->
            io:format("~p received ~p~n", [self(), Cmd]),
            From ! {total, length(Items)},
            loop(Items);
        Other ->
        		loop([Other|Items])
    end.
