%
% This file is part of AtomVM.
%
% Copyright 2019-2020 Fred Dushin <fred@dushin.net>
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
% SPDX-License-Identifier: Apache-2.0 OR LGPL-2.1-or-later
%

-module(test_logger).

-export([test/0, do_log/1, counter/1]).

-include("etest.hrl").
-include("logger.hrl").

test() ->
    start_counter(),
    logger:start([{sinks, [{?MODULE, do_log}]}]),

    ?ASSERT_MATCH(get_counter(info), 0),
    ?ASSERT_MATCH(get_counter(warning), 0),
    ?ASSERT_MATCH(get_counter(error), 0),
    ?ASSERT_MATCH(get_counter(debug), 0),

    ok = ?LOG_INFO("This is an info", []),
    ?ASSERT_MATCH(get_counter(info), 1),
    ?ASSERT_MATCH(get_counter(warning), 0),
    ?ASSERT_MATCH(get_counter(error), 0),
    ?ASSERT_MATCH(get_counter(debug), 0),

    ok = ?LOG_WARNING("This is a warning", []),
    ?ASSERT_MATCH(get_counter(info), 1),
    ?ASSERT_MATCH(get_counter(warning), 1),
    ?ASSERT_MATCH(get_counter(error), 0),
    ?ASSERT_MATCH(get_counter(debug), 0),

    ok = ?LOG_ERROR("This is an error", []),
    ?ASSERT_MATCH(get_counter(info), 1),
    ?ASSERT_MATCH(get_counter(warning), 1),
    ?ASSERT_MATCH(get_counter(error), 1),
    ?ASSERT_MATCH(get_counter(debug), 0),

    ok = ?LOG_DEBUG("This is a debug", []),
    ?ASSERT_MATCH(get_counter(info), 1),
    ?ASSERT_MATCH(get_counter(warning), 1),
    ?ASSERT_MATCH(get_counter(error), 1),
    ?ASSERT_MATCH(get_counter(debug), 0),

    logger:set_levels([debug, info]),
    ok = ?LOG_INFO("Another info ~p", [info]),
    ok = ?LOG_WARNING("Another warning ~p", [warning]),
    ok = ?LOG_ERROR("Another error ~p", [error]),
    ok = ?LOG_DEBUG("Another debug ~p", [debug]),
    ?ASSERT_MATCH(get_counter(info), 2),
    ?ASSERT_MATCH(get_counter(warning), 1),
    ?ASSERT_MATCH(get_counter(error), 1),
    ?ASSERT_MATCH(get_counter(debug), 1),

    % logger:set_sinks([{logger, console_log}]),
    % ok = ?LOG_INFO("Some sample ~p logging to print to the console.", [info]),

    ok.


do_log({_Location, _Time, _Pid, Level, _Msg} = _LogRequest) ->
    increment_counter(Level).


-record(state, {
    counters = [
        {info, 0},
        {warning, 0},
        {error, 0},
        {debug, 0}
    ]
}).

start_counter() ->
    Pid = spawn(?MODULE, counter, [#state{}]),
    erlang:register(counter, Pid).

increment_counter(Level) ->
    Pid = erlang:whereis(counter),
    Pid ! {increment, Level}.

get_counter(Level) ->
    timer:sleep(50),
    Pid = erlang:whereis(counter),
    Ref = erlang:make_ref(),
    Pid ! {self(), Ref, get_counter, Level},
    receive
        {Ref, Counter} -> Counter
    end.

counter(#state{counters=Counters} = State) ->
    NewState = receive
        {increment, Level} ->
            Value = proplists:get_value(Level, Counters),
            State#state{counters=[{Level, Value + 1} | lists:keydelete(Level, 1, Counters)]};
        {Pid, Ref, get_counter, Level} ->
            Pid ! {Ref, proplists:get_value(Level, Counters)},
            State
    end,
    counter(NewState).
