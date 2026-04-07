defmodule FsmSample2 do
  alias FsmDiagram.Manager, as: FSM

  @state_table %{
    init:    "initial",
    state_1: "state_1",
    state_2: "state_2",
    state_3: "state_3",
    state_4: "state_4",
    state_5: "state_5",
  }

  @spec start_link() :: none()
  def start_link() do
    FSM.start_link(__MODULE__, :init, [0])  # (mod, func, arg)
  end
  
  defp moveto(func, argv) do
    if func in Map.keys(@state_table) do
      FSM.update_fsm(__MODULE__, func, argv)
    else
      :false
    end
  end

  # State Machine functions
  @spec init(list()) :: none()
  def init(argv) do
    {eve, _from, _msg} = 
      receive do
        {_, _, _} = msg -> msg
      end
    case eve do
      :go_sts1 -> true = moveto(:state_1, argv)
      :go_sts2 -> true = moveto(:state_2, argv)
      :go_sts3 -> true = moveto(:state_3, argv)
      _ -> init(argv)
    end
  end

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
    {eve, _from, _msg} = 
      receive do
        {_, _, _} = msg -> msg
      end
    case eve do
      :go_sts1 -> true = moveto(:state_1, argv)
      :go_sts3 -> true = moveto(:state_3, argv)
      _ -> state_2(argv)
    end
  end

  def state_3(argv) do
    {eve, _from, _msg} = 
      receive do
        {_, _, _} = msg -> msg
      end
    case eve do
      :go_sts1 -> true = moveto(:state_1, argv)
      :go_sts2 -> true = moveto(:state_2, argv)
      _ -> state_3(argv)
    end
  end

end
