extends Area2D

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

var speed = 150

var direction:Vector2

func _ready():
	await get_tree().create_timer(3).timeout
	queue_free()
	print("delete")

func set_direction(projDirection):
	direction = projDirection
	print(projDirection)
	#rotation_degrees = rad_to_deg(global_position.angle_to_point(global_position+direction))

func _physics_process(delta):
	global_position += direction * speed * delta
	animated_sprite.play("spin")

func _on_body_entered(body):
	pass
