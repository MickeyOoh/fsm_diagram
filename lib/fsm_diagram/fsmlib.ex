defmodule FsmDiagram.Fsmlib do

  alias MemPool, as: Mem
  
  require Logger
  @type fsm_id() :: module() | String.t()

  #struct {key, fsm_id, func, arg, vars}
  #@elmno_key 0
  #@elmno_mod 1
  @elmno_func 2
  @elmno_argv 3
  @elmno_vars 4

  # Public functions
  @doc """
  
  """
  @spec self_fsmid() :: module() | String.t() | :error
  def self_fsmid() do
    names = Registry.keys(FsmDiagram.Registry, self())
    case names do 
      [fsmid | _] -> fsmid 
      [] -> IO.puts(":error") 
        :error
    end
  end

  @spec update_fnc(fun(), list()) :: any() 
  def update_fnc(func, argv) do
    fsm_id = self_fsmid()
    update_fnc(fsm_id, func, argv)
  end
  def update_fnc(fsm_id, func, argv) do
    key = {fsm_id, :fsm}
    Mem.put_mpfelm(key, [{@elmno_func, func}, {@elmno_argv, argv}])
  end 

  @spec put_vars(fun(), list()) :: any() 
  def put_vars(vars) do
    fsm_id = self_fsmid()
    update_fnc(fsm_id, vars)
  end
  def put_vars(fsm_id, vars) do
    key = {fsm_id, :fsm}
    Mem.put_mpfelm(key, {@elmno_vars, vars})
  end 

  @spec get_fsm() :: tuple() | nil
  def get_fsm() do
    fsm_id = self_fsmid()
    get_fsm(fsm_id)
  end
  def get_fsm(fsm_id) do
    key = {fsm_id, :fsm}
    #{^key, _func, _argv, _} = Mem.get_mpf(key)
    Mem.get_mpf(key)
  end

  @spec get_elm(atom()) :: term()
  def get_elm(kind) do
    fsm_id = self_fsmid()
    get_elm(fsm_id, kind)
  end
  def get_elm(fsm_id, kind) do 
    key = {fsm_id, :fsm}
    case kind do
      :func -> Mem.get_mpfelm(key, @elmno_func)
      :argv -> Mem.get_mpfelm(key, @elmno_argv)
      :vars -> Mem.get_mpfelm(key, @elmno_vars)
      _ -> false
    end
  end

  @spec fsm_table() :: list()
  def fsm_table() do
    Mem.get_mpfkeys()
    |> Enum.filter(  fn tuple -> elem(tuple, 1) == :fsm end)
    |> Enum.map(  fn tuple -> elem(tuple, 0) end)
  end
end
