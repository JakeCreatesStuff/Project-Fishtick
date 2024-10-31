extends Node

class_name Cleanable

func hit():
	Global.corruption_amount = Global.corruption_amount - 1
	get_parent().queue_free()
	#print("HIT")
