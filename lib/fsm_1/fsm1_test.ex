defmodule Fsm1_Test do
  alias Fsm_manager, as: FSM

  def do_test() do
    FSM.start()
    Fsm1.start()
    statime = System.os_time(:millisecond)
    do_loop(statime)
  end

  def do_loop(statime) do
    Process.sleep(1000)
    FSM.notifyevent(Fsm1, :on, "hello")
    Process.sleep(3000)
    FSM.notifyevent(Fsm1, :off, "bye")
    Process.sleep(3000)
    FSM.notifyevent(Fsm1, :flk, "flicker on")
    Process.sleep(3000)
    #FSM.notifyevent(Fsm1, :flk_slow, "flicker off")
    #Process.sleep(3000)
    FSM.notifyevent(Fsm1, :flk_off, "bye")
    do_loop(statime)
  end

end
