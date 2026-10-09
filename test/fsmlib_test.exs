defmodule Fsmdiagram.FsmlibTest do
  use ExUnit.Case
  doctest FsmDiagram.Fsmlib
  alias FsmDiagram.Fsmlib

  @test_fsm "Fsmlib"

  test "check if get fsmid from self()" do
    {:ok, _pid} = Sample.start(@test_fsm)
    rec_check(:initialized, 1000)
    # update_fnc()
    assert(Fsmlib.get_fsm() == nil)
    assert(Fsmlib.get_elm(:func) == nil)
    assert(Fsmlib.get_elm(:argv) == nil)
    rec_check(:end, 1000)
  end

  defp rec_check(event, timeout) do
    receive do
      {^event, _from, _msg} -> true
    after timeout ->
      false
    end
  end

end

defmodule Sample do
  use FsmDiagram
  
  import ExUnit.Assertions

  @test_fsm "Fsmlib"
  
  def start(fsm_id \\ __MODULE__) do
    {:ok, _pid} = fsm_start(fsm_id, :init, self())
  end
  def init(pid) do
    # initialize process
    send(pid, {:initialized, self(), "finishied init()"})
    assert(@test_fsm in fsm_table()) 
    assert(self_fsmid() == @test_fsm)
    fsmpid = get_fsmpid(@test_fsm)
    assert(fsmpid == self())
    assert(get_fsmpid("test1") == nil)
    put_vars("put_vars")
    moveto(:state_1, pid)
  end
  def state_1(pid) do
    assert(get_elm(:vars) == "put_vars") 
    
    {fsmid, func, argv, vars} = get_fsm()
    assert(fsmid == {@test_fsm, :fsm})
    my_func = Function.capture(__MODULE__, :state_1, 1)
    assert(func == my_func)
    assert(argv == pid)
    assert(vars == "put_vars")
    assert(get_elm(:func) == my_func)
    assert(get_elm(:argv) == pid)
    assert(get_elm(:test1) == nil)
    send(pid, {:end, self(), "end"})
    state_1(pid)
  end

  defp moveto(func, argv) do
    func = Function.capture(__MODULE__, func, 1)
    update_fnc(func, argv)
  end
end
