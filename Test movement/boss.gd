extends CharacterBody2D

@onready var projectile = load("res://projectile.tscn")
@onready var BOSS = get_tree().get_root().get_node("BOSS")

var speed = 10
var player = null
var player_chase = false

var player_pos
var target_pos

func _ready():
	shoot()

func _physics_process(delta):
	if player_chase:
		if position.y >= 168:
			position.y += (player.position.y - position.y - 100) / speed
			
func _on_area_2d_body_entered(body):
	player_chase = true
	player = body
	print("FOUND YOU")
	print(player)
	
func shoot():
	var instance =  projectile.instantiate()
	instance.dir = rotation
	instance.spawnPos = global_position
	instance.spawnRot = rotation
	BOSS.add_child.call_deferred(instance)
