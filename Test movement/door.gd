extends Area2D
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

func _on_body_entered(body):
	animated_sprite.play("Close")
	print("da door")


func _on_body_exited(body):
	animated_sprite.play("Open")
	print("bye door :(")
