defmodule MemPool do
  @moduledoc """
  :ets wrapper to manage variables with Module name 

  """
  use Task
  

  @tblname :mempool # table name for :ets

  @spec start_link(any()) :: {:ok, pid()}
  def start_link(_argv) do
    Task.start_link(fn -> init() end)
  end
  
  @spec init() :: none()
  defp init() do
    :global.register_name(__MODULE__, self())
    :ets.new(@tblname, [:named_table, :public, :set])
    manager()
  end

  @spec manager() :: none()
  defp manager() do
    receive do
      {:get, from, key} -> get_reply(from, key)
      {:put, from, data} -> put_reply(from, data)
    end
    manager() 
  end

  @spec get_reply(pid(), any()) :: any()
  defp get_reply(from, key) do
    {_key, func, argv, time} = get_mpf(key)
    data = {key, func, argv, time}
    send(from, {:get, data})
  end

  @spec put_reply(pid(), any()) :: any()
  defp put_reply(from, data) do
    put_mpf(data)
    send(from, {:put, data})
  end

  # Public functions
  @doc """
  create mem  
  """
  @spec cre_mpf(Tuple) :: boolean() 
  def cre_mpf(data) do
    :ets.insert_new(@tblname, data)
  end
  
  @spec put_mpf(Tuple) :: boolean() 
  def put_mpf(data) do
    :ets.insert(@tblname,  data)
  end
  
  @spec put_mpfelm(any(), block :: Tuple | List) :: boolean()
  def put_mpfelm(key, block) do
    :ets.update_element(@tblname, key, block)
  end

  @spec get_mpfelm(any(), integer()) :: tuple()
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

  @spec get_mpfkeys() :: List
  def get_mpfkeys() do
    :ets.tab2list(@tblname)
    |> Enum.map( fn tuple -> elem(tuple, 0) end)
  end
  
  @spec delete(any()) :: any()
  def delete(key) do
    :ets.delete_object(@tblname, key)
  end
  

end
