defmodule TimerMngTest do
  use ExUnit.Case
  doctest TimerMng

  test "check timer module" do
    :global.register_name(TestTimer, self())
    sta = TimerMng.get_systime()
    time = div(100, TimerMng.get_tick())
    TimerMng.set_timcb(:oneshot, TestTimer, time, :tim)
    assert rec_check(:tim, 100 + 5) == true
    leap = TimerMng.timestamp(sta)
    IO.puts("leap(100ms) -> #{leap}ms")
    TimerMng.set_timcb(:oneshot, TestTimer, time, :tim)
    assert rec_check(:tim, 100 - 5) == false
    TimerMng.set_timcb(:cancel, TestTimer, 0, :tim)
  end

  defp rec_check(event, timeout) do
    receive do
      {^event, _from, _msg} -> :true
    after timeout -> :false
    end
  end
  
end
