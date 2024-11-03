extends Label

var displayed = false

@onready var animation_player = $AnimationPlayer

func _on_area_2d_body_entered(_body):
	if displayed == false:
		displayed = true
		animation_player.play("Appear")
