defmodule FsmDiagram.Fsmlib do
  @moduledoc """
  libraries Fsm are using to handle FsmDiagram
  """
  
  require Logger
  @type fsm_id() :: module() | String.t()

  # {fsm_id, func, arg, vars}
  #@elmno_mod 1
  @elmno_func 2
  @elmno_argv 3
  @elmno_vars 4

  # Public functions
  @doc """
  get fsm_id from self() through Registry

  """
  @spec self_fsmid() :: module() | String.t() | :error
  def self_fsmid() do
    names = Registry.keys(FsmDiagram.Registry, self())
    case names do 
      [fsmid | _] -> {:ok, fsmid}
      [] -> {:error, "not found pid"}
    end
  end
  @doc """
  get pid of fsm process from fsm_id through Registry
  fsmid: module or name of starting process
  """
  @spec get_fsmpid(any()) :: pid() | nil
  def get_fsmpid(fsmid) do
    case Registry.lookup(FsmDiagram.Registry, fsmid) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end
  @doc """
  update State machine function and the arguement 
  func(): Module and function such as &Module.func/1
  func.(any()) executes, so append Module.
  the arity of func is fixed one but any()
  """
  @spec update_fnc(fun(), any()) :: any() 
  def update_fnc(func, argv) do
    {:ok, fsm_id} = self_fsmid()
    update_fnc(fsm_id, func, argv)
  rescue
    e ->
      {:error, Exception.message(e)}
  end
  @spec update_fnc(any(), fun(), any()) :: none()
  def update_fnc(fsm_id, func, argv) do
    key = {fsm_id, :fsm}
    MemPool.put_mpfelm(key, [{@elmno_func, func}, {@elmno_argv, argv}])
  end 
  @doc """
  put vars into vars data of {fsmid, func, argv, vars} 
  vars data is any() but one 
  the variables are stored as list of tuple [{var1,
  """
  @spec put_vars(any()) :: none() 
  def put_vars(vars) do
    {:ok, fsm_id} = self_fsmid()
    put_vars(fsm_id, vars)
  rescue
    e ->
      {:error, Exception.message(e)}
  end
  def put_vars(fsm_id, vars) do
    key = {fsm_id, :fsm}
    MemPool.put_mpfelm(key, {@elmno_vars, vars})
  end 
  @doc """
  get fsm record {fsmid, func, argv, vars} from :ets
  """
  @spec get_fsm() :: tuple() | nil
  def get_fsm() do
    {:ok, fsm_id} = self_fsmid()
    get_fsm(fsm_id)
  rescue
    e ->
      {:error, Exception.message(e)}
  end
  def get_fsm(fsm_id) do
    key = {fsm_id, :fsm}
    #{^key, _func, _argv, _} = MemPool.get_mpf(key)
    MemPool.get_mpf(key)
  end
  @doc """
  get element data from data 
  :func - function of fsm
  :argv - argument
  :vars - variable fsmid owns
  """
  @spec get_elm(atom()) :: term()
  def get_elm(kind) do
    {:ok, fsm_id} = self_fsmid()
    get_elm(fsm_id, kind)
  rescue
    e ->
      {:error, Exception.message(e)}
  end
  def get_elm(fsm_id, kind) do 
    key = {fsm_id, :fsm}
    case kind do
      :func -> MemPool.get_mpfelm(key, @elmno_func)
      :argv -> MemPool.get_mpfelm(key, @elmno_argv)
      :vars -> MemPool.get_mpfelm(key, @elmno_vars)
      _ -> false
    end
  end

  @doc """
   get list of all fsm_id 
  """
  @spec fsm_table() :: list()
  def fsm_table() do
    #MemPool.get_mpfkeys()
    #|> IO.inspect(label: "fsm_table()")
    #|> Enum.filter( fn tuple -> elem(tuple, 1) == :fsm end)
    #|> Enum.map( fn tuple -> elem(tuple, 0) end)
    match_spec = [{{{:"$1", :fsm}, :_, :_, :_}, [], [:"$1"]}]

    :ets.select(:mempool, match_spec)
    #|> IO.inspect(label: "fsm_table()")
  end
end
