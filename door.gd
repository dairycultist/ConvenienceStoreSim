extends RigidBody3D

func _ready() -> void:
	Consequences.register_callback(_consequence_callback)

func _consequence_callback(id: String, ...args: Array):
	
	if id == "touching" and args[0] == $DoorHandle:
		apply_force((args[3].global_position - args[1]) * 5.0, args[1] - global_position)
