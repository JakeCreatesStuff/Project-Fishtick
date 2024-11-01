extends CharacterBody2D

class_name Player

signal crouch_signal()
signal facing_direction_changed(facing_right : bool)

@export var SPEED : float = 200.0
@export var SWIM_SPEED : float = 250.0
@export var ACCELERATION = 500.0
@export var friction = 800.0
@export var JUMP_VELOCITY : float = -200.0
@export var DOUBLE_JUMP_VELOCITY : float = -150.0
@export var WALL_JUMP_PUSHBACK : float = 150
@export var WALL_SLIDE_GRAVITY = 100
@export var DASH_VELOCITY : float = 600.0
@export var SWIM_DASH_VELOCITY : float = 400.0

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var cshape = $CollisionShape2D
@onready var crouch_raycast1 = $CrouchRaycast_1
@onready var crouch_raycast2 = $CrouchRaycast_2
@onready var wall_raycast_right = $WallCheck_Right
@onready var wall_raycast_left = $WallCheck_Left
@onready var burst_particles = $Burst_Particles
@onready var wet_particles = $Wet_Particles

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 480
var HAS_DOUBLE_JUMPED : bool = false
var HAS_WALL_JUMPED : bool = false
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var facing : Vector2 = Vector2.ZERO
var was_in_air : bool = false
var is_crouching = false
var stuck_under_object = false
var crouch_velocity = 0.5
var is_wall_sliding = false
var is_dashing = false
var can_dash = true
var in_water = false
var is_bursting = false
var can_burst = false
var is_wet = false

var crouching_cshape = preload("res://cshapes/plater_crouch_cshape.tres")
var standing_cshape = preload("res://cshapes/plater_stand_cshape.tres")

func _physics_process(delta):
	#burst_particles.is_emittinng
	#var mouse_position = get_local_mouse_position().normalized()
	# Add the gravity.
	#print(Global.corruption_amount)
	if is_wet:
		wet_particles.emitting = true
	else:
		wet_particles.emitting = false
	if is_bursting:
		burst_particles.emitting = true
	else:
		burst_particles.emitting = false
		
	if !is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true
	else:
		HAS_DOUBLE_JUMPED = false
		HAS_WALL_JUMPED = false
		
		if was_in_air == true:
			land()
			
		was_in_air = false
		
	if Input.is_action_just_pressed("hit"):	
		$Attack_hitbox.process_mode = Node.PROCESS_MODE_INHERIT
		#await get_tree().create_timer(0.5).timeout
		$hit_cooldown.start()
		#$Attack_hitbox.process_mode = Node.PROCESS_MODE_DISABLED
		
	if Input.is_action_just_pressed("down"):
		slide()
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
		
	if Input.is_action_just_pressed("dash") and can_dash:
		dash()
		if is_wet:
			$wet_damage.process_mode = Node.PROCESS_MODE_INHERIT
		$dash_timer.start()
		$dash_cooldown.start()
		
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if !in_water:
			if is_on_floor():
				#normal jump
				jump()
			elif wall_raycast_right.is_colliding() or wall_raycast_left.is_colliding():
				wall_jump()
			elif not HAS_DOUBLE_JUMPED:
				double_jump()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "up", "down")
	if !direction.x == 0 and !is_dashing:
		facing.x = direction.x
	if !in_water:
		#new updates
		if HAS_WALL_JUMPED == false:
			if direction.x and !is_dashing:
				#velocity.x = -direction.x * SPEED * -crouch_velocity
				velocity.x = move_toward(velocity.x, SPEED * round(direction.x), ACCELERATION * delta )
			elif is_dashing and !is_bursting:
				velocity.x = facing.x * DASH_VELOCITY
				#velocity.y = -mouse_position.y * DASH_VELOCITY * -crouch_velocity
			elif is_bursting:
				velocity.x = move_toward(velocity.x, SWIM_SPEED * round(direction.x), ACCELERATION * delta )
				velocity.y = move_toward(velocity.y, SWIM_SPEED * round(direction.y), ACCELERATION * delta )
			else:
				#velocity.x = move_toward(velocity.x, 0, SPEED)
				apply_friction(delta)
		elif is_dashing:
			velocity.x = facing.x * DASH_VELOCITY
	else:
		if (direction.x or direction.y) and !is_dashing:
			velocity.x = move_toward(velocity.x, SWIM_SPEED * round(direction.x), ACCELERATION * delta )
			velocity.y = move_toward(velocity.y, SWIM_SPEED * round(direction.y), ACCELERATION * delta )
		elif is_dashing:
			velocity.x = round(direction.x) * SWIM_DASH_VELOCITY
			velocity.y = round(direction.y) * SWIM_DASH_VELOCITY
		else:
			#velocity.x = move_toward(velocity.x, 0, SPEED)
			apply_friction(delta)	
		
	if is_crouching and is_dashing:
		cshape.position.y = -7
		cshape.shape = crouching_cshape
		
		
	
	#print(is_dashing)
	move_and_slide()
	wall_slide(delta)
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
	if !is_dashing:
		if direction.x > 0:
			animated_sprite.flip_h = false
		elif direction.x < 0:
			animated_sprite.flip_h = true
			
		emit_signal("facing_direction_changed", !animated_sprite.flip_h)
	
func jump():
	velocity.y = JUMP_VELOCITY
	animated_sprite.play("jump")
	animation_locked = true
		
func double_jump():
	velocity.y = DOUBLE_JUMP_VELOCITY
	animated_sprite.play("jump double")
	animation_locked = true
	HAS_DOUBLE_JUMPED = true
	HAS_WALL_JUMPED = false
	
func wall_jump():
	var wall_normal = get_wall_normal()
	velocity.y = JUMP_VELOCITY
	if wall_normal == Vector2.RIGHT:
		velocity.x = WALL_JUMP_PUSHBACK
	elif wall_normal == Vector2.LEFT:
		velocity.x = -WALL_JUMP_PUSHBACK
	animated_sprite.play("jump double")
	animation_locked = true
	HAS_WALL_JUMPED = true
	
func wall_slide(delta):
	if !is_on_floor() and (wall_raycast_right.is_colliding() or wall_raycast_left.is_colliding()):
		animated_sprite.play("wall slide")
		animation_locked = true
		if direction.x > 0 or direction.x < 0:
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
		
	if is_wall_sliding:
		#HAS_WALL_JUMPED = false
		velocity.y += (WALL_SLIDE_GRAVITY * delta)
		velocity.y = min(velocity.y, WALL_SLIDE_GRAVITY)

func burst():
	is_bursting = true
	animation_locked = true
	
func dash():
	is_dashing = true
	animated_sprite.play("dash")
	animation_locked = true
	can_dash = false

func land():
	animated_sprite.play("jump end")
	animation_locked = true

func slide():
	if is_dashing:
		is_crouching = true
		cshape.shape = crouching_cshape
		cshape.position.y = -7

func crouch():
	if is_crouching:
		return
	is_crouching = true
	#cshape.shape = crouching_cshape
	#cshape.position.y = -7

func stand():
	if is_crouching == false:
		return
	is_crouching = false
	cshape.shape = standing_cshape
	cshape.position.y = -14
	
func overhead_check() -> bool:
	var result = !crouch_raycast1.is_colliding() && !crouch_raycast2.is_colliding()
	return result
	
func _on_animated_sprite_2d_animation_finished():
	if(["jump end", "jump", "jump double"].has(animated_sprite.animation)):
		animation_locked = false

#func _input(event):
	#if event.is_action_pressed("test"):
		#velocity.x = 100
		#move_and_slide()

func apply_friction(delta):
	if direction.x == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func _on_crouch_signal():
	pass # Replace with function body.

func _on_dash_timer_timeout():
	is_dashing = false
	animation_locked = false
	$wet_damage.process_mode = Node.PROCESS_MODE_DISABLED
	
func _on_dash_cooldown_timeout():
	is_bursting = false
	can_dash = true

func _on_area_2d_body_entered(body):
	#print("is touching water")
	animated_sprite.play("swim")
	ACCELERATION = 600
	gravity = 100
	in_water = true
	is_wet = true
	animation_locked = true

func _on_area_2d_body_exited(body):
	#print("left water")
	ACCELERATION = 500
	gravity = 480
	in_water = false
	$wet_timer.start()
	if is_dashing:
		is_bursting = true
	animation_locked = false

func _on_wet_timer_timeout():
	if !in_water:
		is_wet = false
	#print("I'm dry :D")

func _on_hit_cooldown_timeout():
	$Attack_hitbox.process_mode = Node.PROCESS_MODE_DISABLED
