defmodule FsmDiagramTest do
  use ExUnit.Case
  doctest FsmDiagram
  alias FsmDiagram, as: FSM

  setup_all do
    name = "LED1"
    {:ok, pid} = FsmSample1.start(name)
    rec_check(:initialized, 100)
    reg_pid = Registry.whereis_name({FsmDiagram.Registry, name})
    assert reg_pid == pid
    fsm_list = FSM.fsm_table()
    assert(name in fsm_list)
    
    name = "LED2"
    {:ok, pid} = FsmSample1.start(name)
    rec_check(:initialized, 100)
    reg_pid = Registry.whereis_name({FsmDiagram.Registry, name})
    assert reg_pid == pid
    fsm_list = FSM.fsm_table()
    assert(name in fsm_list)
    # get lists
    pid = Registry.whereis_name({FsmDiagram.Registry, "fsm_manager"})
    send(pid, {:get_all, self(), :msg, "get all keys"})
    keys = receive do
      {:reply, _from, keys, _} -> keys 
      after 100 -> []
    end
    assert("LED1" in keys)
    assert("LED2" in keys)
    {:ok, names: ["LED1", "LED2"]}
    on_exit(fn ->
      ending( FSM.get_fsmpid("LED1") )
      ending( FSM.get_fsmpid("LED2") )
    end)
  end

  defp ending(pid) do
    if Process.alive?(pid) do
      ref = Process.monitor(pid)
      Process.exit(pid, :shutdown)
      receive do
        {:DOWN, ^ref, :process, ^pid, _reason} -> :ok
      after
        1_000 -> Process.exit(pid, :kill) # タイムアウトしたら強制終了
      end
    end
  end

  test "check state transfer no.1" do
    name = "LED1" 
    statfunc = Function.capture(FsmSample1, :ledoff, 1)
    assert(statfunc == FSM.get_elm(name, :func) )
    #
    notify(name, :on, "ledon")
    Process.sleep(3)
    statfunc = Function.capture(FsmSample1, :ledon, 1)
    assert(statfunc == FSM.get_elm(name, :func) )
    
    notify(name, :off, "ledoff")
    Process.sleep(3)
    statfunc = Function.capture(FsmSample1, :ledoff, 1)
    assert(statfunc == FSM.get_elm(name, :func) )
  end

  test "check state transfer no.2" do
    name = "LED2" 
    statfunc = Function.capture(FsmSample1, :ledoff, 1)
    assert(statfunc == FSM.get_elm(name, :func) )
    #
    {_key, func, _argv, _var} = FSM.get_fsm(name)
    assert(func == statfunc) 

    notify(name, :on, "ledon")
    Process.sleep(3)
    statfunc = Function.capture(FsmSample1, :ledon, 1)
    assert(statfunc == FSM.get_elm(name, :func) )
    
    notify(name, :off, "ledoff")
    Process.sleep(3)
    statfunc = Function.capture(FsmSample1, :ledoff, 1)
    assert(statfunc == FSM.get_elm(name, :func) )
  end

  def notify(name, eve, msg) do
    pid = Registry.whereis_name({FsmDiagram.Registry, name})
    send(pid, {eve, self(), :msg, msg})
  end
  
  defp rec_check(event, timeout) do
    receive do
      {^event, _from, _msg} -> true
    after timeout ->
      false
    end
  end
end

