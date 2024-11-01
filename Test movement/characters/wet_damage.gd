extends Area2D

func _on_body_entered(body):
	#print(body.name)
	for child in body.get_children():
		if child is Cleanable:
			#print(body.name)
			child.hit()
	
	if body.name == "BOSS" and Global.boss_damaged == false:
		print("OWWWCH")
		Global.boss_damaged = true
		Global.Boss_Health = Global.Boss_Health - 1
		print(Global.Boss_Health)
