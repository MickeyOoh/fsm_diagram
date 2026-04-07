defmodule MemPoolTest do
  use ExUnit.Case
  doctest MemPool

  test "MemPool rise up already" do
    lists = :global.registered_names()
    assert MemPool in lists
    lists = :ets.all()
    assert MemPool.get_tblname() in lists
    on_exit(fn -> close() end)
  end
  defp close() do
   
  end

  test "MemPool create mem data" do
    #MemPool.cre_mpf( )
  end

end
