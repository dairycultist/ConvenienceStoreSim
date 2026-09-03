extends Node

signal _c

## Callback should be a function with parameters (id: String, ...args: Array)
func register_callback(callback: Callable):
	_c.connect(callback)

func trigger_for(id: String, ...args: Array):
	args.push_front(id)
	_c.emit.callv(args)
