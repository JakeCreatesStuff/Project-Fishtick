extends Area2D
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	top_level = false

func _on_body_entered(body):
	Global.door_reached = true
	animated_sprite.play("Open")
	await get_tree().create_timer(2).timeout
	top_level = true
	animated_sprite.play("Close")
	print("da door")
	await get_tree().create_timer(1).timeout
	Global.door_reached = false
	get_tree().change_scene_to_file("res://boss_room.tscn")


#func _on_body_exited(body):
	#animated_sprite.play("Open")
	#print("bye door :(")
