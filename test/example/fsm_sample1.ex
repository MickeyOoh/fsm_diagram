defmodule FsmSample1 do
  @moduledoc """
  Sample of FsmDiagram for test
  """
  use FsmDiagram

  def start_link(fsm_id \\ __MODULE__) do
    {:ok, _pid} = fsm_start(fsm_id, :init, self())
  end

  def init(pid) do
    # initialize process
    send(pid, {:initialized, self(), "finishied init()"})
    moveto(:ledoff, [])
  end

  def ledoff(argv) do
    # turn off led
    _ledoff(argv)
  end
  defp _ledoff(argv) do
    receive do
      {:on, _from, _msg}  -> moveto(:ledon, [0])
      _ -> _ledoff(argv)
    end
  end

  def ledon(argv) do
    # turn on led
    _ledon(argv)
  end
  defp _ledon(argv) do
    receive do
      {:off, _from, _msg} -> moveto(:ledoff, [0])
      _    -> _ledon(argv)
    end
  end
  
  defp moveto(func, argv) do
    func = Function.capture(__MODULE__, func, 1)
    update_fnc(func, argv)
  end
end
