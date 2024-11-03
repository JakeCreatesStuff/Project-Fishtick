extends Control


@onready var audio_stream_player = $AudioStreamPlayer
@onready var start_game = $ColorRect/StartGame

func _on_start_button_pressed():
	start_game.emit()
	hide()


func _on_texture_button_pressed():
	audio_stream_player.play()
	start_game.play("Start")
	await start_game.animation_finished
	get_tree().change_scene_to_file("res://Scenes/level_design.tscn")
