extends CharacterBody2D

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player = $AudioStreamPlayer
@onready var collision_shape_2d = $CollisionShape2D

func _on_area_2d_body_entered(body):
	if body is Player:
		if body.is_wet and body.is_dashing:
			hit()

func hit():
	animated_sprite.play("Break")
	collision_shape_2d.set_deferred("disabled", true)
	audio_stream_player.play()
	Global.corruption_amount -= 1
	await animated_sprite.animation_finished
	queue_free()
