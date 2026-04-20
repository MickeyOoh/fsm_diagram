defmodule FsmDiagram do
  @moduledoc """
  Documentation for `FsmDiagram`.
  """

  defmacro __using__(opts) do
    var_valid = Keyword.get(opts, :var_valid, false)
    quote do
      import FsmDiagram.Manager
      require Logger

      if unquote(var_valid) do

        def var_start(mod) do
          MemPool.cre_mpf({{mod, :var}, Map.new()})
        end

        defdelegate create_var(mod), to: FsmDiagram
        defdelegate set_var(mod, name, var), to: FsmDiagram
        defdelegate get_var(mod, name), to: FsmDiagram
        defdelegate remove_var(mod), to: FsmDiagram
      end

      def child_spec(opts) do
       %{ id: __MODULE__, start: {__MODULE__, :start_link, [opts]}}
      end

      @spec fsm_start(module(), fun(), list()) :: {:ok, pid()}
      def fsm_start(mod, fnc, argv) do
        {:ok, pid} = Task.start_link(fn -> start(mod, fnc, argv) end)
        :global.register_name(__MODULE__, pid) 
        {:ok, pid}
      end
       
      if unquote(var_valid) do
        @spec start(module(), fun(), list()) :: none()
         defp start(mod, func, argv) do
           MemPool.cre_mpf({{mod, :fsm}, func, argv, 0})
           var_start(mod)
           dispatch(mod)
         end
      else
        @spec start(module(), fun(), list()) :: none()
        defp start(mod, func, argv) do
          MemPool.cre_mpf({{mod, :fsm}, func, argv, 0})
          dispatch(mod)
        end
      end

      @spec dispatch(module()) :: none() 
      defp dispatch(mod) do
        key = {mod, :fsm}
        record = MemPool.get_mpf(key)
        {^key, func, argv, _time} = record
        Logger.debug("#{mod}: #{Atom.to_string(func)}(#{inspect argv})")
        apply(mod, func, [argv])
        dispatch(mod)
      end
    end

  end

  @spec create_var(module()) :: boolean()
  def create_var(mod) do
    MemPool.cre_mpf({{mod, :var}, Map.new()})
  end

  @spec set_var(module(), atom(), any()) :: boolean()
  def set_var(mod, name, var) do
    key = {mod, :var}
    {^key, m_data } = MemPool.get_mpf(key)
    m_data = Map.put(m_data, name, var)
    record = {key, m_data}
    MemPool.put_mpf(record)
  end

  @spec get_var(module(), atom()) :: any() | nil
  def get_var(mod, name) do
    key = {mod, :var}
    {^key, m_data} = MemPool.get_mpf(key)
    Map.get(m_data, name) 
  end

  @spec remove_var(module()) :: boolean()
  def remove_var(mod) do
    key = {mod, :var}
    MemPool.delete(key)
  end

end
