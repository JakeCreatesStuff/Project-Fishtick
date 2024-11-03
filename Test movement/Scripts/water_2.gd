extends Node

@onready var water_1 = $Water_1
@onready var water_2 = $Water_2
@onready var water_3 = $Water_3

func _on_area_2d_body_entered(body):
	if body is Player:
		water_1.play()

func _on_area_2d_body_exited(body):
	if body is Player:
		water_3.play()
