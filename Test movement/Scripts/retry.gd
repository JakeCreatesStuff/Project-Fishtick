extends Control

var retry_ready = false

@onready var animation_player = $AnimationPlayer
@onready var fauna_animation = $Fauna/FaunaAnimation
@onready var water_animation = $Water/WaterAnimation

func retry_screen_appear():
	animation_player.play("Appear")
	await animation_player.animation_finished
	fauna_animation.play("Hover")
	water_animation.play("Expansion")
	retry_ready = true

func _on_texture_button_mouse_entered():
	if retry_ready == true:
		animation_player.play("MouseIn")

func _on_texture_button_mouse_exited():
	if retry_ready == true:
		animation_player.play_backwards("MouseIn")

func _on_texture_button_pressed():
	if retry_ready == true:
		animation_player.play("Retry")
		$Label.text = "YES!!"
		retry_ready = false
		
		get_tree().change_scene_to_file("res://Scenes/respawn_level.tscn")
		Global.corruption_amount = Global.corruption_save
		Global.hitpoints = 3
