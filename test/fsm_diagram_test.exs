defmodule FsmDiagramTest do
  use ExUnit.Case
  doctest FsmDiagram
  alias FsmDiagram, as: FSM

  setup_all do
    name = "LED1"
    {:ok, pid} = FsmSample1.start_link(name)
    rec_check(:initialized, 100)
    reg_pid = Registry.whereis_name({FsmDiagram.Registry, name})
    assert reg_pid == pid
    fsm_list = FSM.fsm_table()
    assert(name in fsm_list)
    
    name = "LED2"
    {:ok, pid} = FsmSample1.start_link(name)
    rec_check(:initialized, 100)
    reg_pid = Registry.whereis_name({FsmDiagram.Registry, name})
    assert reg_pid == pid
    fsm_list = FSM.fsm_table()
    assert(name in fsm_list)
    # get lists
    pid = FsmDiagram.get_fsmpid("fsm_manager") 
    send(pid, {:get_all, self(), "get all keys"})
    keys = receive do
      {:reply, _from, keys} -> keys 
      after 100 -> []
    end
    assert("LED1" in keys)
    assert("LED2" in keys)
    {:ok, names: ["LED1", "LED2"]}
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
    #pid = Registry.whereis_name({FsmDiagram.Registry, name})
    pid = FSM.get_fsmpid(name)
    send(pid, {eve, self(), msg})
  end
  
  defp rec_check(event, timeout) do
    receive do
      {^event, _from, _msg} -> true
    after timeout ->
      false
    end
  end
end

