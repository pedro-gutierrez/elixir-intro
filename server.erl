% server.erl
-module(server).
-export([start/0, ping/0]).

ping() ->
    server ! {self(), ping},
    receive
        pong ->
            ok
    after 2000 ->
            {error, timeout}
    end.

start() ->
    Pid = spawn(fun() -> loop() end),
    true = register(server, Pid),
    ok.

loop() ->
    receive
        {From, ping} ->
            timer:sleep(rand:uniform(10)*1000),
            From ! pong,
            loop()
    end.
