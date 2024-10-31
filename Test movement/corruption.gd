extends CharacterBody2D
#var clean = false

func _physics_process(delta):
	return

func hit():
	$Cleanable.hit()
