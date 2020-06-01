-module(reducer).
-export([sum/1]).

sum([]) -> 0;
sum([First|Rest]) ->
	First + sum(Rest).
