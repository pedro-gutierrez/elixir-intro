-module(hello).
-export([loop/0]).

loop() ->
    receive
        {hi, From} ->
            From ! {hello, self()},
            loop()
    end.
