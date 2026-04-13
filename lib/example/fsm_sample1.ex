defmodule FsmSample1 do
  use FsmDiagram

  def start_link(_arg \\ 0) do
    start(__MODULE__, :init, [0])  # (mod, func, arg)
  end
  def init(argv) do
    moveto(:ledoff, argv)
  end

  def ledoff(argv) do
    ledoff_loop(argv)
  end
  def ledoff_loop(argv) do
    {eve, _from, _msg} = 
      receive do
        {_, _, _} = msgs -> msgs
      end
    case eve do
      :on  -> moveto(:ledon, [0])
      :flk -> moveto(:flicker, [0])
      _ -> ledoff_loop(argv)
    end
  end

  def ledon(argv) do
    ledon_loop(argv)
  end
  def ledon_loop(argv) do
    {eve, _from, _msg} = 
      receive do
        {_, _, _} = msgs -> msgs
      end
    case eve do
      :off -> moveto(:ledoff, [0])
      :flk -> moveto(:flicker, [0])
      _ -> ledon_loop(argv)
    end
  end
  def flicker(argv) do
    time = div(250, TimerMng.get_tick())
    TimerMng.set_timcb(:cyclic, __MODULE__, time,:tim)
    flicker_loop(argv)
    TimerMng.set_timcb(:cancel, __MODULE__, 0, :tim)
  end
  def flicker_loop(argv) do
    {eve, _from, _msg} = 
      receive do
        {_, _, _} = msgs -> msgs
      end
    case eve do
      :flk_off -> 
              moveto(:ledoff, [0]) 
      :tim -> 
        argv = arg_on_off(argv)
        flicker_loop(argv)
      _ -> 
        flicker_loop(argv)
    end
  end
  
  defp arg_on_off(argv) when argv == [:off], do: [:on]
  defp arg_on_off(_argv), do: [:off]

  defp moveto(func, argv) do
    update_fnc(__MODULE__, func, argv)
  end
end
