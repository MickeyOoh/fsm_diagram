defmodule ManagerTest do
  use ExUnit.Case
  doctest FsmDiagram.Manager

  setup_all do
    {:ok, test_code: "manager.ex"}
  end

  test "put data into memory test" do
    pid = FsmDiagram.get_fsmpid("fsm_manager") 
    send(pid, {:get_all, self(), "get all keys"})
    receive do
      {:reply, _from, keys} -> keys 
      after 100 -> []
    end
    send(pid, {:get, self(), "get all keys"})
    Process.sleep(50)
  end

end
