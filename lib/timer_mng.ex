defmodule TimerMng do
  use Task

  #defstruct [:mod, :reply_eve, :curtimer, :orgtimer]
  @default_tick 10

  def start_link(tick \\ @default_tick) do
    Task.start_link(fn -> init(tick) end)
  end

  defp init(tick) do
    :global.register_name(__MODULE__, self())
    #MemPool.cre_mpf(__MODULE__, [])
    countdown(tick, [])
  end

  defp countdown(tick, []) do
    lists = 
      receive do
        {eve, mod, timer, reply_eve} -> 
                  set_cb([], mod, eve, timer, reply_eve)
        _  -> [] 
      end
    countdown(tick, lists)
  end
  defp countdown(tick, lists) do
    lists =
      receive do
        {eve, mod, timer, reply_eve} ->
                    set_cb(lists, mod, eve, timer, reply_eve)
        dat -> IO.puts("TimerMng: received #{inspect dat}") 
                lists

        after tick -> do_count(lists)
      end
    countdown(tick, lists)
  end

  def do_count(lists) do
    Enum.map(lists, 
      fn 
        [mod, reply_eve, 0, 0] -> [mod, reply_eve, 0, 0]
        [mod, reply_eve, 1, 0] -> notify(mod, reply_eve, "timer") 
                   [mod, reply_eve, 0, 0]
        [mod, reply_eve, 1, cyc] -> notify(mod, reply_eve, "cyctimer") 
                   [mod, reply_eve, cyc, cyc]
        [mod, reply_eve, cnt, cyc] -> 
                   [mod, reply_eve, cnt - 1, cyc]
      end)
  end

  def notify(mod, eve, msg) when is_pid(mod) do
    send(mod, {eve, msg})
  end
  def notify(mod, eve, msg) do
    pid = :global.whereis_name(mod)
    send(pid, {eve, msg})
  end

  def set_timcb(eve, mod, timer, reply_eve) do
    pid = :global.whereis_name(__MODULE__)
    send(pid, {eve, mod, timer, reply_eve})
  end
  
  def set_cb(lists, mod, eve, timer, reply_eve) do
    case eve do
      :oneshot  -> update_or_append(lists, [mod, reply_eve, timer, 0])
      :cyclic   -> update_or_append(lists, [mod, reply_eve, timer, timer])
      :cancel   -> cancel(lists, mod, reply_eve)
      _     -> lists 
    end
  end
  
  def update_or_append(lists, [mod, _reply_eve, _a, _b] = new_item) do
    if Enum.any?(lists, fn [key, _pre_eve, _, _] -> key == mod end) do
      # 置き換え
      Enum.map(lists, fn
        [^mod, _reply_eve, _, _] -> new_item
        other -> other
      end)
    else
      # 追加
      [new_item] ++ lists
    end
  end
      
  def cancel(lists, mod, reply_eve) do
    Enum.reject(lists, fn
        [^mod, ^reply_eve, _, _] -> true
        _ -> false
    end)
  end

  def get_tick() do
    @default_tick
  end

  def get_systime() do
    System.os_time(:millisecond)
  end
  def timestamp(sta_time) do
    System.os_time(:millisecond) - sta_time
  end
end
