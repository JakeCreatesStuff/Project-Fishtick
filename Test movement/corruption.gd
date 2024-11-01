extends Area2D

signal cleaned()

var  corruption = Global.corruption_amount

func _on_body_entered(body):
	hit()

func hit():
	Global.corruption_amount -= 1
	queue_free()
	print (Global.corruption_amount)
	#print("HIT")

#var clean = false


func _on_cleanable_cleaned():
	cleaned.emit()
