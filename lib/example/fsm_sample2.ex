defmodule FsmSample2 do

  use FsmDiagram, var_valid: true

  @state_table %{
    start:   "start",
    state_1: "state_1",
    state_2: "state_2",
    state_3: "state_3",
    state_4: "state_4",
    state_5: "state_5",
  }

  @spec start_link(fsm_id()) :: {:ok, pid}
  def start_link(fsm_id \\ __MODULE__) do
    #{:ok, pid} = Task.start_link(fn -> start(__MODULE__, :init, argv) end)
    {:ok, _pid} = fsm_start(fsm_id, :init, []) 
  end

  @spec moveto(fun(), list()) :: true | false
  defp moveto(func, argv) do
    if func in Map.keys(@state_table) do
      func = Function.capture(__MODULE__, func, 1)
      update_fnc(func, argv)
    else
      :false
    end
  end

  # State Machine functions

  @doc false
  @spec init(list()) :: none()
  def init(argv) do
    true = moveto(:start, argv)
  end
  
  @doc false
  def start(argv) do
    _start(argv)
  end
  defp _start(argv) do
    {eve, _from, _msg} = 
      receive do
        {_, _, _} = msg -> msg
      end
    case eve do
      :go_sts1 -> true = moveto(:state_1, argv)
      :go_sts2 -> true = moveto(:state_2, argv)
      :go_sts3 -> true = moveto(:state_3, argv)
      _ -> _start(argv)
    end
  end
  
  @doc false
  def state_1(argv) do
    {eve, _from, _msg} = 
      receive do
        {_, _, _} = msg -> msg
      end
    case eve do
      :go_sts2 -> true = moveto(:state_2, argv)
      :go_sts3 -> true = moveto(:state_3, argv)
      _ -> state_1(argv)
    end
  end

  def state_2(argv) do

    _state_2(argv)
  end
  defp _state_2(argv) do
    {eve, _from, _msg} = 
      receive do
        {_, _, _} = msg -> msg
      end
    case eve do
      :go_sts1 -> true = moveto(:state_1, argv)
      :go_sts3 -> true = moveto(:state_3, argv)
      _ -> _state_2(argv)
    end
  end

  @doc false
  def state_3(argv) do
    _state_3(argv)
  end
  def _state_3(argv) do
    {eve, _from, _msg} = 
      receive do
        {_, _, _} = msg -> msg
      end
    case eve do
      :go_sts1 -> true = moveto(:state_1, argv)
      :go_sts2 -> true = moveto(:state_2, argv)
      _ -> _state_3(argv)
    end
  end

end
