extends Area2D

@export var player : Player

var can_be_damaged = true
signal hurt()
signal recovered()

func _on_area_entered(_area):
	if can_be_damaged and Global.win == false:
		#print(area.name)
		Global.hitpoints -= 1
		#print(Global.hitpoints)
		can_be_damaged = false
		hurt.emit()
		$damage_cooldown.start()
	
func _on_damage_cooldown_timeout():
	can_be_damaged = true
	recovered.emit()
