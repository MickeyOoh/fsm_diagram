defmodule FsmDiagramTest do
  use ExUnit.Case
  doctest FsmDiagram

  alias FsmDiagram.Manager, as: FSM

  setup_all do
    {:ok, pid} = FsmSample.start()
    Process.sleep(10)  # wait till FsmSample activate
    assert :global.whereis_name(FsmSample) == pid
    {:ok, pid: pid}

    on_exit(fn -> close() end)
  end
  defp close() do
    IO.puts("FsmDiagramTest closing")
    # プロセスに停止信号を送り、終了するまで待機する
    pid = :global.whereis_name(FsmSample) 
    IO.puts("FsmSample pid=#{pid}")
    Process.monitor(pid)
    Process.exit(pid, :normal)
    
    receive do
      {:DOWN, _ref, :process, ^pid, _reason} -> :ok
    after
      5000 -> :timeout # 必要に応じてタイムアウト設定
    end
    TimerMng.set_timcb(:cancel, FsmSample, 0, :tim)
    #:global.unregister_name(FsmSample)

  end

  test "check state transfer" do
    FSM.notifyevent(FsmSample, :on, "hello")
    Process.sleep(1000)
    FSM.notifyevent(FsmSample, :off, "bye")
    Process.sleep(1000)
    FSM.notifyevent(FsmSample, :flk, "flicker on")
    Process.sleep(3000)
    FSM.notifyevent(FsmSample, :flk_off, "bye")
    Process.sleep(1000)
  end

end

defmodule FsmSample do
  alias FsmDiagram.Manager, as: FSM
  
  def start() do
    FSM.start_link(__MODULE__, :init, [[0]])  # (mod, func, arg)
  end
  def init(argv) do
    moveto(:ledoff, argv)
  end

  def ledoff(argv) do
    ledoff_loop(argv)
  end
  def ledoff_loop(argv) do
    {eve, _msg} = FSM.rcv_msg()
    case eve do
      :on  -> moveto(:ledon, [0])
      :flk -> moveto(:flicker, [0])
      _ -> ledoff_loop(argv)
    end
  end

  def ledon(argv) do
    ledon_loop(argv)
  end
  def ledon_loop(argv) do
    {eve, _msg} = FSM.rcv_msg()
    case eve do
      :off -> moveto(:ledoff, [0])
      :flk -> moveto(:flicker, [0])
      _ -> ledon_loop(argv)
    end
  end
  def flicker(argv) do
    TimerMng.set_timcb(:cyclic, __MODULE__, div(250, TimerMng.get_tick()), :tim)
    flicker_loop(argv)
    TimerMng.set_timcb(:cancel, __MODULE__, 0, :tim)
  end
  def flicker_loop(argv) do
    IO.puts("flicker_loop:#{inspect argv}")
    {eve, _msg} = FSM.rcv_msg()
    case eve do
      :flk_off -> moveto(:ledoff, [0]) 
      :tim -> 
        argv = arg_on_off(argv)
        flicker_loop(argv)
      _ -> 
        flicker_loop(argv)
    end
  end
  defp arg_on_off(argv) when argv == [:off] do
    FSM.update_arg(__MODULE__, [:on])
    [:on]
  end
  defp arg_on_off(_argv) do
    FSM.update_arg(__MODULE__, [:off])
    [:off]
  end 
  defp moveto(func, argv) do
    FSM.update_fsm(__MODULE__, func, argv)
  end

end
