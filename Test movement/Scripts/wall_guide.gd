extends Label

var imbued = false

@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer

func _on_start_timer_area_body_entered(body):
	if body is Player and imbued == false:
		timer.start()

func _on_timer_timeout():
	animation_player.play("appear")

func _on_stop_timer_area_body_entered(body):
	if body is Player:
		imbued = true
		timer.stop()
