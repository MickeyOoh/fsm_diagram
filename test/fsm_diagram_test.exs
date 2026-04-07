defmodule FsmDiagramTest do
  use ExUnit.Case
  doctest FsmDiagram
  alias FsmDiagram.Manager, as: FSM

  defp test_mod do
    FsmSample2
  end

  setup_all do
    {:ok, pid} = test_mod().start_link()
    Process.sleep(10)  # wait till FsmSample activate
    assert :global.whereis_name(test_mod()) == pid
    {:ok, pid: pid}

    on_exit(fn -> close() end)
  end
  defp close() do
    pid = :global.whereis_name(test_mod()) 
    Process.monitor(pid)
    Process.exit(pid, :kill)
    receive do
      {:DOWN, _ref, :process, ^pid, reason} -> 
              IO.puts("FsmSample :Down <-#{reason}")
        :ok
    after
      100 -> :timeout # 必要に応じてタイムアウト設定
    end
    TimerMng.set_timcb(:cancel, test_mod(), 0, :tim)
  end
  test "check state transfer" do
    mod = test_mod()
    assert(:init == FSM.get_elm(mod, :func) )
    notify(mod, :go_sts1, "sts1")
    Process.sleep(3)
    assert(:state_1 == FSM.get_elm(mod, :func) )
    notify(mod, :go_sts2, "sts2")
    Process.sleep(3)
    assert(:state_2 == FSM.get_elm(mod, :func) )
    notify(mod, :go_sts3, "sts3")
    Process.sleep(3)
    assert(:state_3 == FSM.get_elm(mod, :func) )
  end

  def notify(mod, eve, msg) do
    # send data to fsm module
    pid = :global.whereis_name(mod)
    send(pid, {eve, self(), msg})
  end

end

