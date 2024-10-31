extends CanvasLayer

var corruption_index = 37

func _input(event):
	if event.is_action_pressed("clean"):
		corruption_index -= 1
