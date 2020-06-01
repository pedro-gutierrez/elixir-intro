-module(launcher).
-export([launch/1]).

launch(0) -> ok;

launch(Count) ->
    producer:start(),
    launch(Count-1).

