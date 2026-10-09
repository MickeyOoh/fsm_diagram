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
  @spec self_fsmid() :: fsm_id() | nil 
  def self_fsmid() do
    Registry.keys(FsmDiagram.Registry, self())
    |> List.first( )
  end
  @doc """
  get pid of fsm process from fsm_id through Registry
  fsmid: module or name of starting process
  """
  @spec get_fsmpid(fsm_id()) :: pid() | nil
  def get_fsmpid(fsm_id) do
    result = Registry.lookup(FsmDiagram.Registry, fsm_id) 
             |> List.first( )
    case result do
      {pid, _value} -> pid
      _ -> result
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
    fsm_id = self_fsmid()
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
    fsm_id = self_fsmid()
    key = {fsm_id, :fsm}
    MemPool.put_mpfelm(key, {@elmno_vars, vars})
  end 
  @doc """
  get fsm record {fsmid, func, argv, vars} from :ets
  """
  @spec get_fsm() :: tuple() | nil
  def get_fsm() do
    fsm_id = self_fsmid()
    get_fsm(fsm_id)
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
    fsm_id = self_fsmid()
    if fsm_id != nil do
      get_elm(fsm_id, kind)
    else
      nil
    end
  end
  def get_elm(fsm_id, kind) do 
    key = {fsm_id, :fsm}
    case kind do
      :func -> MemPool.get_mpfelm(key, @elmno_func)
      :argv -> MemPool.get_mpfelm(key, @elmno_argv)
      :vars -> MemPool.get_mpfelm(key, @elmno_vars)
      _ -> nil
    end
  end

  @doc """
   get list of all fsm_id 
  """
  @spec fsm_table() :: list()
  def fsm_table() do
    match_spec = [{{{:"$1", :fsm}, :_, :_, :_}, [], [:"$1"]}]
    :ets.select(:mempool, match_spec)
    #|> IO.inspect(label: "fsm_table()")
  end
end
