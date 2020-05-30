# Elixir intro

## Erlang & The BEAM

Erlang is a programming language used to build massively **scalable** **soft
real-time** systems with requirements on **high availability**.

Some of its uses are in:

* telecoms
* banking and fintech
* e-commerce
* computer telephony and instant messaging
* Gaming
* Healthcare
* Automotive, IoT
* Blockchain

Companies using Erlang:

* Vocalink
* Goldman Sachs
* Nintendo
* BT Mobile
* Samsung
* Bet365
* WhatsApp


Erlang's runtime system has built-in support for **concurrency**, **distribution** and **fault tolerance**.


**OTP** is set of Erlang **libraries** and **design principles** providing **middleware** to develop these systems. It includes:

* its own distributed database, 
* applications to interface towards other languages
* debugging and release handling tools
* hot code swapping

(https://www.erlang.org)

Some features of the language:

* immutable data
* pattern matching
* functional programming
* dynamic typing


History:

* Originally developer in 1986 by Ericsson
* Named after Danish mathematician and engineer Agner Krarup Erlang
* Originally implemented in Prolog
* Suitable for prototyping telephone exchanges, but too slow
* BEAM started in 1992, which compiles Erlang to C
* In 1998, Ericsson announced the AXD301 switch, with 1M Erlang loc and
    nine 9s availabiliy
* Opensourced in 1998
* Banned in favor of non propietary languages
* Re-adopted in 2004.
* In 2014, used by Ericsson in GPRS, 3G and LTE mobile networks. Also
    used by Nortel and T-Mobile.


Let it crash coding style

* software crashes are much like death and taxes - quite unavoidable. 
*  it would make far greater sense to treat a crash in exactly the same manner as any other normal runtime event.
*  when an Erlang process crashes, this situation is reported as just another type of message arriving in a process' mail box
*   less defensive code to write results in smaller applications

Joe Armstrong summarized the principles of processes:

* Everything is a process
* Processes are strongly isolated
* Process creation and destruction is a lightweight operation
* Message passing is the only way for processes to interact
* Processes have unique names
* Processes can monitor other processes
* If you know the name of a process you can send it a messag
* Processes share no resources. There is no global memory.

```
$ erl +P 1000000
Manager = fun Manager(Count) -> receive ping -> Manager(Count+1); count -> io:format("Pings received ~p\n", [Count]), Manager(Count) end end,
Pid = spawn(fun () -> Manager(0) end),
true = register(manager, Pid),
Worker = fun Worker() -> manager ! ping, timer:sleep(1000), Worker() end,
Load = fun Load(0) -> ok; Load(N) -> spawn(Worker), Load(N-1) end,
erlang:system_info(process_count),
Load(500000),
erlang:system_info(process_count),
manager ! {self(), count}, flush().
```

* Error handling is non-local. Processes can monitor other processes.
    Process failure is reported simply as a message.
* Processes do what they are supposed to do or fail


```
TODO: monitor process, crash, + spawn link
```

Supervision trees:

* A hierarchy of processes, where the top level process is a supervisor.
* A supervisor spawns child processes.
* Children can be workers, or supervisors.
* Supervisors manage the lifecycle of children. They monitor them and
    implement restart strategies.
* They provide a highly scalable and fault-tolerant environment within which application functionality can be implemented.


Concurrency:

* borrows ideas from CSP, but in a functional framework and uses async message passing
* lightweight processes scheduled by the BEAM
* They share no state
* Minimal overhead of 300 words of memory
* 2005 Benchmark 20 million processes in a 64bit 16GB RAM box
    (800bytes/process)


```

> Heap = total_heap_size.
> Mailbox = message_queue_len.

> [{Pid, Heap} = First|_] = lists:reverse(lists:keysort(2,[{P,element(2,
    erlang:process_info(P, Heap))}
    || P <- erlang:processes()])).

> erlang:process_info(Pid).

```
* Processes share memory using message passing.
* This removes the need for explicit locks
* Share nothing, async message passing system: 
* every process has a mailbox
* a process uses the `receive` primitive to match patterns and handle
    messages
* messages are removed from the mailbox

```
> c(kv).

> Pid = spawn(kv, loop, [#{}]).
> Pid ! {self(), get, a}.
> Pid ! {self(), put, a, 1}.
> Pid ! {self(), put, b, 2}.
> Pid ! {self(), get, a}.
> Pid ! {self(), put, a, 3}.
> Pid ! {self(), get, a}.
> Pid ! {self(), get, b}.
> flush().
```


* When a process crashes, it exits cleanly and a signal is sent to the
    controlling process, which can then take action. 


Distribution

* Erlang nodes form clusters
* Topology is full mesh 
* Nodes can monitor other nodes
* Function calls can be executed on remote nodes 

```
> erl -name a@127.0.0.1 -setcookie foo
> erl -name b@127.0.0.1 -setcookie foo
> erl -name c@127.0.0.1 -setcookie foo
> net_adm:ping('b@127.0.0.1').
> net_adm:ping('c@127.0.0.1').
> [B, C] = nodes().
> rpc:call(B, erlang, node, []).
> rpc:call(B, erlang, nodes, []).
> rpc:call(C, erlang, node, []).
> rpc:call(C, erlang, nodes, []).
> net_kernel:monitor_nodes(true).
> flush().
```

* Processes may be created on remote nodes
* communication with them is transparent with regards of location (local
    vs remote)

```
$ erl -name a@127.0.0.1 -setcookie foo
$ erl -name b@127.0.0.1 -setcookie foo

> net_adm:ping('b@127.0.0.1').
> [B] = nodes().
> Mod = kv.
> compile:file(Mod).
> rpc:call(B, compile, file, [Mod]).
> Pid1 = spawn(kv, loop, [#{}]).
> node(Pid1).
> Pid2 = spawn(B, kv, loop, [#{}]).
> node(Pid1).
```

Hot code loading

* language level dynamic software updating.
* Code is loaded, and managed as module units. 
* the system can keep two versions of a module in memory at the same
    time.


Beam
* virtual machine
* short for Bogdan's Erlang Abstract Machine (original version) or Björn's Erlang Abstract Machine (current version)
* part of the Erlang Runtime System (ERTS)
* compiles Erlang and Elixir source code into byte code
* bytecode files have the .beam extension



Famous quote:

* "If Java is 'write once, run anywhere', then Erlang is 'write once, run forever'.”





## The interactive shell

