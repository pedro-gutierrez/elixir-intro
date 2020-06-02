# Erlang & Elixir intro

## Erlang

**Erlang** is a programming language used to build massively **scalable**, **soft real-time** systems with requirements on **high availability**.

### Use cases

* Telecoms
* banking and fintech
* E-commerce
* Computer telephony and instant messaging
* Gaming
* Healthcare
* Automotive, IoT, Embedded systems
* Blockchain

### Some companies using Erlang or Elixir

* WhatsApp
* Goldman Sachs
* Nintendo
* BT Mobile
* Samsung
* Bet365
* Vocalink
* Erlang Solutions
* Pinterest
* Lonely Planet
* Pager Duty
* Discord



### History

* Originally developed in 1986 by Ericsson, by Joe Armstrong, Mike Williams and Robert Virding as the main inventors
* Named after Danish mathematician and engineer Agner Krarup Erlang
* Originally implemented in Prolog
* Suitable for prototyping telephone exchanges, but too slow
* BEAM (Erlang VM) started in 1992, which compiles Erlang to C
* In 1998, Ericsson announced the AXD301 switch, with 1M Erlang loc and
  nine 9s availabiliy
* Opensourced in 1998
* Banned in favor of non propietary languages
* Re-adopted in 2004.
* In 2014, used by Ericsson in GPRS, 3G and LTE mobile networks. Also
  used by Nortel and T-Mobile.

### Products

* Ejabberd
* Apache CouchDB / IBM Cloudant
* Riak KV
* Whatsapp
* RabbitMQ

### Features

Erlang is a **strongly**, **dynamically** typed language. Source code (.erl) compiles to bytecode (.beam) and is loaded and run into the **Erlang Virtual Machine** (BEAM). 

Erlang's runtime system has built-in support for:

* concurrency,
* distribution
* fault tolerance.
* debugging and observability

It is designed for highly parallel, scalable applications requiring high uptime. Relies on a preemptive scheduler.

#### Immutable data

- No variable assignment, but variable binding.
- Once bound, a variable cannot be redefined.

```
Eshell V10.6.4  (abort with ^G)
1> Foo = bar.
bar
2> Foo = baz.
** exception error: no match of right hand side value baz
```

```
Eshell V10.6.4  (abort with ^G)
1> Map1 = #{ foo => bar }.
#{foo => bar}
2> Map2 = maps:put(foo, baz, Map1).
#{foo => baz}
3> Map1.
#{foo => bar}
4> Map2.
#{foo => baz}
```



#### Functional programming

- Functions are grouped into modules
- Modules have no state. There is no global memory.
- Functions operate on arguments.
- Functions are identified by their name and arity.
- Functions can be passed as arguments to other functions

```
-module(hello).
-export([hello/1]).

hello(From) ->
    {hello, From}.
```



#### Pattern matching

```
Eshell V10.6.4  (abort with ^G)
1> MyList = [1, 2, 3].
[1,2,3]
2> [Head|Tail] = MyList.
[1,2,3]
3> Head.
1
4> Tail.
[2,3]

5> Cmd = {self(), put, a, 1}.
{<0.78.0>,put,a,1}
6> {From, put, Key, Value} = Cmd.
{<0.78.0>,put,a,1}
7> From.
<0.78.0>
8> Key.
a
9> Value.
1
```

```
-define(IP_VERSION, 4).
-define(IP_MIN_HDR_LEN, 5).

DgramSize = byte_size(Dgram),
case Dgram of 
    <<?IP_VERSION:4, HLen:4, SrvcType:8, TotLen:16, 
      ID:16, Flgs:3, FragOff:13,
      TTL:8, Proto:8, HdrChkSum:16,
      SrcIP:32,
      DestIP:32, RestDgram/binary>>  when HLen>=5, 4*HLen=<DgramSize  ->
        
        OptsLen = 4*(HLen - ?IP_MIN_HDR_LEN),
        <<Opts:OptsLen/binary,Data/binary>> = RestDgram,
    ...
end.
```



#### List comprehensions

```
10> MyList = [{pet, cats, 1}, {pet, dogs, 1}, {kids, 3}].
[{pet,cats,1},{pet,dogs,1},{kids,3}]

11> [{Kind, Count} || {pet, Kind, Count} <- MyList ].
[{cats,1},{dogs,1}]

12> [Count || {kids, Count} <- MyList ].
[3]
```

#### Recursion

* For loops don't exist in Erlang

```
-module(reducer).
-export([sum/1]).

sum([]) -> 0;
sum([First|Rest]) ->
	First + sum(Rest).
```

```Eshell V10.6.4  (abort with ^G)
Eshell V10.6.4  (abort with ^G)
1> c(reducer).
{ok,reducer}
2> reducer:sum([1, 5, 7, 10]).
23
```

- Favor tail recursion

```
-module(tail_reducer).
-export([sum/1]).

sum([]) -> 0;
sum(List) ->
	sum(List, 0).
	
sum([], Acc) -> Acc;
sum([First|Rest], Acc) ->
	sum(Rest, Acc+First).
```



#### Concurrency

* Everything is a process
* Processes are strongly isolated
* Process creation and destruction is a lightweight operation. 
* Processes have unique names

```
Eshell V10.6.4  (abort with ^G)
1> Hello = fun() -> io:format("Hello from ~p~n", [self()]) end.
#Fun<erl_eval.21.126501267>
2> self().
<0.78.0>
3> Hello().
Hello from <0.78.0>
ok
4> Hello().
Hello from <0.78.0>
ok
5> Pid = spawn(Hello).
Hello from <0.84.0>
<0.84.0>
```

* Message passing is the only way for processes to interact. 
* If you know the name of a process you can send it a message

```
-module(hello).
-export([loop/0]).

loop() ->
    receive
        {hi, From} ->
            From ! {hello, self()},
            loop()
    end.
```

```
Eshell V10.6.4  (abort with ^G)
1> c(hello).
{ok,hello}
2> Pid = spawn(fun hello:loop/0).
<0.85.0>
3> Pid ! {hi, self()}.
{hi,<0.78.0>}
4> flush().
Shell got {hello,<0.85.0>}
ok
```

* Processes can have friendly names

```
5> erlang:register(greeter, Pid).
true
6> greeter ! {hi, self()}.
{hello,<0.78.0>}
7> flush().
Shell got {hello,<0.85.0>}
ok
```

* Processes share no resources. 
* There is no global memory. 

```
-module(kv).
-export([start/0, start/1]).

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
```



```
Eshell V10.6.4  (abort with ^G)
1> c(kv)
1> .
{ok,kv}
2> Pid = kv:start().
<0.85.0>
3> Pid ! {self(), get, a}.
{<0.78.0>,get,a}
4> flush().
Shell got not_found
ok
5> Pid ! {self(), put, a, 1}.
{<0.78.0>,put,a,1}
6> flush().
Shell got ok
ok
7> Pid ! {self(), get, a}.
{<0.78.0>,get,a}
8> flush().
Shell got {ok,1}
ok
9> Pid ! finish.
unrecognized message: finish. Exiting..
finish
10>
```



#### Fault tolerance

- Error handling is non-local. 

```
Eshell V10.6.4  (abort with ^G)
1> self().
<0.78.0>
2> Pid = spawn(fun() -> test = test2 end).
<0.81.0>
=ERROR REPORT==== 1-Jun-2020::18:48:26.744575 ===
Error in process <0.81.0> with exit value:
{{badmatch,test2},[{erl_eval,expr,5,[{file,"erl_eval.erl"},{line,453}]}]}

3> self().
<0.78.0>
4> flush().
ok
```

- Processes can monitor other processes.
- When a process crashes, it exits cleanly and a signal is sent to the
  controlling process, which can then take action. 

```
Eshell V10.6.4  (abort with ^G)
1> self().
<0.78.0>
2> Pid = spawn(fun() -> test = test2 end).
=ERROR REPORT==== 1-Jun-2020::18:51:38.166317 ===
Error in process <0.81.0> with exit value:
{{badmatch,test2},[{erl_eval,expr,5,[{file,"erl_eval.erl"},{line,453}]}]}

<0.81.0>
3> pro
proc_lib     proplists
3> erlang:monitor(process, Pid).
#Ref<0.3556120366.3643015175.94881>
4> self().
<0.78.0>
5> flush().
Shell got {'DOWN',#Ref<0.3556120366.3643015175.94881>,process,<0.81.0>,noproc}
ok
```

- When a process terminates, it terminates with an EXIT signal and **reason**.
- EXIT signals are propagated to all linked processes

```
Eshell V10.6.4  (abort with ^G)
1> self().
<0.78.0>
2> Pid = spawn_link(fun() -> test = test2 end).
=ERROR REPORT==== 1-Jun-2020::18:47:03.954599 ===
Error in process <0.81.0> with exit value:
{{badmatch,test2},[{erl_eval,expr,5,[{file,"erl_eval.erl"},{line,453}]}]}

** exception exit: {badmatch,test2}
3> self().
<0.82.0>
```

- Processes can also trap EXIT signals.
- They do not terminate when an exit signal is received. 
- Instead, the signal is transformed into a regular message `{'EXIT',FromPid,Reason}`. 
- However this is not true if the reason is `kill`. 

```
Eshell V10.6.4  (abort with ^G)
1> process_flag(trap_exit, true).
false
2> self().
<0.78.0>
3> Pid = spawn_link(fun() -> test = test2 end).
=ERROR REPORT==== 1-Jun-2020::18:55:44.718316 ===
Error in process <0.82.0> with exit value:
{{badmatch,test2},[{erl_eval,expr,5,[{file,"erl_eval.erl"},{line,453}]}]}

<0.82.0>
4> self().
<0.78.0>
5> flush().
Shell got {'EXIT',<0.82.0>,
                  {{badmatch,test2},
                   [{erl_eval,expr,5,[{file,"erl_eval.erl"},{line,453}]}]}}
ok
```



#### Distribution

* Erlang nodes form clusters
* Topology is full mesh 

```
$ erl -name a@127.0.0.1 -setcookie foo
$ erl -name b@127.0.0.1 -setcookie foo
$ erl -name c@127.0.0.1 -setcookie foo
```

```
Eshell V10.6.4  (abort with ^G)
(a@127.0.0.1)1> nodes().
[]

Eshell V10.6.4  (abort with ^G)
(b@127.0.0.1)1> nodes().
[]

Eshell V10.6.4  (abort with ^G)
(c@127.0.0.1)1> nodes().
[]
```

```
(a@127.0.0.1)2> net_adm:ping('b@127.0.0.1').
pong
(a@127.0.0.1)3> net_adm:ping('c@127.0.0.1').
pong
```

```
(a@127.0.0.1)4> [B, C] = nodes().
['b@127.0.0.1','c@127.0.0.1']

(b@127.0.0.1)2> nodes().
['a@127.0.0.1','c@127.0.0.1']

(c@127.0.0.1)2> nodes().
['a@127.0.0.1','b@127.0.0.1']
```

* Function calls can be executed on remote nodes 

```
(a@127.0.0.1)5> rpc:call(B, erlang, node, []).
'b@127.0.0.1'
(a@127.0.0.1)6> rpc:call(B, erlang, nodes, []).
['a@127.0.0.1','c@127.0.0.1']

```

- Nodes can monitor other nodes

```
(a@127.0.0.1)7> net_kernel:monitor_nodes(true).
ok
(a@127.0.0.1)8> flush().
ok
```

```
(b@127.0.0.1)3>
BREAK: (a)bort (c)ontinue (p)roc info (i)nfo (l)oaded
       (v)ersion (k)ill (D)b-tables (d)istribution
```

```
(a@127.0.0.1)9> flush().
Shell got {nodedown,'b@127.0.0.1'}
ok
```

```
$ erl -name b@127.0.0.1 -setcookie foo
Erlang/OTP 22 [erts-10.6.4] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [hipe]

Eshell V10.6.4  (abort with ^G)
(b@127.0.0.1)1> net_adm:ping('a@127.0.0.1').
pong
```

```
(a@127.0.0.1)11> flush().
Shell got {nodeup,'b@127.0.0.1'}
ok
```



* Processes may be created on remote nodes

```
$ erl -name a@127.0.0.1 -setcookie foo
$ erl -name b@127.0.0.1 -setcookie foo
```

```
Eshell V10.6.4  (abort with ^G)
(a@127.0.0.1)1> net_adm:ping('b@127.0.0.1').
pong
(a@127.0.0.1)2> [B] = nodes().
['b@127.0.0.1']
```

```
(a@127.0.0.1)3> Mod = kv.
kv
(a@127.0.0.1)4> compile:file(Mod).
{ok,kv}
```

```
(a@127.0.0.1)5> rpc:call(B, compile, file, [Mod]).
{ok,kv}
```

```
(a@127.0.0.1)6> Pid = spawn(Mod, loop, [#{}]).
<0.110.0>
(a@127.0.0.1)7> RemotePid = spawn(B, Mod, loop, [#{}]).
<8691.94.0>
```

- Communication with a process is independent from its location

```
(a@127.0.0.1)8> RemotePid ! {self(), get, a}.
{<0.108.0>,get,a}
(a@127.0.0.1)12> flush().
Shell got not_found
ok
```

- Processes can be registered globally

```
(a@127.0.0.1)10> global:register_name(kv_master, RemotePid).
yes
(a@127.0.0.1)11> global:register_name(kv_master, Pid).
no
(a@127.0.0.1)12> global:whereis_name(kv_master).
<8691.94.0>
(b@127.0.0.1)1>  global:whereis_name(kv_master).
<0.94.0>
```

- Process can form groups

```
(a@127.0.0.1)13> pg2:create(stores).
ok
(a@127.0.0.1)14> pg2:join(stores, Pid).
ok
(a@127.0.0.1)15> pg2:join(stores, RemotePid).
ok
(a@127.0.0.1)16> pg2:get_members(stores).
[<8691.94.0>,<0.100.0>]
(a@127.0.0.1)17> pg2:get_closest_pid(stores).
<0.100.0>
(a@127.0.0.1)18> pg2:get_local_members(stores).
[<0.100.0>]
(a@127.0.0.1)19> pg2:which_groups().
[stores]
```



#### Observability

- Get processes

```
Eshell V10.6.4  (abort with ^G)
1> erlang:processes().
[<0.0.0>,<0.1.0>,<0.2.0>,<0.3.0>,<0.4.0>,<0.5.0>,<0.6.0>,
 <0.9.0>,<0.41.0>,<0.43.0>,<0.45.0>,<0.46.0>,<0.48.0>,
 <0.49.0>,<0.51.0>,<0.52.0>,<0.53.0>,<0.54.0>,<0.55.0>,
 <0.56.0>,<0.57.0>,<0.58.0>,<0.59.0>,<0.60.0>,<0.61.0>,
 <0.62.0>,<0.63.0>,<0.64.0>,<0.65.0>|...]
```

- Get information of a process

```
2> erlang:process_info(self()).
[{current_function,{erl_eval,do_apply,6}},
 {initial_call,{erlang,apply,2}},
 {status,running},
 {message_queue_len,0},
 {links,[<0.77.0>]},
 {dictionary,[]},
 {trap_exit,false},
 {error_handler,error_handler},
 {priority,normal},
 {group_leader,<0.64.0>},
 {total_heap_size,2585},
 {heap_size,987},
 {stack_size,24},
 {reductions,13378},
 {garbage_collection,[{max_heap_size,#{error_logger => true,kill => true,size => 0}},
                      {min_bin_vheap_size,46422},
                      {min_heap_size,233},
                      {fullsweep_after,65535},
                      {minor_gcs,2}]},
 {suspending,[]}]
 
3> erlang:process_info(self(), total_heap_size).
{total_heap_size,3196}

4> erlang:process_info(self(), message_queue_len).
{message_queue_len,0}
```



```
% consumer.erl
-module(consumer).
-export([start/0]).

start() ->
    spawn(fun() -> loop([]) end).

loop(Items) ->
    receive
        {From, switch} ->
            From ! switching,
            ?MODULE:loop(Items);

        {From, total} ->
            From ! {total, length(Items)},
            loop(Items);
        Other ->
            loop([Other|Items])
    end.
```

```
% producer.erl
-module(producer).
-export([start/0, loop/0]).

start() ->
    spawn(fun ?MODULE:loop/0).

loop() ->
    consumer ! work,
    timer:sleep(1000),
    loop().
```

```
% launcher.erl
-module(launcher).
-export([launch/1]).

launch(0) -> ok;

launch(Count) ->
    worker:start(),
    launch(Count-1).
```

```
$ erl +P 2000000
```

```
Eshell V10.6.4  (abort with ^G)
1> [ c(Mod) || Mod <- [consumer, producer, launcher]].
[{ok,consumer},{ok,producer},{ok,launcher}]
2> register(consumer, consumer:start()).
true
3> erlang:whereis(consumer).
<0.95.0>
4> launcher:launch(1).
ok
5> consumer ! {self(), total}.
{<0.78.0>,total}
6> consumer ! {self(), total}.
{<0.78.0>,total}
7> consumer ! {self(), total}.
{<0.78.0>,total}
8> flush().
Shell got {total,35}
Shell got {total,78}
Shell got {total,115}
9> observer:start().
```



```
10> launcher:launch(10000).
ok
11> launcher:launch(10000).
ok
12> launcher:launch(10000).
ok
13> length(erlang:processes()).
30040
```



```
% debugger.erl
-module(debugger).
-export([top/1]).

top(Info) ->
    Procs = erlang:processes(),
    InfoPerProc = [{P,element(2, erlang:process_info(P, Info))} || P <- Procs],
    [First|_] = lists:reverse(lists:keysort(2, InfoPerProc)),
    First.
```

```
12> c(debugger).
{ok,debugger}
13> debugger:top(total_heap_size).
{<0.93.0>,114432973}
13> debugger:top(total_heap_size).
{<0.93.0>,192505222}
14> {Suspect, _} = debugger:top(total_heap_size).
{<0.93.0>,192505222}
15> Suspect = erlang:whereis(consumer).
<0.93.0>

```

```

```



##### Hot code swapping



```
% consumer2.erl
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
```

```
$ cp consumer2.erl consumer.erl
```

```
16> c(consumer).
{ok,consumer}
17> consumer ! {self(), total}.
{<0.78.0>,total}
18> flush().
Shell got {total,23847380}
19> consumer ! {self(), switch}.
{<0.78.0>,switch}
20> flush().
Shell got switching
21> consumer ! {self(), total}.
{<0.78.0>,total}
22> flush().
Shell got {total,41997632,v2}
23> erlang:garbage_collect(erlang:whereis(consumer)).
true
```



##### Sync vs Async

- Message passing between process is async.
- Sync can be built on top of async

```
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

```

```
Eshell V10.6.4  (abort with ^G)
1> c(server).
{ok,server}
2> server:start().
ok
3> server:ping().
{error,timeout}
4> server:ping().
ok
5> server:ping().
{error,timeout}

```



### OTP

OTP stands for *Open Telecom Platform*. A collection of libraries, abstractions and standards designed to help build robust applications, based on Erlang concurrency primitives.

```
├── otp
│   └── release
│       ├── application1
│       │   └── supervisor
│       │       ├── child_sup1
│       │       │   ├── gen_server1
│       │       │   ├── gen_server2
│       │       │   └── gen_servier3
│       │       └── child_sup2
│       └── application2
│           └── supervisor
```

* **Releases** package up applications, runtime options and configuration in a single deliverable.
* **Applications** organize groups of logic as supervision trees 

```
% my_app.erl
-module(my_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_Type, _Args) ->
    my_sup:start_link().

stop(_State) ->
    ok.
```



````
# my/application.ex
defmodule My.Application do
  use Application

  def start(_type, _args) do
  	# Initialize a supervision tree as part
  	# and return the pid of the root supervisor
  end
end
````

* **Supervisors** form supervision trees and manage the lifecycle of child supervisor and worker processes

```
-module(my_supervisor).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link(?MODULE, []).

init(_Args) ->
    SupFlags = #{strategy => one_for_one, intensity => 1, period => 5},
    ChildSpecs = [#{id => my_worker,
                    start => {my_worker, start_link, []},
                    restart => permanent,
                    shutdown => brutal_kill,
                    type => worker,
                    modules => [my_worker]}],
    {ok, {SupFlags, ChildSpecs}}.
```

```
# child specs
children = [
	{My.Stack, []},
	{DynamicSupervisor, strategy: :one_for_one, name: My.DynamicSupervisor}
]

# strategy and name
ops = [strategy: :one_for_one, name: My.Supervisor]


{:ok, pid} = Supervisor.start_link(children, opts)
```

More on supervisors: https://erlang.org/doc/design_principles/sup_princ.html

- **Dynamic Supervisors** are a special kind of supervisors in Elixir (similar to the `simple_one_to_one` strategy in Erlang)

```
# Dynamically add a new worker as a child to the supervisor
{:ok, agent1} = DynamicSupervisor.start_child(My.DynamicSupervisor, {My.Stack, []})
```

* **Generic Servers** are battle tested worker processes.

```
-module(my_stack).
-behaviour(gen_server).

-export([start_link/0]).
-export([pop/0, push/1]).
-export([init/1, handle_call/3, handle_cast/2]).

% Public Api
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

pop() ->
    gen_server:call(?MODULE, pop).

push(Element) ->
    gen_server:cast(?MODULE, {push, Element}).

% Callbacks

init(Stack) ->
    {ok, Stack}.

handle_call(pop, _From, [Head|Tail]) ->
    {reply, Head, Tail}.

handle_cast({push, Element}, Stack) ->
    {noreply, [Element|Stack]}.
```



```
defmodule My.Stack do
  use GenServer
  
  # Public api
  
  def start_link() do
  	GenServer.start_link(Stack, [], name: __MODULE__)
  end
  
  def pop() do
  	GenServer.call(__MODULE__, :pop)
  end
  
  def push(element) do
  	GenServer.cast(__MODULE__, {:push, element})
  end

  # Callbacks

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end
end
```

More on GenServers: https://erlang.org/doc/design_principles/gen_server_concepts.html



* TCP Servers and clients (gen_tcp)
* State Machines (gen_statem)
* Tasks and Agents (Elixir)
* Registry (Elixir)
* Term Storage (ETS)



## Elixir

Elixir is a dynamic, functional language designed for building scalable and maintainable applications.

Elixir leverages the Erlang VM, known for running low-latency, distributed and fault-tolerant systems, while also being successfully used in web development and the embedded software domain.

Created by Jose Valim in 2011.



## Features

- Modern, ruby like syntax

```
defmodule Fun do
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n), do: fib(n-2) + fib(n-1)  
end
```

- Variable rebinding

```
$ iex
Erlang/OTP 22 [erts-10.6.4] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [hipe]

Interactive Elixir (1.10.1) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> a = :a
:a
iex(2)> a = :b
:b
```

Explanation: http://blog.plataformatec.com.br/2016/01/comparing-elixir-and-erlang-variables/

- Metaprogramming via compile time Macros (50% of Elixir's code is written in Elixir itself)

```
defmodule My.Database.Model do
	 use Ecto.Schema

   schema "entries" do
     field :key, :string, primary_key: true
     field :version, :integer, primary_key: true
     field :value, :string

     timestamps()
   end
   ...
end
```



```
defmodule My.Web.Controller do
	use DemoWeb, :router
	 
	scope "/keys", DemoWeb do
    	pipe_through :api

    	get "/:key", KvController, :get
    	put "/:key/:value", KvController, :put
    	delete "/:key", KvController, :delete
	end
	...
end
```



- Pipe operator

```
iex> foo(bar(baz(new_function(other_function()))))

iex> other_function() |> new_function() |> baz() |> bar() |> foo()
iex> "Elixir rocks" |> String.upcase() |> String.split()
["ELIXIR", "ROCKS"]
```



- Railway oriented programming (`with` construct)

```
with {:ok, data} <- do_something(),
		 {:ok, data} <- do_something_else() do
		 
	...
else
	...
end
```



- Lazy and async collections with streams

````
iex> range = 1..3
iex> stream = Stream.map(range, &(&1 * 2))
iex> Enum.map(stream, &(&1 + 1))
[3, 5, 7]
````



- Python-like docstrings
- Polymorphism via protocols
- Configuration per environment



## Elixir major projects

* [Hex](https://hex.pm) (The package manager for the Erlang ecosystem)
* [Phoenix Framework](https://www.phoenixframework.org)  (Web,  development, Scalable Pub/Sub)
* [Ecto](https://hexdocs.pm/ecto/Ecto.html) (ORM with first class support for Postgres)
* [Mix](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html) (Tooling, automation)

```
$ mix phx.new myproject
$ mix deps.get
$ mix compile
$ mix docs
$ mix test
$ mix ecto.migrate
$ mix hex.info jason

mix hex.info jason
A blazing fast JSON parser and generator in pure Elixir.

Config: {:jason, "~> 1.2"}
Releases: 1.2.1, 1.2.0, 1.1.2, 1.1.1, 1.1.0, 1.0.1, 1.0.0, 1.0.0-rc.3, ...

Licenses: Apache-2.0
Links:
  GitHub: https://github.com/michalmuskala/jason
  
$ mix deps.update jason
$ mix release
```

* [Nerves](https://www.nerves-project.org) (IoT and Embedded Devices)
* [LibCluster](https://github.com/bitwalker/libcluster) (Automatic cluster formation/healing for Elixir applications)

```
config :libcluster,
  topologies: [
    k8s_example: [
      strategy: Elixir.Cluster.Strategy.Kubernetes,
      config: [
        mode: :ip,
        kubernetes_node_basename: "myapp",
        kubernetes_selector: "app=myapp",
        kubernetes_namespace: "my_namespace",
        polling_interval: 10_000]]]
```

* [Horde](https://github.com/derekkraan/horde) (Elixir distributed Supervisor and Registry backed by DeltaCrdt)
* [Swarm](https://github.com/bitwalker/swarm) (Easy clustering, registration, and distribution of worker processes for Erlang/Elixir)
* [Riak Core](https://github.com/basho/riak_core) (Distributed systems infrastructure used by Riak)
* [ExUnit](https://hexdocs.pm/ex_unit/ExUnit.html) Unit testing framework for Elixir

```
defmodule ExampleTest do
  use ExUnit.Case
  doctest Example

  test "greets the world" do
    assert Example.hello() == :world
  end
end
```



## Other language on the Beam

- LFE (Lisp Flavoured Erlang)
- Luerl (Lua)
- Alpaca (ML inspired)
- Gleam (Rust inspired)
- Clojerl (Clojure on the Erlang VM)
- Efene (Python inspired)



## Famous quotes

* "If Java is 'write once, run anywhere', then Erlang is 'write once, run forever'.”

* "The problem with object-oriented languages is they’ve got all this implicit environment that they carry around with them. You wanted a banana but what you got was a gorilla holding the banana and the entire jungle".

* "Make it work, then make it beautiful, then if you really, really have to, make it fast. 90 percent of the time, if you make it beautiful, it will already be fast. So really, just make it beautiful!"

  

## Links

* https://www.erlang.org
* https://elixir-lang.org
* https://www.phoenixframework.org
* https://www.youtube.com/watch?v=uKfKtXYLG78 (Erlang, the movie)
* https://www.youtube.com/watch?v=JvBT4XBdoUE (The soul of Erlang, by Sara Juric)
* https://www.erlang-solutions.com/blog/let-s-talkconcurrency-panel-discussion-with-sir-tony-hoare-joe-armstrong-and-carl-hewitt.html



## Books

* Programming Erlang (Joe Armstrong)
* Elixir in Action (Sara Juric)
* Erlang/OTP in Action
* Design for scalability with Erlang/OTP (Francesco Cesarini)

## Similar projects in other languages

* Akka (Scala, JVM) https://akka.io
* Microsoft Orleans https://github.com/dotnet/orleans
* Proto actor (Go) https://github.com/AsynkronIT/protoactor-go 

