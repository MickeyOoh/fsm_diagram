defmodule FsmDiagram.Manager do

  alias MemPool, as: Mem

  require Logger

  @type key() :: {module(), :fsm}
  #defstruct [:mod, :func, :arg, :time]
  #@elmno_mod 1
  @elmno_func 2
  @elmno_argv 3
  @elmno_time 4
  @type event() :: atom()


  # Public functions
  @doc """
  
  """
  @spec update_fnc(module(), fun(), list()) :: any() 
  def update_fnc(mod, func, argv) do
    key = {mod, :fsm}
    Mem.put_mpfelm(key, [{@elmno_func, func}, {@elmno_argv, argv}])
  end
  
  @spec update_argv(module(), list()) :: any()
  def update_argv(mod, argv) do
    key = {mod, :fsm}
    Mem.put_mpfelm(key, {@elmno_argv, argv})
  end

  def info_fsm() do

  end

  @spec get_fsm(module()) :: tuple() | nil
  def get_fsm(mod) do
    key = {mod, :fsm}
    #{^key, _func, _argv, _} = Mem.get_mpf(key)
    Mem.get_mpf(key)
  end

  @spec get_elm(module(),  atom()) :: term()
  def get_elm(mod, kind) do
    key = {mod, :fsm}
    case kind do
      :func -> Mem.get_mpfelm(key, @elmno_func)
      :argv -> Mem.get_mpfelm(key, @elmno_argv)
      :time -> Mem.get_mpfelm(key, @elmno_time)
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
