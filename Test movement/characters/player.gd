extends CharacterBody2D

class_name Player

signal crouch_signal()
signal facing_direction_changed(facing_right : bool)

@export var SPEED : float = 200.0
@export var SWIM_SPEED : float = 250.0
@export var ACCELERATION = 500.0
@export var friction = 800.0
@export var JUMP_VELOCITY : float = -225.0
@export var DOUBLE_JUMP_VELOCITY : float = -200.0
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
@onready var jump_c_shape = $JumpCShape

@onready var jump_audio = $SFX/JumpAudio
@onready var double_jump_audio = $SFX/DoubleJumpAudio
@onready var slide_audio = $SFX/SlideAudio
@onready var foot_steps = $SFX/FootSteps
@onready var land_audio = $SFX/LandAudio

@onready var animation_player = $AnimationPlayer


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

var slide_sound_is_playing = false
var footstep_sound_is_playing = false

var crouching_cshape = preload("res://cshapes/plater_crouch_cshape.tres")
var standing_cshape = preload("res://cshapes/plater_stand_cshape.tres")

func _physics_process(delta):
		#burst_particles.is_emittinng
		#var mouse_position = get_local_mouse_position().normalized()
		# Add the gravity.
	if !Global.door_reached:
		wall_slide(delta)
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
			animated_sprite.modulate = Color(1, 1, 1)
			HAS_WALL_JUMPED = false
			
			if was_in_air == true:
				land()
				
			was_in_air = false
			
		#if Input.is_action_just_pressed("hit"):	
			#$Attack_hitbox.process_mode = Node.PROCESS_MODE_INHERIT
			#attack()
			##await get_tree().create_timer(0.5).timeout
			#$hit_cooldown.start()
			#$Attack_hitbox.process_mode = Node.PROCESS_MODE_DISABLED
			
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
			
		if Input.is_action_just_pressed("dash") and can_dash:
			dash()
			
			#if is_wet:
				#$wet_damage.process_mode = Node.PROCESS_MODE_INHERIT
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
					animated_sprite.modulate = Color(0.581, 0.581, 0.581)
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		direction = Input.get_vector("left", "right", "up", "down")
		if !direction.x == 0 and !is_dashing:
			facing.x = round(direction.x)
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
			cshape.position.y = -13
			cshape.shape = crouching_cshape
			if slide_sound_is_playing == false:
				slide_sound_is_playing = true
				slide_audio.play()
				
			
		move_and_slide()
		update_animation()
		update_facing_direction()
		
		if is_wet:
			$wet_damage.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			$wet_damage.process_mode = Node.PROCESS_MODE_DISABLED
		
		if in_water:
			cshape.shape = crouching_cshape
			animated_sprite.play("swim")
			jump_c_shape.disabled = true
			animated_sprite.modulate = Color(0.529, 1, 1)
		elif !in_water and !HAS_DOUBLE_JUMPED:
				animated_sprite.modulate = Color(1, 1, 1)
		elif !in_water and HAS_DOUBLE_JUMPED:
				animated_sprite.modulate = Color(0.581, 0.581, 0.581)
	else:
		animated_sprite.play("idle")

func update_animation():
	if not animation_locked:
		if direction.x != 0:
			if cshape.shape != crouching_cshape:
				animated_sprite.play("run")

			else:
				animated_sprite.play("slide")
		else:
			if !is_dashing and cshape.shape != crouching_cshape:
				if is_on_floor():
					animated_sprite.play("idle")
				else:
					animated_sprite.play("mid air")
			else:
				animated_sprite.play("slide")
			
func update_facing_direction():
	if !is_dashing:
		if !is_wall_sliding:
			if direction.x > 0:
				animated_sprite.flip_h = true
			elif direction.x < 0:
				animated_sprite.flip_h = false
		#else:
			#if direction.x > 0:
				#animated_sprite.flip_h = false
			#elif direction.x < 0:
				#animated_sprite.flip_h = true
	
		emit_signal("facing_direction_changed", !animated_sprite.flip_h)
	if wall_raycast_left.is_colliding() and is_wall_sliding:
		animated_sprite.flip_h = true
	elif wall_raycast_right.is_colliding() and is_wall_sliding:
		animated_sprite.flip_h = false

func attack():
	animated_sprite.play("attack")
	animation_locked = true
	
func jump():
	velocity.y = JUMP_VELOCITY
	jump_audio.play()
	animated_sprite.play("jump")
	animation_locked = true
	await get_tree().create_timer(0.2).timeout
	if is_crouching:return
	jump_c_shape.disabled = false

func double_jump():
	velocity.y = DOUBLE_JUMP_VELOCITY
	jump_audio.play()
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
	double_jump_audio.play()
	jump_c_shape.disabled = false
	animation_locked = true
	HAS_WALL_JUMPED = true
	#print("jumped")
	
func wall_slide(delta):
	jump_c_shape.disabled = true
	if !is_on_floor() and (wall_raycast_right.is_colliding() or wall_raycast_left.is_colliding()):
		if is_on_wall():	
			animated_sprite.play("wall slide")
			is_wall_sliding = true
			animation_locked = true
			
		#if direction.x > 0 or direction.x < 0:
			
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
	animated_sprite.play("jump")
	animation_locked = true
	
func dash():
	is_dashing = true
	if !is_crouching:
		animated_sprite.play("dash")
		animation_locked = true
	can_dash = false

func land():
	animated_sprite.play("jump end")
	land_audio.play()
	jump_c_shape.disabled = true
	animation_locked = true

#func slide():
	#if is_dashing:
		#is_crouching = true
		#cshape.shape = crouching_cshape
		#print("changed shape")
		#cshape.position.y = -25
		#print("changed shape")

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
	cshape.position.y = -23
	
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
	#$wet_damage.process_mode = Node.PROCESS_MODE_DISABLED
	
func _on_dash_cooldown_timeout():
	is_bursting = false
	can_dash = true

func _on_area_2d_body_entered(_body):
	animated_sprite.play("swim")
	ACCELERATION = 600
	gravity = 100
	in_water = true
	is_wet = true
	animation_locked = true

func _on_area_2d_body_exited(_body):
	ACCELERATION = 500
	gravity = 480
	in_water = false
	cshape.set_deferred("shape", standing_cshape)
	$wet_timer.start()
	if is_dashing:
		is_bursting = true
	animation_locked = false

func _on_wet_timer_timeout():
	if !in_water:
		is_wet = false

func _on_hit_cooldown_timeout():
	$Attack_hitbox.process_mode = Node.PROCESS_MODE_DISABLED


func _on_slide_audio_finished():
	slide_sound_is_playing = false
	


func _on_hitbox_hurt():
	animation_player.play("hurt")
func _on_hitbox_recovered():
	animation_player.stop()
