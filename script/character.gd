extends CharacterBody3D

@onready var HEAD = $Head

@onready var JUMP_BTN = $"../UI/JumpBtn"
@onready var RUN_BTN = $"../UI/RunBtn"


@onready var PICK_RAY = $Head/Eye/Camera3D/pick_up_ray
var PICK_OBJECT = null
@onready var PICK_TARGET = $Head/Eye/Camera3D/SpringArm3D/pick_target
@onready var PICK_HAND = $"../UI/pick_hand"
var CAN_PICK_OBJECT = true


const SENSITIVITY = 0.2
var RUN_BTN_MODE = false
var SPEED = 4.0
const JUMP_VELOCITY = 4.5

const lerp_time = 10
var direction = Vector3.ZERO


var is_running = false


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
	if event is InputEventScreenDrag:
		if event.position.x > 400:
			rotate_y(deg_to_rad(-event.relative.x * SENSITIVITY))
			HEAD.rotate_x(deg_to_rad(-event.relative.y * SENSITIVITY))
		
			HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-80), deg_to_rad(60))
			

func _physics_process(delta):
	#OBJECT PICKUP
	
	if PICK_OBJECT != null:
		PICK_OBJECT.global_transform.origin = PICK_TARGET.global_transform.origin
		PICK_OBJECT.global_rotation = Vector3.ZERO
		
		if PICK_HAND.is_pressed() and CAN_PICK_OBJECT:
			PICK_OBJECT.collision_layer = 1
			PICK_OBJECT.collision_mask = 1
			PICK_OBJECT = null
			CAN_PICK_OBJECT = false
			get_node("pick_timer").start()
			
	
	
	if PICK_RAY.is_colliding():
		var COLLIDER = PICK_RAY.get_collider()
		
		if COLLIDER is RigidBody3D and COLLIDER.is_in_group('item'):
			PICK_HAND.show()
			
			if PICK_HAND.is_pressed() and CAN_PICK_OBJECT:
				COLLIDER.collision_layer = 0
				COLLIDER.collision_mask = 0
				PICK_OBJECT = COLLIDER
				CAN_PICK_OBJECT = false
				get_node("pick_timer").start()
				
		else:
			if PICK_OBJECT == null:
				PICK_HAND.hide()
			else:
				PICK_HAND.show()
	
	else:
		if PICK_OBJECT == null:
			PICK_HAND.hide()
		else:
			PICK_HAND.show()

	
	
	
	
	
	
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	#JUMP
	if Input.is_action_just_pressed("ui_accept") or JUMP_BTN.is_pressed() and is_on_floor():
		velocity.y = JUMP_VELOCITY
		

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if RUN_BTN.is_pressed():
		input_dir.y = -1
		SPEED = 8.0
		is_running = true
		
	else:
		SPEED = 4.0
		is_running = false
		
		
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_time)
	
	if direction:
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()


func _on_pick_timer_timeout():
	CAN_PICK_OBJECT = true
	
