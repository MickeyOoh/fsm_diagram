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

  @spec start(module(), fun(), list()) :: {:ok, pid()}
  def start(mod, func, argv\\ []) do
   {:ok, _pid} = Task.start_link(fn -> init(mod, func, argv) end)
  end

  @spec init(module(), fun(), list()) :: none()
  defp init(mod, func, argv) do
    Mem.cre_mpf({{mod, :fsm}, func, argv, 0})
    dispatch(mod)
  end

  @spec dispatch(module()) :: none() 
  defp dispatch(mod) do
    key = {mod, :fsm}
    record = Mem.get_mpf(key)
    {^key, func, argv, _time} = record
    Logger.debug("#{mod}: #{Atom.to_string(func)}(#{inspect argv})")
    apply(mod, func, [argv])
    dispatch(mod)
  end

  #defp logging(mod, record) do
  #  {_key, func, argv, _time} = record
  #  funcstr = Atom.to_string(func)
  #  Logger.debug("#{mod}: #{funcstr}(#{inspect argv})")
  #end

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
  #@spec put_elm(module(), atom(), any()) :: any()
  #def put_elm(mod, :func, data) when is_atom(data) do
  #  key = {mod, :fsm}
  #  :ets.update_element(@tblname, key, {@elmno_func, data})
  #end
  #def put_elm(mod, :argv, data) when is_list(data) do
  #  key = {mod, :fsm}
  #  :ets.update_element(@tblname, key, {@elmno_argv, data})
  #end
  #def put_elm(mod, :time, data) when is_integer(data) do
  #  key = {mod, :fsm}
  #  :ets.update_element(@tblname, key, {@elmno_time, data})
  #end
  #def put_elm( _, _, _), do: false

end
