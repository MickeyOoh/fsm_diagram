defmodule TimerMng do
  use Task
  # mempool: {key, tick, []}
  defstruct [:mod, :reteve, :curtimer, :orgtimer]
  @default_tick 10

  @elmno_tick 2
  @elmno_lists 3
  
  @spec start_link(integer()) :: {:ok, pid()}
  def start_link(tick \\ @default_tick) do
    Task.start_link(fn -> init(tick) end)
  end

  @spec get_key() :: tuple()
  defp get_key(), do: {__MODULE__, :timer}

  defp init(tick) do
    :global.register_name(__MODULE__, self())
    MemPool.cre_mpf({get_key(), tick, []})
    countdown(tick, [])
  end

  # Public function
  @spec set_timcb(atom(), module() | pid(), integer(), atom()) :: any()
  def set_timcb(eve, mod, timer, reteve) do
    pid = :global.whereis_name(__MODULE__)    # This TimerMng pid
    send(pid, {eve, mod, timer, reteve})
  end
  
  @spec get_tick() :: integer()
  def get_tick() do
    MemPool.get_mpfelm(get_key(), @elmno_tick)
  end
  
  @spec get_systime() :: integer()
  def get_systime() do
    System.os_time(:millisecond)
  end

  @spec timestamp(integer()) :: integer()
  def timestamp(sta_time) do
    System.os_time(:millisecond) - sta_time
  end
  
  @spec get_lists() :: list()
  def get_lists() do
    MemPool.get_mpfelm(get_key(), @elmno_lists)
  end

  defp countdown(tick, []) do
    lists = 
      receive do
        {eve, mod, timer, reteve} -> 
                  set_cb([], mod, eve, timer, reteve)
        _  -> [] 
      end
    put_lists(lists) 
    countdown(tick, lists)
  end
  defp countdown(tick, lists) do
    lists =
      receive do
        {eve, mod, timer, reteve} ->
                    set_cb(lists, mod, eve, timer, reteve)
        dat -> IO.puts("TimerMng: received #{inspect dat}") 
                lists

        after tick - 1 -> do_count(lists)
      end
    put_lists(lists) 
    countdown(tick, lists)
  end

  defp do_count(lists) do
    Enum.map(lists, 
      fn 
        [mod, reteve, 0, 0]     -> [mod, reteve, 0, 0]
        [mod, reteve, 1, 0]     -> notify(mod, reteve, "oneshot") 
                                   [mod, reteve, 0, 0]
        [mod, reteve, 1, cyc]   -> notify(mod, reteve, "cyclic") 
                                   [mod, reteve, cyc, cyc]
        [mod, reteve, cnt, cyc] -> [mod, reteve, cnt - 1, cyc]
    end)
    #|> IO.inspect()
  end

  @spec notify(module() | pid(), atom(), any()) :: any()
  defp notify(mod, eve, msg) when is_pid(mod) do
    send(mod, {eve, self(), msg})
  end
  defp notify(mod, eve, msg) do
    pid = :global.whereis_name(mod)
    send(pid, {eve, self(), msg})
  end

  defp set_cb(lists, mod, eve, timer, reteve) do
    timer = div(timer, get_tick()) 
    case eve do
      :oneshot  -> update_or_append(lists, [mod, reteve, timer, 0])
      :cyclic   -> update_or_append(lists, [mod, reteve, timer, timer])
      :cancel   -> cancel(lists, mod)
      _     -> lists 
    end
  end
  
  defp update_or_append(lists, [mod, _reteve, _a, _b] = new_item) do
    if Enum.any?(lists, fn [key, _pre_eve, _, _] -> key == mod end) do
      # 置き換え
      Enum.map(lists, fn
        [^mod, _reteve, _, _] -> new_item
        other -> other
      end)
    else
      # 追加
      [new_item] ++ lists
    end
  end
      
  defp cancel(lists, mod) do
    Enum.reject(lists, fn
        [^mod, _, _, _] -> true
        _ -> false
    end)
  end

  defp put_lists(lists) do
    MemPool.put_mpfelm(get_key(), {@elmno_lists, lists})
  end

end
