defmodule MemPool do
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
      {:put, from, key, data} -> put_reply(from, key, data)
    end
    manager() 
  end
  
  defp get_reply(from, key) do
    {_key, func, argv, time} = get_mpf(key)
    data = {key, func, argv, time}
    send(from, {:get, data})
  end
  defp put_reply(from, key, data) do
    put_mpf(key, data)
    send(from, {:put, data})
  end

  # Public functions
  @doc """
  
  ## Tests

    iex> MemPool.cre_mpf({Test1, :init, [1], 123})
    true

  """
  @spec cre_mpf(Tuple) :: boolean() 
  def cre_mpf(data) do
    :ets.insert_new(@tblname, data)
  end
  
  @spec put_mpf(any(), Tuple) :: boolean() 
  def put_mpf(_key, data) do
    :ets.insert(@tblname,  data)
  end
  
  @spec update_elm(key :: any(), block :: Tuple | List) :: boolean()
  def update_elm(key, block) when is_list(block) do
    :ets.update_element(@tblname, key, block)
  end

  def get_mpf(key) do
    data = :ets.lookup(@tblname, key)
    case  data do
      [data] -> data
      [] -> :error
    end
  end

  def delete(key) do
    :ets.delete_object(@tblname, key)
  end
  
  def get_tbname(), do: @tblname

end
