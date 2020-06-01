% optimized consumer.erl
-module(consumer).
-export([start/0]).
-export([loop/1]).   % need this

start() ->
    spawn(fun() -> loop([]) end).

loop(Items) when is_list(Items) -> % backwards compatibility
    loop(length(Items));

loop(Total) -> % optimized code
    receive
        {From, switch} ->
            From ! switching,
            ?MODULE:loop(Total);
    	  		
        {From, total} ->
            From ! {total, Total, v2},
            loop(Total);
        _ ->
            loop(Total+1)
    end.
