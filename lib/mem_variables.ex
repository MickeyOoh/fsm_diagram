defmodule MemVariables do
  @moduledoc """
  to manage variable inside state machine. 

  This module provides functions to manage variables in a memory pool. It allows you to create, set, get, and remove variables associated with a specific FSM (Finite State Machine) identified by its module or name.
  """
  @type fsm_id() :: module() | String.t()

  @doc """
  Creates a variable storage for the specified FSM.
   

  """
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
    #|> IO.inspect(label: "set_var record")
    MemPool.put_mpf(record)
  end

  @spec get_var(fsm_id(), atom()) :: any() | nil
  def get_var(mod, name) do
    key = {mod, :var}
    {^key, m_data} = MemPool.get_mpf(key)
    Map.get(m_data, name) 
    #|> IO.inspect(label: "get_var")
  end

  @spec remove_var(fsm_id()) :: boolean()
  def remove_var(mod) do
    key = {mod, :var}
    MemPool.delete(key)
  end

end
