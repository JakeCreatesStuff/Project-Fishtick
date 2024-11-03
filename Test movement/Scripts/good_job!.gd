extends Label

var good_job = false
@onready var arrow = $Arrow

func _on_area_2d_body_entered(body):
	if body is Player and good_job == false:
		good_job = true
		show()
		await get_tree().create_timer(1.0).timeout
		arrow.show()
