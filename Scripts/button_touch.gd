extends Control

@export var Input_received := "ui_jump"
@onready var animation = $AnimationPlayer
@onready var touch_button = $TouchScreenButton

var pressed = false

func _ready():
	touch_button.action = Input_received
	animation.play("RESET")

func _input(event):
	if pressed == true:
		animation.play("pressed")
	else:
		animation.play("RESET")

func _on_touch_screen_button_pressed():
	pressed = true

func _on_touch_screen_button_released():
	pressed = false
	

