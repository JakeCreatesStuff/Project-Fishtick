#jake change

extends CharacterBody2D
signal crouch_signal()

@export var SPEED : float = 200.0
@export var JUMP_VELOCITY : float = -200.0
@export var DOUBLE_JUMP_VELOCITY : float = -150.0
@export var WALL_JUMP_PUSHBACK : float = 100

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var cshape = $CollisionShape2D
@onready var crouch_raycast1 = $CrouchRaycast_1
@onready var crouch_raycast2 = $CrouchRaycast_2
@onready var wall_raycast_right = $WallCheck_Right
@onready var wall_raycast_left = $WallCheck_Left

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var HAS_DOUBLE_JUMPED : bool = false
var HAS_WALL_JUMPED : bool = false
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var was_in_air : bool = false
var is_crouching = false
var stuck_under_object = false
var crouch_velocity = 0.5

var crouching_cshape = preload("res://cshapes/plater_crouch_cshape.tres")
var standing_cshape = preload("res://cshapes/plater_stand_cshape.tres")

func _physics_process(delta):
	# Add the gravity.
	print("test")
	if not is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true
	else:
		HAS_DOUBLE_JUMPED = false
		HAS_WALL_JUMPED = false
		
		if was_in_air == true:
			land()
			
		was_in_air = false
		
	if Input.is_action_just_pressed("down"):
		crouch()
		crouch_signal.emit()
	elif Input.is_action_just_released("down"):
		if overhead_check():
			stand()
		else:
			if stuck_under_object !=true:
				stuck_under_object = true
	if stuck_under_object && overhead_check():
		stand()
		stuck_under_object = false
		
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			#normal jump
			jump()
		elif not HAS_DOUBLE_JUMPED:
			if is_on_wall():
				wall_jump()
			else:
				double_jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "up", "down")
	if is_crouching:
		crouch_velocity = 0.5
	else:
		crouch_velocity = 1
	if HAS_WALL_JUMPED == false:
		if direction.x > 0:
			velocity.x = SPEED * crouch_velocity
		elif direction.x < 0 :
			velocity.x = SPEED * -crouch_velocity
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		if wall_raycast_left.is_colliding():
			velocity.x = 100
		if wall_raycast_right.is_colliding():
			velocity.x = -100
	
	move_and_slide()
	update_animation()
	update_facing_direction()

func update_animation():
	if not animation_locked:
		if direction.x != 0:
			if is_crouching:
				animated_sprite.play("crouch walk")
			else:
				animated_sprite.play("run")
		else:
			if is_crouching:
				animated_sprite.play("crouch")
			else:
				animated_sprite.play("idle")
			
func update_facing_direction():
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

func jump():
	velocity.y = JUMP_VELOCITY
	animated_sprite.play("jump")
	animation_locked = true
		
func double_jump():
	velocity.y = DOUBLE_JUMP_VELOCITY
	animated_sprite.play("jump double")
	print("double jump")
	animation_locked = true
	HAS_DOUBLE_JUMPED = true
	HAS_WALL_JUMPED = false
	
func wall_jump():
	velocity.y = JUMP_VELOCITY
	#if direction.x < 0:
		#velocity.x = WALL_JUMP_PUSHBACK
		#print("wall jump left")
	#elif direction.x > 0:
		#velocity.x = WALL_JUMP_PUSHBACK
	print("wall jump")
	animated_sprite.play("jump")
	animation_locked = true
	HAS_WALL_JUMPED = true
	
func land():
	animated_sprite.play("jump end")
	animation_locked = true

func crouch():
	if is_crouching:
		return
	is_crouching = true
	cshape.shape = crouching_cshape
	cshape.position.y = 9

func stand():
	if is_crouching == false:
		return
	is_crouching = false
	cshape.shape = standing_cshape
	cshape.position.y = 2
	
func overhead_check() -> bool:
	var result = !crouch_raycast1.is_colliding() && !crouch_raycast2.is_colliding()
	return result
	
func _on_animated_sprite_2d_animation_finished():
	if(["jump end", "jump", "jump double"].has(animated_sprite.animation)):
		animation_locked = false

func _input(event):
	if event.is_action_pressed("test"):
		velocity.x = 100
		move_and_slide()

func _on_crouch_signal():
	pass # Replace with function body.
