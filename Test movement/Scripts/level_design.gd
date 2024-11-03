extends Node2D

@onready var trident = $Trident
@onready var bgm = $BGM
@onready var start_game = $Trident/ColorRect2/StartGame


#func _ready():
	#start_game.play_backwards("Start")

func _on_corruptions_cleaned():
	trident.clean()
	#print("clean")


func _on_bgm_finished():
	bgm.play()
