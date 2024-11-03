extends Label

var displayed = false

@onready var slide_animation = $SlideAnimation

func _on_area_2d_body_entered(_body):
	if displayed == false:
		displayed = true
		slide_animation.play("Appear")

func _input(event):
	if event.is_action_pressed("dash") and ("down"):
		self_modulate = Color(0.296, 0.512, 0.628)
	else:
		self_modulate = Color(1, 1, 1)
