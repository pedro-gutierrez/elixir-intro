-module(kv2).
-export([start/0, start/1, start/2, loop/1]).

start() ->
    start(#{}).

start(State) ->
    start(node(), State).

start(Node, State) ->
    spawn(Node, kv2, loop, [State]).

loop(State) ->
    receive 
        {From, put, Key, Value} ->
            State2 = maps:put(Key, Value, State),
            From ! ok,
            loop(State2);

        {From, get, Key} ->
            case maps:is_key(Key, State) of 
                false ->
                    From ! not_found;

                true ->
                    From ! {ok, maps:get(Key, State)}
            end,

            loop(State);
        _ ->
            error
    end.
