extends Label

@onready var a = $A
@onready var s = $S
@onready var d = $D


func _process(_delta):
	if Input.is_action_pressed("up"):
		self_modulate = Color(0.256, 0.289, 0.485)
	else:
		self_modulate = Color(1, 1, 1)

	if Input.is_action_pressed("down"):
		s.self_modulate = Color(0.256, 0.289, 0.485)
	else:
		s.self_modulate = Color(1, 1, 1)

	if Input.is_action_pressed("left"):
		a.self_modulate = Color(0.256, 0.289, 0.485)
	else:
		a.self_modulate = Color(1, 1, 1)

	if Input.is_action_pressed("right"):
		d.self_modulate = Color(0.256, 0.289, 0.485)
	else:
		d.self_modulate = Color(1, 1, 1)
