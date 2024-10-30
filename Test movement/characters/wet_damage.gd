extends Area2D

func _on_body_entered(body):
	print(body.name)
	for child in body.get_children():
		if child is Cleanable:
			print(body.name)
			child.hit()
