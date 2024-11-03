extends Node
class_name Cleanable

@onready var corruption = Global.corruption_amount

signal cleaned()

func hit():
	corruption -= 1
	get_parent().queue_free()
	#print("HIT")
