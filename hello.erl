-module(hello).
-export([loop/0]).

loop() ->
    receive
        {hello, From} ->
            From ! {hello, self()},
            loop()
    end.
