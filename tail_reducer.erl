-module(tail_reducer).
-export([sum/1]).

sum([]) -> 0;
sum(List) ->
	sum(List, 0).
	
sum([], Acc) -> Acc;
sum([First|Rest], Acc) ->
	sum(Rest, Acc+First).
