%%% gen_server для обслуговування кешу
-module(lesson6_task1_1).
-behaviour(gen_server).

%% API
-export([start_link/1, insert/3, insert/4, lookup/2]).
%% Callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% API
start_link(TableName) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, TableName, []).

insert(TableName, Key, Value) ->
    gen_server:call(?MODULE, {insert, TableName, Key, Value, infinity}).

insert(TableName, Key, Value, Ttl) ->
    gen_server:call(?MODULE, {insert, TableName, Key, Value, Ttl}).

lookup(TableName, Key) ->
    gen_server:call(?MODULE, {lookup, TableName, Key}).

%% Callbacks
init(TableName) ->
    ets:new(TableName, [named_table, public, set]),
    {ok, #{table => TableName, interval => 60000}}.

handle_call({insert, TableName, Key, Value, infinity}, _From, State) ->
    ets:insert(TableName, {Key, Value, infinity}),
    {reply, ok, State};

handle_call({insert, TableName, Key, Value, Ttl}, _From, State) ->
    Expiry = erlang:system_time(second) + Ttl,
    ets:insert(TableName, {Key, Value, Expiry}),
    {reply, ok, State};

handle_call({lookup, TableName, Key}, _From, State) ->
    Now = erlang:system_time(second),
    case ets:lookup(TableName, Key) of
        [{Key, Value, infinity}] -> {reply, Value, State};
        [{Key, Value, Expiry}] when Expiry > Now -> {reply, Value, State};
        _ -> {reply, undefined, State}
    end.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(timeout, State) ->
    TableName = maps:get(table, State),
    Now = erlang:system_time(second),
    Fun = fun({Key, _Value, Expiry}) when Expiry =/= infinity, Expiry < Now ->
                  ets:delete(TableName, Key);
              (_) -> ok
          end,
    ets:foldl(Fun, ok, TableName),
    erlang:send_after(maps:get(interval, State), self(), timeout),
    {noreply, State}.

terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
