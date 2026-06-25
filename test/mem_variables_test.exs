defmodule MemVariablesTest do
  use ExUnit.Case
  doctest MemVariables
  alias MemPool
  alias MemVariables, as: Vars

  @fsm_id "test1"  

  setup_all do
    assert(MemPool.get_mpf(@fsm_id) == nil)
    Vars.create_var(@fsm_id)
    {_, data} = MemPool.get_mpf({@fsm_id, :var}) 
    assert(data == [])
    {:ok, fsm_id: @fsm_id}
  end

  test "set variable test" do
    Vars.set_var(@fsm_id, :var1, 123)
    assert(Vars.get_var(@fsm_id, :var1) == 123)
    Vars.set_var(@fsm_id, :var2, 345)
    assert(Vars.get_var(@fsm_id, :var2) == 345)
    Vars.remove_var(@fsm_id)
    assert(MemPool.get_mpf(@fsm_id) == nil)
  end

end
