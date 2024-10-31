extends CharacterBody2D

const projectile = preload("res://projectile.tscn")
@onready var BOSS = get_tree().get_root().get_node("BOSS")
@onready var ShootCooldown = $ShootCooldown

@export var shootSpeed = 1.0

var speed = 10
var player = null
var player_chase = false

var player_pos
var target_pos

var canShoot = true
var projDirection = 10

var shotAngle:Vector2
var shotAngleDeg

func _ready():
	ShootCooldown.wait_time = 0.25 / shootSpeed

func _physics_process(delta):
	if Input.is_action_just_pressed("hit"):	
		shoot()
	if player_chase:
		if position.y >= 168:
			position.y += (player.position.y - position.y - 100) / speed
			
		shotAngle = position - player.position
		shotAngleDeg = atan2(-shotAngle.y, -shotAngle.x)
		shotAngleDeg = Vector2.from_angle(shotAngleDeg)
		#print(shotAngleDeg)
		

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
