extends Node

class_name Cleanable

func hit():
	get_parent().queue_free()
	print("HIT")
