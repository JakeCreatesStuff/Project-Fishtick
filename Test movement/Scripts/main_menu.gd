extends Control

signal start_game()



func _on_start_button_pressed():
	start_game.emit()
	hide()
