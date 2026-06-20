# FsmDiagram

[![Hex pm](https://img.shields.io/hexpm/v/fsm_diagram.svg)](https://hex.pm/packages/fsm_diagram)
[![Hex Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/fsm_diagram/)

`FsmDiagram` is a State Machine Control library to embed a sequence of operations.

## Feature

* Sequential steps are implemented by calling state function.
* Transits states mostly by message events to wait inside. otherwise these run endlessly. 
* Uses `update_fnc(fnc, arg)` to move to next state function and return to caller. 
* `fnc` should be added with `Module`(&Module.fnc/1) to allow the different module.  

## Usage

it starts according to `fsm_start()` to activate state machine task.
```
use FsmDiagram

def start_link(fsm_id \\ __MODULE__)
    {:ok, _pid} = fsm_start(fsm_id, :init, [])
end

def init(argv) do 
    moveto(:staten_1, argv)
end
def state_1(argv) do 
 ---
end

defp moveto(func, argv) do
    func = Function.capture(__MODULE__, func, 1)
    update_fnc(func, argv)
end
```

fsm_start(fsm_id, func, argv)
    fsm_id - name of the task by fsm_start() calling.
    func   - any function of state machine function.
    argv   - one argument to pass into the function.

Each State Machine function will be called by the task fsm_strat() starts.
You need to prepare `moveto(func, argv)` which set next state function and the argv into FsmDiagram.
Then FsmDiagram callbacks next state function when current function returns.


## installing

```
def deps do
  [
    {:fsm_diagram, "~> 0.1.0"}
  ]
end
```

