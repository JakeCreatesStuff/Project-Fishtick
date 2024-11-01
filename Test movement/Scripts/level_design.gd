extends Node2D

@onready var trident = $Trident


func _on_corruptions_cleaned():
	trident.clean()
	print("clean")
