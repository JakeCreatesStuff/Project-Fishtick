extends Label

var appeared = false
var burst_through = false
var timer_started = false
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer

func _input(event):
	if event.is_action_pressed("dash") and ("up"):
		if appeared == true:
			self_modulate = Color(0.296, 0.512, 0.628)
	else:
		if appeared == true:
			self_modulate = Color(1, 1, 1)

func _on_start_timer_body_entered(body):
	if body is Player and burst_through == false and timer_started == false:
		timer_started = true
		timer.start()


func _on_timer_timeout():
	animation_player.play("appear")
	appeared = true


func _on_stop_timer_body_entered(body):
	if body is Player:
		burst_through = true
		timer.stop()
