defmodule FsmDiagram do
  @moduledoc """
  Documentation for `FsmDiagram`.
  """

  defmacro __using__(opts) do
    var_valid = Keyword.get(opts, :var_valid, false)
    quote do
      import FsmDiagram.Manager
       
      if unquote(var_valid) do

        def var_start(mod) do
          MemPool.cre_mpf({{mod, :var}, Map.new()})
        end

        defdelegate create_var(mod), to: FsmDiagram
        defdelegate set_var(mod, name, var), to: FsmDiagram
        defdelegate get_var(mod, name), to: FsmDiagram
        defdelegate remove_var(mod), to: FsmDiagram
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
