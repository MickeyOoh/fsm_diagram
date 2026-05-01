defmodule FsmDiagram do
  @moduledoc """
  Documentation for `FsmDiagram`.
  """

  defmacro __using__(_opts) do
    #var_valid = Keyword.get(opts, :var_valid, false)
    quote do
      import FsmDiagram.Fsmlib 
      require Logger

      @type fsm_id() :: String.t() | module()

      @spec child_spec(fsm_id()) :: map()
      def child_spec(fsm_id) do
        %{id: __MODULE__, 
          start: {__MODULE__, :start_link, [fsm_id]},}
      end

      @spec fsm_start(fsm_id(), fun(), list()) :: {:ok, pid()}
      def fsm_start(fsm_id, fnc, argv) do
        {:ok, _pid} = Task.start_link(fn -> fsm_init(fsm_id, fnc, argv) end)
      end
       
      @spec fsm_init(fsm_id(), fun(), list()) :: none()
      defp fsm_init(fsm_id, func, argv) do
        # register fsm_id and make set funcs of fsm into :ets
        Registry.register_name({FsmDiagram.Registry, fsm_id}, self())
        func = Function.capture(__MODULE__, func, 1)
        MemPool.cre_mpf({{fsm_id, :fsm}, func, argv, 0})
        dispatch(fsm_id)
      end

      @spec dispatch(fsm_id()) :: none() 
      defp dispatch(fsm_id) do
        key = {fsm_id, :fsm}
        record = MemPool.get_mpf(key)
        {^key, func, argv, _var} = record
        Logger.debug("#{fsm_id}: #{inspect func}(#{inspect argv})")
        func.(argv)
        dispatch(fsm_id)
      end
    end

  end

end
