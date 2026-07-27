defmodule TimerMngTest do
  use ExUnit.Case
  doctest TimerMng

  defp timer_2() do
    timerpid = :global.whereis_name(TimerMng)
    time = 150
    eve = :tim2
    send(timerpid, {:oneshot, self(), time, eve})
    sta = timestamp()
    assert(rec_check(eve, time + 10), "#{eve}:#{time}ms -> #{timestamp(sta)}ms")
    # check :cyclic 
    time = 200
    eve  = :cyc2
    send(timerpid, {:cyclic, self(), time, eve})
    sta = timestamp()
    assert(rec_check(eve, time + 10), "#{eve}:#{time}ms -> #{timestamp(sta)}ms")
    
    send(timerpid, {:cancel, self(), time, eve})
  end

  test "check timer module" do
    # check ileegal event by sending set timer
    timerpid = :global.whereis_name(TimerMng)
    send(timerpid, {:none, self(), 100})   # illegal data send
    # start timer_2 task to check the multi timer control
    spawn(fn -> timer_2() end)
    # check the timer
    time = 100
    eve  = :tim

    send(timerpid, {:oneshot, self(), time, eve})   # illegal data send
    sta = timestamp()
    assert(rec_check(eve, time + 10), "#{eve}:#{time}ms -> #{timestamp(sta)}ms")

    send(timerpid, {:oneshot, self(), time, eve})   # illegal data send
    assert rec_check(eve, time - 10) == false
    # check :cyclic 
    time = 200
    eve  = :cyc
    send(timerpid, {:cyclic, self(), time, eve})   # illegal data send
    
    sta = timestamp()
    assert(rec_check(eve, time + 10), "#{eve}:#{time}ms -> #{timestamp(sta)}ms")
    # check illegal event    
    send(timerpid, {:none, self(), 100})   # illegal data send
    #
    Process.sleep(10)
    lists = TimerMng.get_lists()
    IO.puts("timer lists = #{inspect lists}")
    
    sta = timestamp()
    assert(rec_check(eve, time + 50), "#{eve}:#{time}ms -> #{timestamp(sta)}ms")
    
    sta = timestamp()
    assert(rec_check(eve, time + 10), "#{eve}:#{time}ms -> #{timestamp(sta)}ms")
    #
    send(timerpid, {:cancel, self(), time, eve})
  end

  defp rec_check(event, timeout) do
    receive do
      {^event, _from, _msg} -> :true
    after timeout -> :false
    end
  end

  defp timestamp(sta \\ 0) do
    System.monotonic_time(:millisecond) - sta
  end
  
end
