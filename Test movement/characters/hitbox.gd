extends Area2D

@export var player : Player

var can_be_damaged = true

func _on_area_entered(area):
	if can_be_damaged:
		#print(area.name)
		Global.hitpoints = Global.hitpoints - 1
		print(Global.hitpoints)
		can_be_damaged = false
		$damage_cooldown.start()
	
func _on_damage_cooldown_timeout():
	can_be_damaged = true
