extends CharacterBody2D

const projectile = preload("res://projectile.tscn")
@onready var BOSS = get_tree().get_root().get_node("BOSS")
@onready var ShootCooldown = $ShootCooldown
@onready var DamagedCooldown = $DamagedCooldown

@export var shootSpeed = 1.0

var speed = 200
var player = null
var player_chase = false
var friction = 800

var player_pos
var target_pos

var canShoot = true
var projDirection = 10
var hurt = false

var shotAngle:Vector2
var shotAngleDeg

func _ready():
	ShootCooldown.wait_time = 1.0

func _physics_process(delta):
	#if Input.is_action_just_pressed("hit"):	
		#ShootCooldown.wait_time = 0.25
	if Global.boss_damaged and !hurt:
		hurt = true
		DamagedCooldown.start()
		
	if player_chase:
		#position.y += (player.position.y - position.y - 100) / speed
		
		if !Global.boss_damaged:
			position.y = move_toward(position.y, player.position.y - 120, delta * speed)
			position.x = 250
		else:
			position.y = move_toward(position.y, 168, delta * speed / 2)
			position.x = 250
			
		shotAngle = position - player.position
		shotAngleDeg = atan2(-shotAngle.y, -shotAngle.x)
		shotAngleDeg = Vector2.from_angle(shotAngleDeg)
		#print(shotAngleDeg)
		shoot()
		move_and_slide()
		

func shoot():
	if canShoot:
		canShoot = false
		ShootCooldown.start()
		
		var projectileNode = projectile.instantiate()
		
		projectileNode.set_direction(shotAngleDeg)
		get_tree().root.add_child(projectileNode)
		projectileNode.global_position = position

func _on_area_2d_body_entered(body):
	player_chase = true
	player = body
	print("FOUND YOU")
	print(player)

func _on_shoot_cooldown_timeout():
	canShoot = true
	
func setup_direction(direction):
	projDirection = direction


func _on_damaged_cooldown_timeout():
	Global.boss_damaged = false
	hurt = false
	print("I'm coming back")
