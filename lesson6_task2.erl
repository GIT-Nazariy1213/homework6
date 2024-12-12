-module(lesson6_task2).
-include("d:/Programs/Erl/Erlang OTP/lib/common_test/include/ct.hrl").

-export([all/0, init_per_suite/1, end_per_suite/1, init_per_testcase/2, end_per_testcase/2,
         test_insert_lookup/1, test_expiry/1]).

all() -> [test_insert_lookup, test_expiry].

init_per_suite(Config) ->
    application:start(lesson6_task1_3),
    Config.

end_per_suite(_Config) ->
    application:stop(lesson6_task1_3).

init_per_testcase(_TestCase, Config) ->
    Config.

end_per_testcase(_TestCase, _Config) ->
    ok.

%%% Тест: вставка і пошук
test_insert_lookup(_Config) ->
    ok = lesson6_task1_1:insert(my_cache, key1, value1),
    ?assertEqual(value1, lesson6_task1_1:lookup(my_cache, key1)).

%%% Тест: перевірка часу життя запису
test_expiry(_Config) ->
    ok = lesson6_task1_1:insert(my_cache, key2, value2, 1),
    ?assertEqual(value2, lesson6_task1_1:lookup(my_cache, key2)),
    timer:sleep(2000),
    ?assertEqual(undefined, lesson6_task1_1:lookup(my_cache, key2)).
