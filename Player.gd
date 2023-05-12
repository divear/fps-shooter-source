extends CharacterBody3D

signal health_changed(health_value)

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/pistol/MuzzleFlash
@onready var raycast = $Camera3D/RayCast3D


var health = 5
const SPEED = 7.0
const JUMP_VELOCITY = 9
var isAdmin = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") *1.5
var isZoom
var is_drag
var is_jump_hov

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _input(event):
	if is_jump_hov:
		is_drag = event is InputEventScreenDrag or event is InputEventMouseMotion

func _ready():
	if not is_multiplayer_authority():return
	muzzle_flash.emitting = false
#	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	


func _unhandled_input(event):
	if not is_multiplayer_authority():return
	if event is  InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		camera.rotate_x(-event.relative.y * 0.005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	if Input.is_action_just_pressed("admin"):
		isAdmin = true
		anim_player.play("admin")
	if Input.is_action_just_pressed("shoot") and anim_player.current_animation != "shoot":
		shoot.rpc()
		if(raycast.is_colliding()):
			var hit_player = raycast.get_collider()
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
	if Input.is_action_just_pressed("zoom"):
		if isZoom: 
			camera.fov = 80
			isZoom = false
			return
		camera.fov /= 2
	
		isZoom = true
	if Input.is_action_just_pressed("gaming_mode"):
		var random = RandomNumberGenerator.new()
		random.randomize()
		camera.fov = 179 *random.randfn()

@rpc("call_local")
func shoot():
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 5
		position = Vector3.ZERO
	health_changed.emit(health)

func _physics_process(delta):
	if not is_multiplayer_authority():return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and isAdmin:
		velocity.y = JUMP_VELOCITY*1.4
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if is_jump_hov and is_on_floor():
		velocity.y = JUMP_VELOCITY*1.5
		
		

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
#	print(direction)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("idle")

	move_and_slide()






func _on_area_2d_mouse_entered():
	is_jump_hov = true


func _on_area_2d_mouse_exited():
	is_jump_hov = false
