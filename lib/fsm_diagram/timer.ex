defmodule Timer do
  
  #defstruct [:mod, :reply_eve, :curtimer, :orgtimer]

  def start_link(tick \\ 100) do
    pid = spawn(__MODULE__, :tim_manager, [tick - 1, []])
    :global.register_name(__MODULE__, pid)
    pid
  end

  def tim_manager(tick, lists) do
    countdown(tick, lists)
  end

  def countdown(tick, []) do
    lists = 
      receive do
        {eve, mod, timer, reply_eve} -> set_cb([], mod, eve, timer, reply_eve)
        _  -> [] 
      end
    countdown(tick, lists)
  end
  def countdown(tick, lists) do
    lists =
      receive do
          {eve, mod, timer, reply_eve} -> set_cb(lists, mod, eve, timer, reply_eve)
          _  -> lists
          after tick -> 
              do_count(lists)
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

  def notify(mod, eve, msg) do
    #IO.puts("notify of #{mod} #{eve} #{msg}")
    pid = :global.whereis_name(mod)
    send(pid, {eve, msg})
  end

  def set_timcb(eve, mod, timer, reply_eve) do
    pid = :global.whereis_name(__MODULE__)
    send(pid, {eve, mod, timer, reply_eve})
  end

    ##def get_timcb() do
    ##  rec = :ets.lookup(:fsm_cb, __MODULE__)
    ##  case rec do
    ##    [cb] -> 
    ##      #IO.puts("#{inspect cb}")
    ##      cb
    ##    [] -> :error
    ##  end
    ##end
  
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
      lists ++ [new_item]
    end
  end
      
  def cancel(lists, mod, reply_eve) do
    Enum.reject(lists, fn
        [^mod, ^reply_eve, _, _] -> true
        _ -> false
    end)
  end
end
