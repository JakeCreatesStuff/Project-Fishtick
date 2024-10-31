extends CharacterBody2D

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
#var spawnPos : Vector2
#var spawnRot : float

func _ready():
	pass
	#global_position = spawnPos
	#global_rotation = spawnRot

func _physics_process(delta):
	#velocity = Vector2(0, -SPEED).rotated(dir)
	animated_sprite.play("spin")
	#move_and_slide()
