defmodule TimerMng do
  use Task
  # mempool: {key, tick, []}
  defstruct [:fsm_id, :kind, :curtimer, :orgtimer]
  @default_tick 10

  @elmno_tick 2
  @elmno_lists 3
  
  @spec start_link(integer()) :: {:ok, pid()}
  def start_link(tick \\ @default_tick) do
    {:ok, _pid} = Task.start_link(fn -> init(tick) end)

  end

  @spec get_key() :: {String.t(), atom()}
  defp get_key(), do: {"timermng", :timer}

  defp init(tick) do
    :global.register_name(__MODULE__, self())
    Process.register(self(), :timermng)
    MemPool.cre_mpf({get_key(), tick, []})
    countdown(tick, [])
  end

  # Public function
  @spec set_timcb(atom(), pid(), integer(), atom()) :: any()
  def set_timcb(eve, pid, timer, reteve) do
    send(:timermng, {eve, pid, timer, reteve})
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
        {eve, pid, timer, reteve} -> 
                  set_cb([], pid, eve, timer, reteve)
        _  -> [] 
      end
    put_lists(lists) 
    countdown(tick, lists)
  end
  defp countdown(tick, lists) do
    lists =
      receive do
        {eve, pid, timer, reteve} ->
                    set_cb(lists, pid, eve, timer, reteve)
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
        [pid, reteve, 0, 0]     -> [pid, reteve, 0, 0]
        [pid, reteve, 1, 0]     -> notify(pid, reteve, "oneshot") 
                                   [pid, reteve, 0, 0]
        [pid, reteve, 1, cyc]   -> notify(pid, reteve, "cyclic") 
                                   [pid, reteve, cyc, cyc]
        [pid, reteve, cnt, cyc] -> [pid, reteve, cnt - 1, cyc]
    end)
    #|> IO.inspect()
  end

  @spec notify(pid(), atom(), any()) :: any()
  defp notify(pid, eve, msg) when is_pid(pid) do
    send(pid, {eve, self(), msg})
  end

  defp set_cb(lists, pid, eve, timer, reteve) do
    timer = div(timer, get_tick()) 
    case eve do
      :oneshot  -> update_or_append(lists, [pid, reteve, timer, 0])
      :cyclic   -> update_or_append(lists, [pid, reteve, timer, timer])
      :cancel   -> cancel(lists, pid)
      _     -> lists 
    end
  end
  
  defp update_or_append(lists, [pid, _reteve, _a, _b] = new_item) do
    if Enum.any?(lists, fn [key, _pre_eve, _, _] -> key == pid end) do
      # 置き換え
      Enum.map(lists, fn
        [^pid, _reteve, _, _] -> new_item
        other -> other
      end)
    else
      # 追加
      [new_item] ++ lists
    end
  end
      
  defp cancel(lists, pid) do
    Enum.reject(lists, fn
        [^pid, _, _, _] -> true
        _ -> false
    end)
  end

  defp put_lists(lists) do
    MemPool.put_mpfelm(get_key(), {@elmno_lists, lists})
  end

end
