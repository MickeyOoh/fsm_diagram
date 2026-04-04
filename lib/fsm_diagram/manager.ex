defmodule FsmDiagram.Manager do
  use Task
  require Logger

  alias MemPool, as: Mem
  alias TimerMng, as: Timer

  #defstruct [:mod, :func, :arg, :time]
  
  @type event() :: atom()

  @spec start_link(module(), fun(), list()) :: {:ok, pid()}
  def start_link(mod, func, argv\\ []) do
    Task.start_link(fn -> init(mod, func, argv) end)
  end
  defp init(mod, func, argv) do
    time = Timer.get_systime()
    :global.register_name(mod, self()) 
    record = {mod, func, argv, time}
    Mem.cre_mpf(record)
    dispatch(mod)
  end

  # def close(mod) do
  #  Mem.delete(mod) 
  #end

  @spec dispatch(module()) :: none() 
  def dispatch(mod) do
    {_mod, func, argv, _time} = Mem.get_mpf(mod)
    apply(mod, func, [argv])
    dispatch(mod)
  end

  @spec rcv_msg(none() | integer()) :: {event(), any()} | {:illegal, any()} 
  def rcv_msg() do
    receive do
      {eve, arg} -> {eve,arg}
      #:shutdown -> close()
      _ -> {:illegal, "illegal"}
    end
  end
  def rcv_msg(timeout) do
    receive do
      {eve, arg} -> {eve,arg}
      #:shutdown -> close()
      _ -> {:illegal, "illegal"}
      after timeout -> {:timeout, 0}
    end
  end

  @spec notifyevent(module(), event(), any()) :: any()
  def notifyevent(mod, eve, msg) do
    pid = :global.whereis_name(mod)
    send(pid, {eve, msg})
  end

  @spec update_fsm(module(), fun(), list()) :: any()
  def update_fsm(mod, func, argv) do
    {^mod, prefunc, preargv, time} = Mem.get_mpf(mod)
    prefstr = Atom.to_string(prefunc)
    fstr    = Atom.to_string(func)
    Logger.debug("Move #{mod}: #{prefstr}(#{preargv}) -> #{fstr}(#{argv})")
    Mem.put_mpf(mod, {mod, func, argv, time})
  end
  
  @spec update_arg(module(), list()) :: any()
  def update_arg(mod, argv) do
    {_mod, func, _argv, time} = Mem.get_mpf(mod)
    Mem.put_mpf(mod, {mod, func, argv, time})
  end
  
  @spec get_arg(module()) :: list()
  def get_arg(mod) do
    {_mod, _func, argv, _time} = Mem.get_mpf(mod)
    argv
  end

end
