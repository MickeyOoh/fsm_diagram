defmodule MemVariables do
  @moduledoc """
  Documentation for `MemVariables`.
  """
  @type fsm_id() :: module() | String.t()

  @spec create_var(fsm_id() | String.t()) :: boolean()
  def create_var(mod) do
    MemPool.cre_mpf({{mod, :var}, Map.new()})
  end

  @spec set_var(fsm_id(), atom(), any()) :: boolean()
  def set_var(mod, name, var) do
    key = {mod, :var}
    {^key, m_data } = MemPool.get_mpf(key)
    m_data = Map.put(m_data, name, var)
    record = {key, m_data}
    MemPool.put_mpf(record)
  end

  @spec get_var(fsm_id(), atom()) :: any() | nil
  def get_var(mod, name) do
    key = {mod, :var}
    {^key, m_data} = MemPool.get_mpf(key)
    Map.get(m_data, name) 
  end

  @spec remove_var(fsm_id()) :: boolean()
  def remove_var(mod) do
    key = {mod, :var}
    MemPool.delete(key)
  end

end
