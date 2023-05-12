extends CharacterBody3D
signal health_changed(health_value)

var health = 1
const SPEED = 5.0
const JUMP_VELOCITY = 10


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func receive_damage():
	health -= 1
	if health <= 0:
		health = 5
		position = Vector3.ZERO
	health_changed.emit(health)

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta

	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
#	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var direction = (transform.basis * Vector3(randi()%500, 0, randi()%500)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
