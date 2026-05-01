defmodule FsmDiagramTest do
  use ExUnit.Case
  doctest FsmDiagram
  alias FsmDiagram.Fsmlib, as: FSM

  defp test_examples do
    [{FsmSample2, "i2c-1"}]
  end
  def getReg() do
    FsmDiagram.Registry 
  end

  setup_all do
    [{mod, name} | _] = test_examples()
    {:ok, pid} = mod.start_link(name)
    Process.sleep(10)  # wait till FsmSample activate
    reg_pid = Registry.whereis_name({getReg(), name})
    assert reg_pid == pid
    {:ok, pid: pid}

    #on_exit(fn -> close() end)
  end
  #defp close() do
  #  {mod, name} = test_mod()
  #  pid = Registry.whereis_name({FsmDigram.Registry, name})
  #  Process.monitor(pid)
  #  Process.exit(pid, :kill)
  #  receive do
  #    {:DOWN, _ref, :process, ^pid, reason} -> 
  #            IO.puts("FsmSample :Down <-#{reason}")
  #      :ok
  #  after
  #    100 -> :timeout # 必要に応じてタイムアウト設定
  #  end
  #  TimerMng.set_timcb(:cancel, test_mod(), 0, :tim)
  #end
  test "check state transfer" do
    [{mod, name} | _] = test_examples()
    statfunc = Function.capture(mod, :start, 1)
    assert(statfunc == FSM.get_elm(name, :func) )
    #
    notify(name, :go_sts1, "sts1")
    Process.sleep(3)
    statfunc = Function.capture(mod, :state_1, 1)
    assert(statfunc == FSM.get_elm(name, :func) )
    #
    notify(name, :go_sts2, "sts2")
    Process.sleep(3)
    statfunc = Function.capture(mod, :state_2, 1)
    assert(statfunc == FSM.get_elm(name, :func) )
    notify(name, :go_sts3, "sts3")
    Process.sleep(3)
    statfunc = Function.capture(mod, :state_3, 1)
    assert(statfunc == FSM.get_elm(name, :func) )
  end

  def notify(name, eve, msg) do
    pid = Registry.whereis_name({getReg(), name})
    send(pid, {eve, self(), msg})
  end

end

