extends Node

signal cleaned()

func _on_corruption_cleaned():
	cleaned.emit()
