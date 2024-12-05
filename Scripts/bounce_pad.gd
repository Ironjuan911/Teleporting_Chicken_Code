extends Node2D

@export var power_jump = 1

@onready var animation = $AnimationPlayer
@onready var timer_bounce = $Timerbounce
@onready var bounce_particles = $bounceparticles
@onready var sound_bounce = $SoundBounce

var bounce = false
var object_to_bounce


func _ready():
	animation.play("RESET")

func _on_area_2d_body_entered(body):
	if body.has_method("jump_slinghot"):
		sound_bounce.playing = true
		body.jump_slinghot(power_jump,false)
		object_to_bounce = body
		animation.play("RESET")
		animation.play("Bounce")
		timer_bounce.start()
		bounce_particles.restart()
		bounce = true
		
	else:
		animation.play("RESET")
		animation.play("Pressed")

func _physics_process(delta):
	if bounce == true:
		object_to_bounce.jump_slinghot(power_jump,true)
	if object_to_bounce:
		if object_to_bounce.has_method("raycast_detection"):
			if object_to_bounce.raycastup_3.is_colliding():
				bounce = false

func _on_timerbounce_timeout():
	bounce = false
