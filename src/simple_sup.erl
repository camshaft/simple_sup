-module(simple_sup).
-behaviour(supervisor).

%% API.
-export([start_link/1]).

%% supervisor.
-export([init/1]).

%% API.

-spec start_link(list()) -> {ok, pid()}.
start_link(Procs) ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, Procs).

%% supervisor.

init(Procs) ->
  FormattedProcs = [
    case Proc of
      Module when is_atom(Module) ->
        {Module,
          {Module, start_link, []},
          permanent, 5000, worker, [Module]};
      {Module, Function} when is_atom(Module), is_atom(Function) ->
        {Module,
          {Module, Function, []},
          permanent, 5000, worker, [Module]};
      {Module, Args} when is_atom(Module), is_list(Args) ->
        {Module,
          {Module, start_link, Args},
          permanent, 5000, worker, [Module]};
      {Module, Function, Args} = Spec when is_atom(Module), is_atom(Function), is_list(Args) ->
        {Module, Spec, permanent, 5000, worker, [Module]};
      Spec ->
        Spec
    end
  || Proc <- Procs],

  {ok, {{one_for_one, 10, 10}, FormattedProcs}}.
