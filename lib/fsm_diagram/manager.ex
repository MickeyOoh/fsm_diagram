defmodule FsmDiagram.Manager do

  use Task
  alias MemPool, as: Mem

  require Logger

  def start_link(_argv \\ []) do
    Registry.start_link(keys: :unique, name: FsmDiagram.Registry)
    #Registry.start_link(keys: :unique, name: FsmDiagram)
    Logger.info("Starting FsmDiagram.Manager")
    Task.start_link(fn -> fsm_task() end)
  end
  defp fsm_task() do
    Registry.register_name({FsmDiagram.Registry, "fsm_manager"}, self())
    fsm_loop()    
  end

  def fsm_loop() do
    receive do
      {:get_all, from, _argv} ->
        keys = Mem.get_mpfkeys()
               |> Enum.filter( fn {_basekey, sort} -> sort == :fsm end)
        send(from, {:reply, keys})
      msg -> Logger.info("Manager receive #{inspect msg}")  
    end
    fsm_loop()
  end

end
