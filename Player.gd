extends CharacterBody3D

@onready var camera3d = $Neck/Camera3D

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	camera3d.current = is_multiplayer_authority()

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * 0.01)
			camera.rotate_x(-event.relative.y * 0.01)
			#Make it where the player can't look straight up or down... adds a bit of realism
			#...and makes it where the camera is less confusing
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-30), deg_to_rad(60) )
	if Input.is_action_just_pressed("quit"):
		$"../".exit_game(name.to_int())
		get_tree().quit()

func _physics_process(delta):
	#If your not the server then disable
	#if is_multiplayer_authority():
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var input_dir = Input.get_vector("left", "right", "forward", "back")
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#This bases movement off the player object itself 
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#This makes it where 'forward' is based off the camera (which is part of the neck)
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
