extends CharacterBody2D

const projectile = preload("res://projectile.tscn")

var startBattle = false
@onready var BOSS = %BOSS
#@onready var BOSS = get_tree().get_root().get_node("BOSS")
@onready var ShootCooldown = $ShootCooldown
@onready var DamagedCooldown = $DamagedCooldown
@onready var ball_audio = $"../BallAudio"
@onready var animation_player = $AnimationPlayer
@onready var boss_dmg_audio = $BossDmgAudio

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
		animation_player.play("hurt")
		boss_dmg_audio.play()
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
	if Global.died or Global.win: return
	if canShoot and startBattle and Global.boss_damaged == false:
		canShoot = false
		ShootCooldown.start()
		
		var projectileNode = projectile.instantiate()
		
		projectileNode.set_direction(shotAngleDeg)
		get_tree().root.add_child(projectileNode)
		projectileNode.global_position = position
		ball_audio.play()

func _on_area_2d_body_entered(body):
	player_chase = true
	player = body
	#print("FOUND YOU")
	#print(player)

func _on_shoot_cooldown_timeout():
	canShoot = true
	
func setup_direction(direction):
	projDirection = direction


func _on_damaged_cooldown_timeout():
	Global.boss_damaged = false
	animation_player.stop()
	hurt = false
	animation_player.stop()
	#print("I'm coming back")


func _on_start_timer_timeout():
	startBattle = true

func hurtEffect():
	animation_player.play("hurt")
	boss_dmg_audio.play()
