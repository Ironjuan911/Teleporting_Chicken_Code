extends Node2D
class_name Set_limit_camera

@export var available_transition = false
@export var set_cape = 1
@export var set_movement_x = true
@export var set_movement_y = true

@onready var ray_cast_up: RayCast2D = $RayCastUp
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var timer_test: Timer = $TimerTest
@onready var timer_process: Timer = $TimerProcess
@onready var timer_exit: Timer = $TimerExit
@onready var timer_dash_player: Timer = $TimerDashPlayer

var camera
var base_movement_x
var base_movement_y
var base_cape
var player

var general_process = false
var process_up = false
var process_down = false
var transition_player = false #Indica si el jugador esta transpasando el limite
var procces_transition = false #Indica si la transicion del jugador esta en proceso

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	for node in get_tree().get_nodes_in_group("Camera"):
		camera = node
		break
	for node in get_tree().get_nodes_in_group("Player"):
		player = node
		break

func _physics_process(delta: float) -> void:
	if procces_transition == true and available_transition == true:
		set_transition_player()

		
	"""Up"""
	if ray_cast_down.is_colliding() and process_down == false and general_process == false:
		general_process = true
		process_up = true
		timer_test.start()
		timer_process.start()
	#if ray_cast_up.is_colliding() and ray_cast_down.is_colliding(): #Seguridad
		#general_process = false
	if ray_cast_up.is_colliding() and process_up == true:
		process_up = false
		change_data_camera(true)

	"""Down"""
	if ray_cast_up.is_colliding() and process_up == false and general_process == false:
		general_process = true
		process_down = true
		timer_test.start()
		timer_process.start()
	#if ray_cast_up.is_colliding() and ray_cast_down.is_colliding(): #Seguridad
		#general_process = false
	if ray_cast_down.is_colliding() and process_down == true:
		process_down = false
		change_data_camera(false)

func set_transition_player():
	if transition_player == true:
		player.force_dash_mode()
		player.block_for_dash = true
	else:
		player.block_for_dash = false

func change_data_camera(state):
	if state == true:
		if not base_cape:
			base_cape = camera.cape 
		if not base_movement_x:
			base_movement_x = camera.movement_x
		if not base_movement_y:
			base_movement_y = camera.movement_y
		camera.movement_x = set_movement_x
		camera.movement_y = set_movement_y
		camera.cape = set_cape
		camera.set_limits(camera.cape)
	else:
		camera.movement_x = base_movement_x
		camera.movement_y = base_movement_y
		camera.cape = base_cape
		camera.set_limits(camera.cape)


func _on_timer_test_timeout() -> void:
	process_up = false
	process_down = false

func _on_timer_process_timeout() -> void:
	general_process = false


func _on_timer_dash_player_timeout() -> void:
	transition_player = false
	await get_tree().process_frame
	procces_transition = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	transition_player = true
	procces_transition = true
	timer_dash_player.start()
