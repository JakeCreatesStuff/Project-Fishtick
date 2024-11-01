extends CanvasLayer


var start_cleaning = false # for debug purpose
var index = 0
var corruption = Global.corruption_amount
var hp = 3
var win_state = false
var lose_state = false



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



@onready var glass_audio = $GlassBreakingAudio
@onready var death_audio = $DeathAudio
@onready var heart_beat_audio = $HeartBeatAudio
@onready var win_audio = $WinAudio

@onready var animation = $AnimationPlayer
@onready var win_screen_animation = $WinScreen/WinScreen_Animation


func _process(delta):
	if start_cleaning == true:
		clean()

func clean():
		if corruption > 0:
			corruption -= 1
		elif win_state == false:
			win_state = true
			win()
			

		if corruption > 120:
			cleaning_1()
		elif corruption > 100:
			cleaning_2()
		elif corruption > 80:
			cleaning_3()
		elif corruption > 60:
			cleaning_4()
		elif corruption > 40:
			cleaning_5()
		elif corruption > 20:
			cleaning_6()
		elif corruption > 0:
			cleaning_7()


func _input(event):
	if event.is_action_pressed("clean"):
		start_cleaning = true
	if event.is_action_pressed("hp"):
		if hp > 0:
			hp -= 1
			hp_update()
		else:
			died()
	if event.is_action_pressed("reset_hp"):
		hp = 3
		hp_update()

func hp_update():
	if hp == 3:
		tip_1.animation = "full"
		tip_2.animation = "full"
		tip_3.animation = "full"
	elif hp == 2:
		tip_1.play("breaking")
		tip_2.play("white")
		tip_3.play("white")
		trident.play("white")
		glass_audio.play()
		await tip_1. animation_finished
		tip_1.play("broke")
	elif hp == 1:
		tip_1.play("broke_white")
		tip_2.play("breaking")
		tip_3.play("white")
		trident.play("white")
		glass_audio.pitch_scale = 0.9
		glass_audio.play()
		await tip_2. animation_finished
		tip_1.play("broke")
		tip_2.play("broke")
	elif hp == 0:
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

func died():
	animation.play("dead")
	death_audio.play()
	ball_1.speed_scale = 4
	ball_2.speed_scale = 4
	ball_3.speed_scale = 4
	await get_tree().create_timer(1.0).timeout
	heart_beat_audio.play()
	animation.play("tendril_breathe")
	$Retry.show()

func win():
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
	await get_tree().create_timer(1).timeout
	animation.play("trident_fades_out")

func cleaning_1():
	tendril_1.frame = 129 - corruption

func cleaning_2():
	tendril_2.frame = 121 - corruption

func cleaning_3():
	tendril_3.frame = 101 - corruption

func cleaning_4():
	tendril_4.frame = 81 - corruption

func cleaning_5():
	tendril_5.frame = 61 - corruption

func cleaning_6():
	tendril_6.frame = 41 - corruption

func cleaning_7():
	tendril_7.frame = 21 - corruption
