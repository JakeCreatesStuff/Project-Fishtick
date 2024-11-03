extends Area2D
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var door_open = $DoorOpen
@onready var door_closed = $DoorClosed

func _ready():
	top_level = false

func _on_body_entered(_body):
	Global.corruption_save = Global.corruption_amount
	Global.door_reached = true
	door_open.play()
	animated_sprite.play("Open")
	await get_tree().create_timer(2).timeout
	top_level = true
	animated_sprite.play("Close")
	await get_tree().create_timer(0.5).timeout
	door_closed.play()
	await get_tree().create_timer(1).timeout
	Global.door_reached = false
	get_tree().change_scene_to_file("res://boss_room.tscn")
