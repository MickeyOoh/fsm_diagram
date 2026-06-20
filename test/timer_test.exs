defmodule TimerMngTest do
  use ExUnit.Case
  doctest TimerMng

  defp timer_2() do
    time = 150
    eve = :tim2
    TimerMng.set_timcb(:oneshot, self(), time, eve)
    sta = TimerMng.get_systime()
    rec_check(eve, time + 100)
    leap = TimerMng.timestamp(sta)
    IO.puts("timer2: #{eve} :leap(#{time}ms) -> #{leap}ms")
    # check :cyclic 
    time = 200
    eve  = :cyc2
    TimerMng.set_timcb(:cyclic, self(), time, eve)
    sta = TimerMng.get_systime()
    rec_check(eve, time + 100)
    leap = TimerMng.timestamp(sta)
    IO.puts("timer2: #{eve} :leap(#{time}ms) -> #{leap}ms")
    
    TimerMng.set_timcb(:cancel, self(), 0, eve)
     
  end

  test "check timer module" do
    pid = :global.whereis_name(TimerMng)
    send(pid, {:none, self(), 100})   # illegal data send

    spawn(fn -> timer_2() end)
    time = 100
    eve  = :tim
    TimerMng.set_timcb(:oneshot, self(), time, eve)
    sta = TimerMng.get_systime()
    rec_check(eve, time + 100)
    leap = TimerMng.timestamp(sta)
    IO.puts("0: #{eve} :leap(#{time}ms) -> #{leap}ms")

    TimerMng.set_timcb(:oneshot, self(), time, eve)
    assert rec_check(:tim, time - 5) == false
    # check :cyclic 
    time = 200
    eve  = :cyc
    TimerMng.set_timcb(:cyclic, self(), time, eve)
    
    sta = TimerMng.get_systime()
    rec_check(eve, time + 100)
    leap = TimerMng.timestamp(sta)
    IO.puts("1: #{eve} :leap(#{time}ms) -> #{leap}ms")
    # get_lists() |> IO.inspect()
    lists = TimerMng.get_lists()
    IO.puts("timer lists = #{inspect lists}")
    send(pid, {:none, self(), 100})   # illegal data send
    TimerMng.set_timcb(:none, self(), time, eve)
    TimerMng.set_timcb(:oneshot, self(), 0, :tim)
    
    sta = TimerMng.get_systime()
    rec_check(eve, time + 100)
    leap = TimerMng.timestamp(sta)
    IO.puts("2: #{eve}: leap(#{time}ms) -> #{leap}ms")
    
    sta = TimerMng.get_systime()
    rec_check(eve, time + 100)
    leap = TimerMng.timestamp(sta)
    IO.puts("3: #{eve} :leap(#{time}ms) -> #{leap}ms")
    #
    TimerMng.set_timcb(:cancel, self(), 0, eve)
  end

  defp rec_check(event, timeout) do
    receive do
      {^event, _from, _msg} -> :true
    after timeout -> :false
    end
  end
  
end
