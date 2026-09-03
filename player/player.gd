extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENS = 0.003

func _ready() -> void:
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	
	$CameraMount/Camera/HandRaycast.force_raycast_update()
	
	if Input.is_action_pressed("left_hand") and $CameraMount/Camera/HandRaycast.is_colliding():
		$CameraMount/Camera/LeftHand.global_position = $CameraMount/Camera/HandRaycast.get_collision_point()
		$CameraMount/Camera/LeftHand.look_at($CameraMount/Camera/LeftHand.global_position + $CameraMount/Camera/HandRaycast.get_collision_normal(), $CameraMount/Camera.global_basis.y, true)
	else:
		$CameraMount/Camera/LeftHand.position = $CameraMount/Camera/LeftHandRestPos.position
		$CameraMount/Camera/LeftHand.rotation = Vector3.ZERO
	
	if Input.is_action_pressed("right_hand") and $CameraMount/Camera/HandRaycast.is_colliding():
		$CameraMount/Camera/RightHand.global_position = $CameraMount/Camera/HandRaycast.get_collision_point()
		$CameraMount/Camera/RightHand.look_at($CameraMount/Camera/RightHand.global_position + $CameraMount/Camera/HandRaycast.get_collision_normal(), $CameraMount/Camera.global_basis.y, true)
	else:
		$CameraMount/Camera/RightHand.position = $CameraMount/Camera/RightHandRestPos.position
		$CameraMount/Camera/RightHand.rotation = Vector3.ZERO
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		global_rotation.y -= event.relative.x * MOUSE_SENS
		# TODO looking too far up causes you to fall backward, too far down fall forward
		$CameraMount.rotation.x -= event.relative.y * MOUSE_SENS
		$CameraMount.rotation.x = clamp($CameraMount.rotation.x, -PI/2 - PI/8, PI/2)
