defmodule MemPoolTest do
  use ExUnit.Case
  doctest MemPool

  @test_key :test1
  @test_data1 {:test1, :init, 123, %{}}

  setup_all do
    lists = :global.registered_names()
    assert MemPool in lists
    lists = :ets.all()
    assert :mempool in lists
    assert(MemPool.get_mpf(@test_key) == nil)
    MemPool.cre_mpf(@test_data1)
    assert(MemPool.get_mpf(@test_key) == @test_data1)
    assert(MemPool.cre_mpf(@test_data1) == false)
    assert(@test_key in MemPool.get_mpfkeys())
    {:ok, test_key: @test_key}
  end

  test "put data into memory test" do
    MemPool.put_mpf(@test_data1)
    assert(MemPool.get_mpf(@test_key) == @test_data1)
    {key, _dt1, dt2, dt3} = MemPool.get_mpf(:test1) 
    MemPool.put_mpfelm(@test_key, {2, :state2})
    assert(MemPool.get_mpf(:test1) == {key, :state2, dt2, dt3})
    MemPool.put_mpfelm(@test_key, [{2, :state}, {3, 654}, {4, %{a: 1}}])
    assert(MemPool.get_mpf(:test1) == {key, :state, 654, %{a: 1}})
    # send message to get data test
    pid = :global.whereis_name(MemPool)
    send(pid, {:get, self(), @test_key})
    receive do
      {:get, data} -> assert(data == {key, :state, 654, %{a: 1}})
    end
    send(pid, {:get, self(), "key1", "key2"})
    receive do

    after 100 -> assert(true)
    end
  end

  test "delete with key test" do
    data = MemPool.get_mpf(@test_key) 
    assert(is_tuple(data))
    MemPool.delete(@test_key)
    assert(MemPool.get_mpf(@test_key) == nil)
  end
end
