%%% Application для запуску supervisor
-module(lesson6_task1_3).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    lesson6_task1_2:start_link().

stop(_State) ->
    ok.