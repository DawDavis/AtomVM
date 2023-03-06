%
% This file is part of AtomVM.
%
% Copyright 2023 Davide Bettio <davide@uninstall.it>
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

-module(test_close_avm_pack).

-export([start/0]).

-include("code_load/code_load_pack_data.hrl").

start() ->
    Bin = ?CODE_LOAD_PACK_DATA,
    _ = atomvm:add_avm_pack_binary(Bin, [{name, mypack}]),
    ok = atomvm:close_avm_pack(mypack, []),
    try export_test_module:exported_func(4) of
        _Any -> -1
    catch
        error:undef -> 0
    end.
