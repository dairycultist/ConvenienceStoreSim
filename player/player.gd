extends CharacterBody3D

@export var walk_speed = 5.0
@export var jump_speed = 4.5
@export var mouse_sensitivity = 0.003

@export var max_handable_anchor_distance := 2.0

@onready var left_hand := $CameraMount/Camera/LeftHand
@onready var right_hand := $CameraMount/Camera/RightHand
@onready var hand_raycast := $CameraMount/Camera/HandRaycast

var left_hand_anchor: Node3D
var right_hand_anchor: Node3D

func _ready() -> void:
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	
	hand_raycast.force_raycast_update()
	
	if left_hand_anchor:
		Consequences.trigger_for(
			"touching",
			left_hand_anchor,
			left_hand.global_position,
			left_hand.global_basis.z,
			self
		)
		if not Input.is_action_pressed("left_hand") or $CameraMount/Camera/LeftHandRestPos.global_position.distance_to(left_hand.global_position) > max_handable_anchor_distance:
			left_hand_anchor = null
			left_hand.reparent($CameraMount/Camera)
	else:
		if Input.is_action_pressed("left_hand") and hand_raycast.is_colliding():
			left_hand.global_position = hand_raycast.get_collision_point()
			left_hand.look_at(left_hand.global_position + hand_raycast.get_collision_normal(), $CameraMount/Camera.global_basis.y, true)
			Consequences.trigger_for(
				"touching",
				hand_raycast.get_collider(),
				hand_raycast.get_collision_point(),
				hand_raycast.get_collision_normal(),
				self
			)
			if hand_raycast.get_collider().is_in_group("HandableAnchor"):
				left_hand_anchor = hand_raycast.get_collider()
				left_hand.reparent(left_hand_anchor)
		else:
			left_hand.position = $CameraMount/Camera/LeftHandRestPos.position
			left_hand.rotation = Vector3.ZERO
	
	if right_hand_anchor:
		Consequences.trigger_for(
			"touching",
			right_hand_anchor,
			right_hand.global_position,
			right_hand.global_basis.z,
			self
		)
		if not Input.is_action_pressed("right_hand") or $CameraMount/Camera/RightHandRestPos.global_position.distance_to(right_hand.global_position) > max_handable_anchor_distance:
			right_hand_anchor = null
			right_hand.reparent($CameraMount/Camera)
	else:
		if Input.is_action_pressed("right_hand") and hand_raycast.is_colliding():
			right_hand.global_position = hand_raycast.get_collision_point()
			right_hand.look_at(right_hand.global_position + hand_raycast.get_collision_normal(), $CameraMount/Camera.global_basis.y, true)
			Consequences.trigger_for(
				"touching",
				hand_raycast.get_collider(),
				hand_raycast.get_collision_point(),
				hand_raycast.get_collision_normal(),
				self
			)
			if hand_raycast.get_collider().is_in_group("HandableAnchor"):
				right_hand_anchor = hand_raycast.get_collider()
				right_hand.reparent(right_hand_anchor)
		else:
			right_hand.position = $CameraMount/Camera/RightHandRestPos.position
			right_hand.rotation = Vector3.ZERO
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_speed

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		global_rotation.y -= event.relative.x * mouse_sensitivity
		# TODO looking too far up causes you to fall backward, too far down fall forward
		$CameraMount.rotation.x -= event.relative.y * mouse_sensitivity
		$CameraMount.rotation.x = clamp($CameraMount.rotation.x, -PI/2 - PI/8, PI/2)
