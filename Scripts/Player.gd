extends CharacterBody2D
class_name Player

@export var flip_right = true
@export var total_avaidable_dash = 1

@onready var sprite = $Sprite2D
@onready var animation = $AnimationPlayer
@onready var animation_flip = $AnimationFlip
@onready var timerjump = $"Timerjump"
@onready var timerspeed = $TimerSpeed
@onready var dashtimer = $DashTimer
@onready var bouncetimer = $BounceTimer
@onready var timerfliquer = $Timerfliquer
@onready var dash_animation_timer = $DashAnimationTimer
@onready var timer_dead = $TimerDead

@onready var raycastup_1 = $RaycastUp/RayCast1
@onready var raycastup_2 = $RaycastUp/RayCast2
@onready var raycastup_3 = $RaycastUp/RayCast3
@onready var frontraycast = $FrontRaycast

@onready var step_1 = $"Sound step 1"
@onready var step_2 = $"Sound step 2"
@onready var step_3 = $"Sound step 3"
@onready var sound_jump = $"Sound Jump"
@onready var sound_dash = $"Sound dash"

@onready var dash_particles = $"Dash particles"
@onready var mini_particles = $"Mini Particles"

@onready var dash_animation_data = preload("res://Scenes/Player/dash.tscn")
@onready var dash_animation = dash_animation_data.instantiate()

var gravity = 3.75
var mini_speed = 3
var max_speed = 15
var speed = 0 # Es la velocidad total del jugador (la cual es resultado de la velocidad minima y maxima)
var dash_speed = max_speed*1.7
var avaidable_dash = 0
var jump = 20
var jumping #si es verdadera, significa que el jugador esta saltando
var meter = 8.0
var rozamiento = 0.4
var joystick_dead_range = 0.25
var jump_bounce = false #Define si el salto realisado por el jugador es causado por una resortera
var animation_bounce = false
var fliquer = false #El parpadeo
var can_change_scene = false #Indica si el jugador al morir, ya se puede cambiar de escena
var dead_process = false #Indica si el jugador esta en proceso de muerte

var block_jump = false #Se encarga de que no se pueda spam al salto
var block_for_dash = false
var force_dash = false #Se encarga de forzar el dash al jugador
var can_jump = true
var can_walk = true
var can_player_movement = true
var blend = false #Si el jugador esta agachado o no
var switch_timer #Olvide que hace esto
var direction_x = 0
var direction_y = 0
var dash_direction_x
var dash_direction_y
var random_number_step
var delta_x

func _ready():
	set_right_flip(flip_right)

func _physics_process(delta):
	
	if Input.is_action_pressed("ui_test"):
		force_dash_mode()
	
	if is_on_floor() or not (direction_x == 0 and block_for_dash == false):
		jump_bounce = false
	delta_x = delta*58.86
	
	if can_player_movement == true: #Basicamente, si es falso el jugador no podra mover el personaje
		movement_in_y()
		movement_in_x()
		dash_control()
		jump_control()
		flip_and_blend_player()
		fall_and_jump_animations()
		raycast_detection()
	
	if dead_process == true:
		damage()

func gravity_movement():
	if velocity.y < 400: #Gravedad con una velocidad maxima de 300t
		if block_for_dash == false:
			velocity.y = velocity.y + gravity*meter*delta_x
	else:
		velocity.y = 399

func movement_in_y():
	gravity_movement()
	
	if Input.is_action_pressed("ui_jump") and can_jump == true and block_jump == false and block_for_dash == false: #Jump
		velocity.y = -jump*meter*delta_x
		jumping = true
	else:
		jumping = false
	
	#Bloqueo de spam para los saltos
	if Input.is_action_pressed("ui_jump") and not is_on_floor() and can_jump == false: #Spam en el suelo
		block_jump = true
	if not Input.is_action_pressed("ui_jump") and is_on_floor():
		block_jump = false
	
	if Input.is_action_just_released("ui_jump"): #Spam en el aire
		block_jump = true
	
	if jumping == false and not is_on_floor(): #saltar al momento de caer en el aire
		block_jump = true
	
	#await get_tree().create_timer(0.1).timeout


func movement_in_x():
	direction_x = Input.get_axis("ui_left" ,"ui_right")
	direction_y = Input.get_axis("ui_down" ,"ui_up")
	if direction_x == 0:
		speed = mini_speed
		timerspeed.start()
	
	if ((-joystick_dead_range > direction_x) or (direction_x > joystick_dead_range)) and can_walk == true and block_for_dash == false: #Walk
		if not direction_y <= -joystick_dead_range:#Que si se agacha el jugador, este derrape
			velocity.x = speed*meter*direction_x*delta_x
		else:
			velocity.x = lerp(velocity.x, 0.0, 0.05)
		if is_on_floor():
			animation.play("Walk")
		
	else:
		velocity.x = lerp(velocity.x , 0.0, rozamiento)
		if not direction_y < 0 and block_for_dash == false:
			set_right_flip(flip_right)
			if fliquer == true:
				animation.play("fliquer")
			else:
				animation.play("Idle")

func force_dash_mode():
	if velocity.x > 0:
		dash_direction_x = 1
	elif velocity.x < 0:
		dash_direction_x = -1
	else:
		dash_direction_x = 0
	
	if velocity.y < 0:
		dash_direction_y = 1
	elif velocity.y > 0:
		dash_direction_y = -1
	else:
		dash_direction_y = 0
	
	

func dash_control():
	if Input.is_action_just_pressed("ui_dash")  and (avaidable_dash > 0 or avaidable_dash < 0):
		avaidable_dash = avaidable_dash - 1
		dash_sound()
		if direction_x == 0 and direction_y == 0: #hacer dash si el jugador no presiona ninguna direccion
			
			if flip_right == true:
				dash_direction_x = 1
			else:
				dash_direction_x = -1
			
		else:
			dash_direction_x = round(direction_x)
		dash_direction_y = round(direction_y)
		velocity.y = 0
		dashtimer.start()
		animation.play("Fall")
		block_for_dash = true
		dash_particles.restart()
	
	if block_for_dash == true:
		dash_movement()

	if is_on_floor() and not Input.is_action_pressed("ui_dash"):
		if total_avaidable_dash > avaidable_dash:
			avaidable_dash = total_avaidable_dash
		elif total_avaidable_dash == -1:
			avaidable_dash = total_avaidable_dash
	
	move_and_slide()

func dash_movement(): #El desplazamiento del dash
	if dash_direction_y == 0:
		velocity.x = dash_speed*meter*dash_direction_x*1.3*delta_x
	else:
		velocity.x = dash_speed*meter*dash_direction_x*delta_x
	if dash_direction_x == 0:
		velocity.y = -dash_speed*meter*dash_direction_y*1.3*delta_x
	else:
		velocity.y = -dash_speed*meter*dash_direction_y*delta_x
	
	

func flip_and_blend_player():
	if direction_x > joystick_dead_range: #flip
		animation_flip.play("Right_Flip")
		flip_right = true
	elif direction_x < -joystick_dead_range:
		animation_flip.play("Left_Flip")
		flip_right = false
	
	if direction_y < -joystick_dead_range and not((-joystick_dead_range > direction_x) and (direction_x > joystick_dead_range)) and not Input.is_action_pressed("ui_jump"):#bend
		animation.active = false
		if flip_right == true:
			if blend == false:
				animation_flip.play("Bend_right")
				blend = true
		else:
			if blend == false:
				animation_flip.play("Bend_left")
				blend = true
	else:
		blend = false
		set_right_flip(flip_right)
		animation.active = true
	
func jump_control():
	if not is_on_floor():
		if switch_timer == false:
			switch_timer = true
			timerjump.start()
	if is_on_floor():
		switch_timer = false
		can_jump = true
	
func fall_and_jump_animations():
	if not is_on_floor() and can_jump == true:
		animation.play("Jump")
	if can_jump == false:
		animation.play("Fall")
	
func raycast_detection():
	
	if raycastup_1.is_colliding() and not raycastup_3.is_colliding():
		position.x = lerp(position.x, position.x + 3, 0.7)
		
	if raycastup_2.is_colliding() and not raycastup_3.is_colliding():
		position.x = lerp(position.x, position.x - 3, 0.7)
	
	if raycastup_3.is_colliding():
		can_jump = false
		
	if frontraycast.is_colliding():
		if is_on_floor():
			can_walk = false
	else:
		can_walk = true


"""End func physics process"""

func jump_slinghot(power, can_bounce):
	if can_bounce == true:
		avaidable_dash = total_avaidable_dash
		velocity.y = -jump*meter*power*1.2
		jump_bounce = true
		move_and_slide()
	else:
		bouncetimer.start()
		dash_animation_timer.wait_time = 0.03
		await get_tree().create_timer(0.01).timeout
		animation_bounce = true
		

func set_right_flip(flip):
	if flip == true:
		animation_flip.play("Right_Flip")
	else:
		animation_flip.play("Left_Flip")
		
func damage():
	if dead_process == false:
		velocity.y = -jump*1.5*meter*delta_x
		animation_flip.play("RESET")
		set_right_flip(flip_right)
		block_for_dash = false
		can_player_movement = false
		dead_process = true
	gravity_movement()
	animation.active = true
	animation.play("Dead")
	if not is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, 0.05)
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		
	if velocity.y < 0 and not is_on_floor(): #Es el timer encargado de establecer un tiempo minimo limite antes de que se pueda cambiar de escena
		timer_dead.start() #can_change_scene = true
		
		
	if abs(velocity.x) < 0.1 and velocity.y > 0 and can_change_scene == true: #Que cuando el jugador deje de moverse, la escena se resetee
		can_change_scene = false
		GameManajer.set_world()

		
	move_and_slide()

func _on_timerjump_timeout(): #Jump control
	can_jump = false

func _on_timer_speed_timeout(): #Timer max speed
	speed = max_speed

func _on_dash_timer_timeout(): #Timer dash duration
	block_for_dash = false

func _on_dash_animation_timer_timeout(): # timer que genera la animacion de dash
	if block_for_dash == true or animation_bounce == true:
		add_sibling(dash_animation)
		dash_animation.position = $".".position
		dash_animation.flip_sprite(flip_right)
		dash_animation = dash_animation_data.instantiate()

func _on_bounce_timer_timeout():
	dash_animation_timer.wait_time = 0.05
	animation_bounce = false

func _on_timerfliquer_timeout():
	fliquer = true
	await get_tree().create_timer(0.3).timeout
	fliquer = false
	
func steps():
	random_number_step = randi() % 3 + 1 # numero aleatorio entre 1 hasta 3 
	if random_number_step == 1:
		step_1.playing = true
	elif random_number_step == 2:
		step_2.playing = true
	else:
		step_3.playing = true

func jump_sound():
	if Input.is_action_just_pressed("ui_jump") and block_jump == false:
		sound_jump.playing = true

func dash_sound():
	sound_dash.play()
	
func end_animation(start):
	if start == true:
		dash_particles.restart()
		mini_particles.restart()
		animation.play("Disappear")

func disappear():
	mini_particles.emitting = false

func _on_timer_dead_timeout():
	can_change_scene = true
