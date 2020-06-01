% debugger.erl
-module(debugger).
-export([top/1]).

top(Info) ->
    Procs = erlang:processes(),
    InfoPerProc = [{P,element(2, erlang:process_info(P, Info))} || P <-
                                                                   Procs],
    [First|_] = lists:reverse(lists:keysort(2, InfoPerProc)),
    First.

