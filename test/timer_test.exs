defmodule TimerMngTest do
  use ExUnit.Case
  doctest TimerMng

  test "check timer module" do
    :global.register_name(TestTimer, self())
    TimerMng.set_timcb(:oneshot, TestTimer, div(100, TimerMng.get_tick()), :tim)
    assert rec_check(:tim, 100 + 10) == true
    TimerMng.set_timcb(:cancel, TestTimer, 0, :tim)
  end

  defp rec_check(event, timeout) do
    receive do
      {^event, _msg} -> :true
    after timeout -> :false
    end
  end
  
end
