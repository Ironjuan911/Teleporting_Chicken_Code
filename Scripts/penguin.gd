extends CharacterBody2D
class_name Penguin

@export var right_flip = true
@export var speed = 3

@onready var animation = $AnimationPlayer
@onready var animationflip = $Animationflip
@onready var sprite = $Sprite2D
@onready var timer_flip = $TimerFlip
@onready var detect_player = $DetectPlayer

@onready var ray_cast_front = $RayCast_front
@onready var ray_cast_floor = $RayCast_floor

@onready var step_1: AudioStreamPlayer2D = $"Sound step 1"
@onready var step_2: AudioStreamPlayer2D = $"Sound step 2"
@onready var step_3: AudioStreamPlayer2D = $"Sound step 3"

var jump = 20
var meter = 8
var gravity = 3.75
var can_flip = true

func _ready(): #Apenas apareco
	animation.play("RESET")
	#print(randi() % 5 - 2 )
	animation.speed_scale = speed
	
	
func _physics_process(delta): #a cada rato
	movement_x()
	movement_y()
	detection_raycast()
	
func movement_y():
	"""Gravedad"""
	velocity.y = velocity.y + gravity*meter
	
func movement_x():
	
	if right_flip == true:
		velocity.x = speed*meter
		animationflip.play("right_flip")
		animation.play("Walk")
	else:
		velocity.x = -speed*meter
		animationflip.play("left_flip")
		animation.play("Walk")
	
	move_and_slide()

func detection_raycast():
	if (not ray_cast_floor.is_colliding() or ray_cast_front.is_colliding()) and can_flip == true:
		timer_flip.start()
		can_flip = false
		right_flip = !right_flip

func _on_timer_flip_timeout():
	can_flip = true

func _on_detect_player_body_entered(body):
	if body.has_method("damage") and body is Player:
		body.damage()

func steps():
	var random_number_step = randi() % 3 + 1 # numero aleatorio entre 1 hasta 3 
	if random_number_step == 1:
		step_1.playing = true
	elif random_number_step == 2:
		step_2.playing = true
	else:
		step_3.playing = true
