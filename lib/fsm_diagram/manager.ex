defmodule Fsm_manager do

  defstruct [:mod, :func, :arg, :statime]

  @tick 10
  
  def start() do
    #:ets.new(:fsm_cb, [:named_table, :public, :set])
    Timer.start_link(@tick)
  end

  def start_link(mod, func, arg \\ 0) do
    statime = System.os_time(:millisecond)
    cb = %Fsm_manager{mod: mod, func: func, arg: arg, statime: statime}
    IO.puts("start_link #{inspect cb}")
    pid = spawn(__MODULE__, :dispatch, [cb])
    :global.register_name(mod, pid) 
    #:ets.insert_new(:fsm_cb, {mod, cb})
    pid
  end
  
  def dispatch(cb) do
    cb = apply(cb.mod, cb.func, [cb])
    dispatch(cb)
  end

  def rcv_msg() do
    receive do
      {eve, arg} ->
        {eve,arg}
      _ ->
        IO.puts("receive the other")
        {:end, "stop"}
    end
  end

  def trcv_msg(timeout) do
    receive do
      {eve, arg} ->
        {eve,arg}
      _ ->
        IO.puts("receive the other")
        {:end, "stop"}
      after timeout -> {:timeout, 0}
    end
  end

  def notifyevent(mod, eve, msg) do
    pid = :global.whereis_name(mod)
    send(pid, {eve, msg})
  end

  def get_tick() do
      @tick
  end
  
  ##def get_sts(mod) do
  ##  rec = :ets.lookup(:fsm_cb, mod)
  ##  case rec do
  ##    [{_mod, cb}] -> 
  ##            IO.puts("#{inspect cb}")
  ##            cb 
  ##    [] -> :error
  ##  end
  ##end
  ##
  ##def set_sts(mod, cb) do
  ##  :ets.insert(:fsm_cb, { mod, cb})
  ##  #{mod, func, step}
  ##  cb
  ##end

end
