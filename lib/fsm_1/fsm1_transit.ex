defmodule Fsm1 do
  alias Fsm_manager, as: FSM

  #defstruct [:mod, :func, :arg, :statime]

  def start() do
    FSM.start_link(__MODULE__, :init, 0)  # (mod, func, arg)
  end

  def init(cb) do
    %{cb | func: :ledoff, arg: 0}
  end

  def ledoff(cb) do
    if cb.arg == 0 do
      IO.puts("#{cb.func}  (#{timestamp(cb)})")
      %{cb | arg: cb.arg + 1}
    else
      {eve, _msg} = FSM.rcv_msg()
      case eve do
        :on ->
          %{cb | func: :ledon, arg: 0}
        :flk ->
          %{cb | func: :flicker, arg: 0}
        _ -> 
          cb = %{cb | arg: cb.arg + 1} 
          IO.puts("#{cb.func}  cont(#{timestamp(cb)})")
          ledoff(cb)
      end
    end
  end

  def ledoff_loop(cb) do
    {eve, _msg} = FSM.rcv_msg()
    case eve do
      :on ->
        %{cb | func: :ledon, arg: 0}
      :flk ->
        %{cb | func: :flicker, arg: 0}
      _ -> 
        cb = %{cb | arg: cb.arg + 1} 
        IO.puts("#{cb.func}  cont(#{timestamp(cb)})")
        ledoff_loop(cb)
    end
  end

  def ledon(cb) do
    IO.puts("#{cb.func}  (#{timestamp(cb)})")
    ledon_loop(cb)
  end
  def ledon_loop(cb) do
    {eve, _msg} = FSM.rcv_msg()
    case eve do
      :off ->
        %{cb | func: :ledoff, arg: 0}
      :flk ->
        %{cb | func: :flicker, arg: 0}
      _ -> 
        IO.puts("#{cb.func}  cont(#{timestamp(cb)})")
        ledon_loop(cb)
    end
  end
  def flicker(cb) do
    IO.puts("#{cb.func}  (#{timestamp(cb)})")
    Timer.set_timcb(:cyclic, cb.mod, div(250, FSM.get_tick), :tim)
    flicker_loop(cb)
  end
  def flicker_loop(cb) do
    {eve, _msg} = FSM.rcv_msg()
    case eve do
      :flk_off ->
        Timer.set_timcb(:cancel, cb.mod, 0, :tim)
        %{cb | func: :ledoff, arg: 0}
      :flk ->
        %{cb | func: :flicker, arg: 0}
      :tim ->
        cb =
          if cb.arg == 0 do
            IO.puts("flk led off  (#{timestamp(cb)})")
            %{cb | arg: 1}
          else
            IO.puts("flk led on   (#{timestamp(cb)})")
            %{cb | arg: 0}
          end
        flicker_loop(cb)
      _ -> 
        IO.puts("#{cb.func}  cont(#{timestamp(cb)})")
        flicker_loop(cb)
    end
  end
  
  def flickerslow(cb) do
    IO.puts("#{cb.func}  (#{timestamp(cb)})")
    Timer.set_timcb(:cyclic, cb.mod, div(500, FSM.get_tick), :tim)
    flicker_loop(cb)
  end
  
  def timestamp(cb) do
    curtime = System.os_time(:millisecond)
    div(curtime - cb.statime, 10) * 10
  end
end
