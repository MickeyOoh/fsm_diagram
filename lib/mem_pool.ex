defmodule MemPool do
  @moduledoc """
  :ets wrapper to manage variables with Module name 

  """
  use Task

  @tblname :mempool # table name for :ets

  @spec start_link(any()) :: {:ok, pid()}
  def start_link(_argv) do
    :ets.new(@tblname, [:named_table, :public, :set])
    Task.start_link(fn -> init() end)
  end
  
  #@spec init() :: none()
  defp init() do
    :global.register_name(__MODULE__, self())
    manager()
  end

  defp manager() do
    receive do
      {:get, from, key} -> get_reply(from, key)
      _ -> nil 
    end
    manager() 
  end

  @spec get_reply(pid(), any()) :: any()
  defp get_reply(from, key) do
    {^key, func, argv, vars} = get_mpf(key)
    data = {key, func, argv, vars}
    send(from, {:get, data})
  end

  # Public functions
  @doc """
  create mem to check if it is new 
  """
  @spec cre_mpf(tuple()) :: boolean() 
  def cre_mpf(data) do
    :ets.insert_new(@tblname, data)
  end

  @doc """
  update data into mem 
  """
  @spec put_mpf(tuple()) :: boolean() 
  def put_mpf(data) do
    :ets.insert(@tblname,  data)
  end
  
  @spec put_mpfelm(any(), {pos_integer(), any()} | [{pos_integer(), any()}]) :: boolean()
  def put_mpfelm(key, block) do
    :ets.update_element(@tblname, key, block)
  end

  @spec get_mpfelm(any(), integer()) :: any()
  def get_mpfelm(key, pos) do
    :ets.lookup_element(@tblname, key, pos)
  end

  @spec get_mpf(any()) :: tuple() | nil
  def get_mpf(key) do
    data = :ets.lookup(@tblname, key)
    case  data do
      [data] -> data
      [] -> nil
    end
  end

  @spec get_mpfkeys() :: [any()]
  def get_mpfkeys() do
    :ets.tab2list(@tblname)
    |> Enum.map(fn tuple -> elem(tuple, 0) end)
  end
  
  @spec delete(any()) :: any()
  def delete(key) do
    :ets.delete(@tblname, key)
  end
  

end
