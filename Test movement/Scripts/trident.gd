extends CanvasLayer

signal WIN()

var start_cleaning = false # for debug purpose
var index = 0
@onready var corruption = Global.corruption_amount
var hp = 3
var win_state = false
var lose_state = false

var hit_0 = false
var hit_1 = false
var hit_2 = false
var hit_3 = false
var dead = false

@onready var trident = $TridentSprite
@onready var tip_1 = $TridentSprite/Tip_1
@onready var tip_2 = $TridentSprite/Tip_2
@onready var tip_3 = $TridentSprite/Tip_3

@onready var ball_3 = $TridentSprite/Ball/Ball_3
@onready var ball_2 = $TridentSprite/Ball/Ball_2
@onready var ball_1 = $TridentSprite/Ball/Ball_1

@onready var tendril_1 = $TridentSprite/Tendril/Tendril_1
@onready var tendril_2 = $TridentSprite/Tendril/Tendril_2
@onready var tendril_3 = $TridentSprite/Tendril/Tendril_3
@onready var tendril_4 = $TridentSprite/Tendril/Tendril_4
@onready var tendril_5 = $TridentSprite/Tendril/Tendril_5
@onready var tendril_6 = $TridentSprite/Tendril/Tendril_6
@onready var tendril_7 = $TridentSprite/Tendril/Tendril_7



@onready var glass_audio = $Audio/GlassBreakingAudio
@onready var death_audio = $Audio/DeathAudio
@onready var heart_beat_audio = $Audio/HeartBeatAudio
@onready var win_audio = $Audio/WinAudio
@onready var fan_fare_audio = $Audio/FanFareAudio

@onready var animation = $AnimationPlayer
@onready var win_screen_animation = $Win/WinScreen/WinScreen_Animation
@onready var counter = $Counter


func _process(_delta):
	#if start_cleaning == true:
		#clean()
	clean()
	hp_update()

func clean():
	#if corruption > 0:
		#corruption -= 1
	#elif win_state == false:
		#win_state = true
		#win()

	if Global.corruption_amount > 120:
		cleaning_1()
	elif Global.corruption_amount > 100:
		cleaning_2()
	elif Global.corruption_amount > 80:
		cleaning_3()
	elif Global.corruption_amount > 60:
		cleaning_4()
	elif Global.corruption_amount > 40:
		cleaning_5()
	elif Global.corruption_amount > 20:
		cleaning_6()
	elif Global.corruption_amount > 0:
		cleaning_7()
	elif Global.corruption_amount < 0 and win_state == false:
		win_state = true
		end()

#func _input(event):
	#if event.is_action_pressed("clean"):
		#Global.corruption_amount -= 7
	#if event.is_action_pressed("hp"):
		#if hp > 0:
			#Global.hitpoints -= 1
			#hp_update()
		#else:
			#died()
	#if event.is_action_pressed("reset_hp"):
		#hp = 3
		#hp_update()

func hp_update():
	if Global.hitpoints == 3 and hit_0 == false:
		hit_0 = true
		tip_1.animation = "full"
		tip_2.animation = "full"
		tip_3.animation = "full"
	elif Global.hitpoints == 2 and hit_1 == false:
		hit_1 = true
		tip_1.play("breaking")
		tip_2.play("white")
		tip_3.play("white")
		trident.play("white")
		glass_audio.play()
		await tip_1. animation_finished
		tip_1.play("broke")
	elif Global.hitpoints == 1 and hit_2 == false:
		hit_2 = true
		tip_1.play("broke_white")
		tip_2.play("breaking")
		tip_3.play("white")
		trident.play("white")
		glass_audio.pitch_scale = 0.9
		glass_audio.play()
		await tip_2. animation_finished
		tip_1.play("broke")
		tip_2.play("broke")
	elif Global.hitpoints == 0 and hit_3 == false:
		hit_3 = true
		tip_1.play("broke_white")
		tip_2.play("broke_white")
		tip_3.play("breaking")
		trident.play("white")
		glass_audio.pitch_scale = 0.8
		glass_audio.play()
		await tip_3. animation_finished
		tip_1.play("broke")
		tip_2.play("broke")
		tip_3.play("broke")
	elif Global.hitpoints == -1 and dead == false:
		dead = true
		died()

func died():
	Global.died = true
	animation.play("dead")
	death_audio.play()
	ball_1.speed_scale = 4
	ball_2.speed_scale = 4
	ball_3.speed_scale = 4
	await get_tree().create_timer(1.0).timeout
	heart_beat_audio.play()
	animation.play("tendril_breathe")
	$Lose/Retry.show()
	$Lose/Retry.retry_screen_appear()

func win():
	WIN.emit()
	Global.win = true
	animation.play("win")
	await get_tree().create_timer(1).timeout
	win_screen_animation.play("blue_screen")
	await get_tree().create_timer(2).timeout
	ball_1.play("pop")
	await get_tree().create_timer(0.1).timeout
	win_audio.play()
	ball_2.play("pop")
	await get_tree().create_timer(0.1).timeout
	ball_3.play("pop")
	Global.hitpoints = 3
	tip_1.play("win")
	tip_2.play("win")
	tip_3.play("win")
	trident.play("win")
	await get_tree().create_timer(1).timeout
	counter.text = "You've fought " + str(Global.have_retried) + " times"
	animation.play("trident_fades_out")
	await animation.animation_finished
	animation.play("Gura")
	

func cleaning_1():
	tendril_1.frame = 129 - Global.corruption_amount

func cleaning_2():
	tendril_1.frame = 8
	tendril_2.frame = 121 - Global.corruption_amount

func cleaning_3():
	tendril_1.frame = 8
	tendril_2.frame = 20
	tendril_3.frame = 101 - Global.corruption_amount

func cleaning_4():
	tendril_1.frame = 8
	tendril_2.frame = 20
	tendril_3.frame = 20
	tendril_4.frame = 81 - Global.corruption_amount

func cleaning_5():
	tendril_1.frame = 8
	tendril_2.frame = 20
	tendril_3.frame = 20
	tendril_4.frame = 20
	tendril_5.frame = 61 - Global.corruption_amount

func cleaning_6():
	tendril_1.frame = 8
	tendril_2.frame = 20
	tendril_3.frame = 20
	tendril_4.frame = 20
	tendril_5.frame = 20
	tendril_6.frame = 41 - Global.corruption_amount

func cleaning_7():
	tendril_1.frame = 8
	tendril_2.frame = 20
	tendril_3.frame = 20
	tendril_4.frame = 20
	tendril_5.frame = 20
	tendril_6.frame = 20
	tendril_7.frame = 21 - Global.corruption_amount

func end():
	tendril_1.frame = 8
	tendril_2.frame = 20
	tendril_3.frame = 20
	tendril_4.frame = 20
	tendril_5.frame = 20
	tendril_6.frame = 20
	tendril_7.frame = 20
	win()
