defmodule FsmDiagram.Manager do
  @moduledoc """
  kick off the FsmDiagram and manager the state
  """
  use Task

  require Logger

  def start_link(_argv) do
    Registry.start_link(keys: :unique, name: FsmDiagram.Registry)
    #Logger.debug("Starting FsmDiagram.Manager", fsm_diagram: true)
    Task.start_link(fn -> fsm_task() end)
  end
  defp fsm_task() do
    Registry.register_name({FsmDiagram.Registry, "fsm_manager"}, self())
    fsm_loop()    
  end

  def fsm_loop() do
    receive do
      {:get_all, from, _argv1, _argv2} ->
        keys = FsmDiagram.fsm_table()
          #keys = Mem.get_mpfkeys()
        #     |> Enum.filter(fn {_basekey, sort} -> sort == :fsm end)
        send(from, {:reply, self(), keys, length(keys)})
      _msg -> #Logger.debug("Manager receive #{inspect msg}")
              :error
    end
    fsm_loop()
  end

end
