extends Node2D

@onready var boss_bgm = $BossBGM
@onready var start_animation = $Node/StartAnimation
@onready var start = $Node/Start
@onready var win_animation = $WinAnimation
@onready var guide_animation = $Guide/GuideAnimation
@onready var guide_text = $Guide/CanvasLayer/GuideText
@onready var guide_timer = $Guide/GuideTimer
@onready var second_guide_timer = $Guide/SecondGuideTimer


var dialogue_pick
var bgm_off = false
var first_guide_given = false

func _ready():
	if Global.have_retried < 3:
		dialogue_pick = randi_range(1, 12)
	elif Global.have_retried == 3:
		dialogue_pick = 13
	elif Global.have_retried > 3:
		dialogue_pick = 14
	match dialogue_pick:
		1:
			start.text = "It ends here!"
		2:
			start.text = "You'll be swimming with the fishes!"
		3:
			start.text = "It's sink or swim, sharky!"
		4:
			start.text = "Say hi to the bottom of the ocean for me!"
		5:
			start.text = "Did lil sharky stray too far from home?"
		6:
			start.text = "You'll never see the surface again!"
		7:
			start.text = "Say hi to the bottom of the ocean for me!"
		8:
			start.text = "I'll turn you into fish food"
		9:
			start.text = "Hah, you're fin-ished"
		10:
			start.text = "You're in too deep little shark"
		11:
			start.text = "You won't know what hit you"
		12:
			start.text = "You'll sink deeper than Atlantis"
		12:
			start.text = "You'll sink deeper than Atlantis"
		13:
			start.text = "You again? Die already!"
		14:
			start.text = "Cmon man how many times are we gonna do this"
			

	start_animation.play("entering")
	await get_tree().create_timer(5.0).timeout
	start_animation.play_backwards("entering")

func _process(_delta):
	if Global.win == true and bgm_off == false:
		bgm_off = true
		win_animation.play("winAudio")
	if Global.boss_damaged == true:
		Global.tutorial_not_needed = true
	if Global.tutorial_not_needed == true:
		guide_timer.stop()

func _on_trident_win():
	pass


func _on_boss_bgm_finished():
	boss_bgm.play()


func _on_guide_timer_timeout():
	guide_text.text = "Strike her with the force of the ocean..."
	guide_animation.play("Hint")
	$Guide/SecondGuideTimer.start()


func _on_second_guide_timer_timeout():
	guide_text.text = "... Shift + Up to her..."
	guide_animation.play("Hint")
