%%% Supervisor для управління gen_server
-module(lesson6_task1_2).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    ChildSpec = #{id => lesson6_task1_1,
                  start => {lesson6_task1_1, start_link, [my_cache]},
                  restart => permanent,
                  shutdown => 5000,
                  type => worker,
                  modules => [lesson6_task1_1]},
    {ok, {{one_for_one, 1, 5}, [ChildSpec]}}.
