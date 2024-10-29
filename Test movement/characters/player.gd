extends CharacterBody2D

signal crouch_signal()
signal jumped()
signal landing()

var JakeAbandonedUs = true
var SweetPotatoWithSalt = true

@export var SPEED : float = 200.0
@export var ACCELERATION = 500.0
@export var friction = 800.0
@export var air_resistance = 200.0
@export var JUMP_VELOCITY : float = -200.0
@export var DOUBLE_JUMP_VELOCITY : float = -150.0
@export var WALL_JUMP_PUSHBACK : float = 100
@export var wall_slide_gravity : float = 100

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var cshape = $CollisionShape2D
@onready var crouch_raycast1 = $CrouchRaycast_1
@onready var crouch_raycast2 = $CrouchRaycast_2
@onready var wall_raycast_right = $WallCheck_Right
@onready var wall_raycast_left = $WallCheck_Left

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var HAS_DOUBLE_JUMPED : bool = false
var touched_a_wall = false
var has_jumped = false
var jump_timer = false
var HAS_WALL_JUMPED : bool = false
var animation_locked : bool = false
var was_in_air : bool = false
var is_crouching = false
var stuck_under_object = false
var is_wall_sliding = false
var crouch_velocity = 0.5


var crouching_cshape = preload("res://cshapes/plater_crouch_cshape.tres")
var standing_cshape = preload("res://cshapes/plater_stand_cshape.tres")

func _physics_process(delta):
	# Add the gravity.
	var direction = Input.get_axis("left", "right")
	if not is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true
		#if !jump_timer:
			#jump_timer = true
			#$JumpTimer.start()
	else:
		has_jumped = false
		HAS_DOUBLE_JUMPED = false
		HAS_WALL_JUMPED = false
		if was_in_air == true:
			animated_sprite.play("jump end")
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
	
	if is_crouching:
		crouch_velocity = 0.5
	else:
		crouch_velocity = 1
	if HAS_WALL_JUMPED == false:
		if direction != 0:
			velocity.x = move_toward(velocity.x, SPEED * crouch_velocity * direction, ACCELERATION * delta )
			if is_crouching and is_on_floor():
				animated_sprite.play("crouch walk")
			elif is_on_floor():
				animated_sprite.play("run")
		else:
			apply_friction(direction, delta)
			if is_crouching and is_on_floor():
				animated_sprite.play("crouch")
			elif is_on_floor():
				animated_sprite.play("idle")
	# Handle jump.
	# handle_wall_jump()
	wall_checker()
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			#normal jump
			jump(direction)
		elif touched_a_wall and $WallJumpGracePeriod.time_left > 0:
			wall_jump(direction)
		#elif not HAS_DOUBLE_JUMPED:
			#double_jump()
			#if is_on_wall() and $WallJumpGracePeriod.time_left > 0 :
				#wall_jump(direction)
				##print("pog")
			#else:
				

	
	#else:
		#if wall_raycast_left.is_colliding():
			#velocity.x = 100
		#if wall_raycast_right.is_colliding():
			#velocity.x = -100
	wall_slide(direction, delta)
	apply_air_resistance(direction, delta)
	move_and_slide()
	#update_animation(direction)
	update_facing_direction(direction)


#func update_animation(direction):
	#if direction != 0 and velocity.y == 0 :
		#if is_crouching:
			#animated_sprite.play("crouch walk")
		#else:
			#animated_sprite.play("run")
	#elif direction == 0 and velocity.y == 0:
		#if is_crouching:
			#animated_sprite.play("crouch")
		#else:
			#animated_sprite.play("idle")
	#elif velocity.y != 0:
		#animated_sprite.play("jump")
		#animated_sprite.frame = 5

func update_facing_direction(direction):
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

func jump(direction):
	has_jumped = true
	velocity.y = JUMP_VELOCITY
	animated_sprite.play("jump")
	#elif direction != 0:
		#animated_sprite.play("jump move")

func double_jump():
	velocity.y = DOUBLE_JUMP_VELOCITY
	animated_sprite.play("jump")
	#print("double jump")
	#animation_locked = true
	HAS_DOUBLE_JUMPED = true
	HAS_WALL_JUMPED = false
	
func wall_jump(direction):
	#animation_locked = false
	var wall_normal = get_wall_normal()
	velocity.x = wall_normal.x * SPEED
	velocity.y = JUMP_VELOCITY
	if wall_normal == Vector2.LEFT:
		direction = 1
		animated_sprite.play("jump")
	if wall_normal == Vector2.RIGHT:
		direction = -1
		animated_sprite.play("jump")
	elif wall_normal == Vector2.ZERO:
		direction = 0
	#if direction.x < 0:
		#velocity.x = WALL_JUMP_PUSHBACK
		#print("wall jump left")
	#elif direction.x > 0:
		#velocity.x = WALL_JUMP_PUSHBACK
	#print("wall jump")
	#animated_sprite.play("jump")
	#animation_locked = true
	HAS_WALL_JUMPED = true
	
func wall_slide(direction, delta):
	if is_on_wall_only():
		#print("wall slide")
		if velocity.x != 0:
			if !is_wall_sliding:
				is_wall_sliding = true
			if is_wall_sliding:
				animated_sprite.play("wall slide")
			animation_locked = true
		else:
			is_wall_sliding = false
			animated_sprite.play("jump")
			animation_locked = true
	else:
		is_wall_sliding = false
	if is_wall_sliding:
		velocity.y += (wall_slide_gravity * delta)
		velocity.y = min(velocity.y, wall_slide_gravity)

func land():
	print("test")
	animated_sprite.play("jump end")
	await animated_sprite.animation_finished
	animated_sprite.play("idle")

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
	
#func _on_animated_sprite_2d_animation_finished():
	#if(["jump end", "jump", "jump double"].has(animated_sprite.animation)):
		#animation_locked = false


func _on_crouch_signal():
	pass # Replace with function body.

func wall_checker():
	if wall_raycast_left.is_colliding() or wall_raycast_right.is_colliding():
		touched_a_wall = true
		$WallJumpGracePeriod.start()
	else:
		touched_a_wall = false


func apply_friction(direction, delta):
	if direction == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		

func apply_air_resistance(direction, delta):
	if not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_resistance * delta)


func _on_jump_timer_timeout():
	jump_timer = false
	if !has_jumped:
		animated_sprite.play("mid air")
	else: 
		await animated_sprite.animation_finished
		animated_sprite.play("mid air")
		
