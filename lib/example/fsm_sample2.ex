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
  @var_table [{:var1, nil}, {:var2, nil}, {:var3, nil}]

  @spec start_link(any()) :: {:ok, pid}
  def start_link(argv \\ []) do
    {:ok, pid} = Task.start_link(fn -> start(__MODULE__, :init, argv) end)
    :global.register_name(__MODULE__, pid) 
    {:ok, pid}
  end

  @spec moveto(fun(), list()) :: true | false
  defp moveto(func, argv) do
    if func in Map.keys(@state_table) do
      update_fnc(__MODULE__, func, argv)
    else
      :false
    end
  end

  # State Machine functions

  @doc false
  @spec init(list()) :: none()
  def init(argv) do
    Enum.each(@var_table, 
                fn m -> {name, var} = m 
                        set_var(__MODULE__, name, var)
              end)
    true = moveto(:start, argv)
  end
  
  @doc false
  def start(argv) do
    set_var(__MODULE__, :var1, "start")
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
