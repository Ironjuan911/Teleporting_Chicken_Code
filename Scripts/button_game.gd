extends Node2D
class_name Button_Game

enum button_list{
	Red,
	Blue,
	Green
}

@export var can_restart = false
@export var Button_type : button_list
var set_button_type

@onready var animation_player = $AnimationPlayer
@onready var timer_restart = $TimerRestart

var group_template = "_Buttons_Unpressed"
var group_selected


var pressed = false

func _ready():
	set_button_type = button_list.find_key(Button_type)
	animation_player.play("Un_pressed")
	group_selected = set_button_type + group_template
	add_to_group(group_selected)

func _on_area_2d_body_entered(body):
	if body is Player and pressed == false:
		animation_player.play("pressed")
		pressed = true
		remove_from_group(group_selected)
		
		if can_restart == true:
			timer_restart.start()
		
	pass # Replace with function body.

func restart():
	animation_player.play("Restart")
	add_to_group(group_selected)
	pressed = false

func _on_timer_restart_timeout():
	restart()
