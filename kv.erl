-module(kv).
-export([start/0, start/1, loop/1]).

start() ->
    start(#{}).

start(State) ->
    spawn(fun() -> loop(State) end).

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
                	Value = maps:get(Key, State),
                    From ! {ok, Value}
            end,
            loop(State);
        Other ->
        	io:format("unrecognized message: ~p. Exiting..~n", [Other])
    end.
