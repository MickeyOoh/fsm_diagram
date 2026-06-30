defmodule TimerMngTest do
  use ExUnit.Case
  doctest TimerMng

  defp timer_2() do
    time = 150
    eve = :tim2
    TimerMng.set_timcb(:oneshot, self(), time, eve)
    sta = TimerMng.get_systime()
    assert(rec_check(eve, time + 10), "#{eve}:#{time}ms -> #{TimerMng.timestamp(sta)}ms")
    # check :cyclic 
    time = 200
    eve  = :cyc2
    TimerMng.set_timcb(:cyclic, self(), time, eve)
    sta = TimerMng.get_systime()
    assert(rec_check(eve, time + 10), "#{eve}:#{time}ms -> #{TimerMng.timestamp(sta)}ms")
    
    TimerMng.set_timcb(:cancel, self(), 0, eve)
     
  end

  test "check timer module" do
    # check ileegal event by sending set timer
    pid = :global.whereis_name(TimerMng)
    send(pid, {:none, self(), 100})   # illegal data send
    # start timer_2 task to check the multi timer control
    spawn(fn -> timer_2() end)
    # check the timer
    time = 100
    eve  = :tim
    TimerMng.set_timcb(:oneshot, self(), time, eve)
    sta = TimerMng.get_systime()
    assert(rec_check(eve, time + 10), "#{eve}:#{time}ms -> #{TimerMng.timestamp(sta)}ms")

    TimerMng.set_timcb(:oneshot, self(), time, eve)
    assert rec_check(eve, time - 10) == false
    # check :cyclic 
    time = 200
    eve  = :cyc
    TimerMng.set_timcb(:cyclic, self(), time, eve)
    
    sta = TimerMng.get_systime()
    assert(rec_check(eve, time + 10), "#{eve}:#{time}ms -> #{TimerMng.timestamp(sta)}ms")
    # check illegal event    
    send(pid, {:none, self(), 100})   # illegal data send
    TimerMng.set_timcb(:none, self(), time, eve)
    # timer 0 check
    TimerMng.set_timcb(:oneshot, self(), 0, :tim)
    #
    Process.sleep(10)
    lists = TimerMng.get_lists()
    IO.puts("timer lists = #{inspect lists}")
    
    sta = TimerMng.get_systime()
    assert(rec_check(eve, time + 50), "#{eve}:#{time}ms -> #{TimerMng.timestamp(sta)}ms")
    
    sta = TimerMng.get_systime()
    assert(rec_check(eve, time + 10), "#{eve}:#{time}ms -> #{TimerMng.timestamp(sta)}ms")
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
