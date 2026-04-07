defmodule FsmDiagram.Manager do
  use Task
  require Logger
  alias TimerMng, as: Timer
  @tblname :mempool

  @type key() :: {module(), :fsm}
  #defstruct [:mod, :func, :arg, :time]
  #@elmno_mod 1
  @elmno_func 2
  @elmno_argv 3
  @elmno_time 4
  @type event() :: atom()

  @spec start_link(module(), fun(), list()) :: {:ok, pid()}
  def start_link(mod, func, argv\\ []) do
    Task.start_link(fn -> init(mod, func, argv) end)
  end

  @spec init(module(), fun(), list()) :: none()
  defp init(mod, func, argv) do
    time = Timer.get_systime()
    :global.register_name(mod, self()) 
    key = {mod, :fsm}
    record = {key, func, argv, time}
    :ets.insert_new(@tblname, record)
    dispatch(mod)
  end

  @spec dispatch(key()) :: none() 
  defp dispatch(mod) do
    key = {mod, :fsm}
    [{^key, func, argv, _time}] = 
            :ets.lookup(@tblname, key) 
    apply(mod, func, [argv])
    dispatch(mod)
  end

  @spec rcv_msg(none() | integer()) :: {event(), any()} | {:illegal, any()} 
  def rcv_msg() do
    receive do
      {eve, from, arg} -> {eve, from, arg}
      msg -> {:illegal, "#{inspect msg}"}
    end
  end
  def rcv_msg(timeout) do
    receive do
      {eve, from, arg} -> {eve, from, arg}
      msg -> {:illegal, "#{inspect msg}"}
      after timeout -> {:timeout, 0}
    end
  end

  @spec update_fsm(module(), fun(), list()) :: any()
  def update_fsm(mod, func, argv) do
    prefunc = get_elm(mod, :func)
    pfuncstr = Atom.to_string(prefunc)
    funcstr = Atom.to_string(func)
    Logger.debug("Move #{mod}: #{pfuncstr}() -> #{funcstr}(#{inspect argv})")
    update_fnc(mod, func, argv)
  end
  
  @spec update_argv(module(), list()) :: any()
  def update_argv(mod, argv) do
    key = {mod, :fsm}
    :ets.update_element(@tblname, key, {@elmno_argv, argv})
  end
  @spec update_fnc(module(), fun(), list()) :: any() 
  def update_fnc(mod, func, argv) do
    key = {mod, :fsm}
    :ets.update_element(@tblname, key, [{@elmno_func, func}, {@elmno_argv, argv}])
  end

  @spec get_elm(module(), atom()) :: term()
  def get_elm(mod, kind) do
    key = {mod, :fsm}
    case kind do
      :func -> :ets.lookup_element(@tblname, key, @elmno_func)
      :argv -> :ets.lookup_element(@tblname, key, @elmno_argv)
      :time -> :ets.lookup_element(@tblname, key, @elmno_time)
      _ -> false
    end
  end

  @spec put_elm(module(), atom(), any()) :: any()
  def put_elm(mod, :func, data) when is_atom(data) do
    key = {mod, :fsm}
    :ets.update_element(@tblname, key, {@elmno_func, data})
  end
  def put_elm(mod, :argv, data) when is_list(data) do
    key = {mod, :fsm}
    :ets.update_element(@tblname, key, {@elmno_argv, data})
  end
  def put_elm(mod, :time, data) when is_integer(data) do
    key = {mod, :fsm}
    :ets.update_element(@tblname, key, {@elmno_time, data})
  end
  def put_elm(_mod, _, _), do: false

end
