%
% This file is part of AtomVM.
%
% Copyright 2019-2021 Fred Dushin <fred@dushin.net>
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

-module(test_gen_server).

-export([test/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-record(state, {
    num_casts=0,
    num_infos=0
}).

test() ->
    ok = test_call(),
    ok = test_cast(),
    ok = test_info(),
    ok = test_start_link(),
    ok.

test_call() ->
    {ok, Pid} = gen_server:start(?MODULE, [], []),

    pong = gen_server:call(Pid, ping),
    pong = gen_server:call(Pid, reply_ping),
    %pong = gen_server:call(Pid, async_ping),

    gen_server:stop(Pid),
    ok.

test_start_link() ->
    {ok, Pid} = gen_server:start_link(?MODULE, [], []),

    pong = gen_server:call(Pid, ping),
    pong = gen_server:call(Pid, reply_ping),
    erlang:process_flag(trap_exit, true),
    ok = gen_server:cast(Pid, crash),
    receive
        {'EXIT', Pid, _Reason} -> ok
    after 1000 -> error
    end.

test_cast() ->
    {ok, Pid} = gen_server:start(?MODULE, [], []),

    ok = gen_server:cast(Pid, ping),
    ok = gen_server:cast(Pid, ping),
    ok = gen_server:cast(Pid, ping),
    ok = gen_server:cast(Pid, ping),
    ok = gen_server:cast(Pid, ping),

    5 = gen_server:call(Pid, get_num_casts),
    0 = gen_server:call(Pid, get_num_casts),

    gen_server:stop(Pid),
    ok.

test_info() ->
    {ok, Pid} = gen_server:start(?MODULE, [], []),

    Pid ! ping,
    Pid ! ping,
    Pid ! ping,

    3 = gen_server:call(Pid, get_num_infos),
    0 = gen_server:call(Pid, get_num_infos),

    gen_server:stop(Pid),
    ok.


%%
%% callbacks
%%

init(_) ->
    {ok, #state{}}.

handle_call(ping, _From, State) ->
    {reply, pong, State};
handle_call(reply_ping, From, State) ->
    gen_server:reply(From, pong),
    {noreply, State};
handle_call(async_ping, From, State) ->
    erlang:spawn(gen_server, reply, [{From, pong}]),
    {noreply, State};
handle_call(get_num_casts, From, #state{num_casts=NumCasts} = State) ->
    gen_server:reply(From, NumCasts),
    {noreply, State#state{num_casts=0}};
handle_call(get_num_infos, From, #state{num_infos=NumInfos} = State) ->
    gen_server:reply(From, NumInfos),
    {noreply, State#state{num_infos=0}}.

handle_cast(crash, _State) ->
    throw(test_crash);
handle_cast(ping, #state{num_casts=NumCasts} = State) ->
    {noreply, State#state{num_casts=NumCasts + 1}};
handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(ping, #state{num_infos=NumInfos} = State) ->
    {noreply, State#state{num_infos=NumInfos + 1}};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.
