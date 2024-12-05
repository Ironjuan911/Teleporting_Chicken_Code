class_name UI
extends Control

@export var android_controls = false

@onready var timer_controls: Timer = $TouchControls/TimerControls
@onready var touch_controls = $TouchControls
@onready var mask_virtual_joystick: Control = $"TouchControls/Mask Virtual Joystick"
@onready var button_dash: Control = $"TouchControls/Button dash"
@onready var button_jump: Control = $"TouchControls/Button jump"

@onready var transition_texture = $TransitionScene/TransitionTexture
@onready var reference_point_a = $TransitionScene/ReferencePointA
@onready var reference_point_b = $TransitionScene/ReferencePointB

@onready var base_resolution = float(GameManajer.base_resolution)
@onready var real_resolution = float(GameManajer.real_resolution)
var check_real_resolution
var reference #Variable que se usa para indicar como referencia para que la rencision se dirija a esta
var start_transition = false #Indica si la transición ya a empezado
var transition_down = false #Indica si la transicion se dirije hacia arriba o hacia abajo

var check_android_buttons = 0
var total_check_android_buttons = 1 #indica el maximo de veses que se debe de presionar la pantalla para que los botones se activen


func _ready():
	check_real_resolution = float(GameManajer.real_resolution)
	call_scaleable_nodes()
	ready_position()

	


func android_buttons_mode(): #Funcion encargada de la visibilidad de los botones de android
	if android_controls == true:
		mask_virtual_joystick.working(true)
		touch_controls.visible = true
	else:
		mask_virtual_joystick.working(false)
		touch_controls.visible = false
		

func _input(event: InputEvent) -> void: #Comprobante de si, se intenta usar la pantalla si no se tiene teclado alguno
	if event is InputEventScreenTouch and event.is_pressed():
		timer_controls.start() #Basicamente, cada ves que se toca la pantalla tactil, se inicia un timer el cual es un intervalo de 1 segundo, el cual si se cumple la cuenta se reseteara
		check_android_buttons = check_android_buttons + 1 
		if check_android_buttons >= total_check_android_buttons: #Si se presiona 4 veses el touch sin que se active el timer, los botones de android apareseran
			android_controls = true
			GameData.game_settings["android_buttons"] = android_controls #Guarda la variable en ajustes
			GameData.save_settings()
			android_buttons_mode()
	
	if event.is_action_pressed("ui_disable_buttons"):
		android_controls = false
		GameData.game_settings["android_buttons"] = android_controls
		GameData.save_settings()
		android_buttons_mode()
	

func _physics_process(delta):
	if abs(transition_texture.position.y - reference_point_a.position.y) < 10:
		transition_texture.visible = false #Hacer que si la animacion no se ve, para evitar bugs visuales que la transicion en si se vuelva invisible
	else:
		transition_texture.visible = true
	
	#if Input.is_action_just_pressed("ui_up"):
		#transitión_active(false,true)
	#elif Input.is_action_just_pressed("ui_down"):
		#transitión_active(true,true)
	
	
	if start_transition == true:
		transitión_active(transition_down,true)
	
	real_resolution = float(GameManajer.real_resolution)
	if not check_real_resolution == real_resolution:
		call_scaleable_nodes()
		check_real_resolution = real_resolution

func call_scaleable_nodes():
	for node_called in get_tree().get_nodes_in_group("Scaleable_node"):
		scale_nodes(node_called)
		
func scale_nodes(node):
	if node.has_method("ready_scale_mode"):
		node.scale.x = (real_resolution*(node.ready_scale_x))/base_resolution
	else:
		node.scale.x = real_resolution/base_resolution
	node.scale.y = node.scale.x
	
"""Transición para escenas"""
func ready_position():
	transition_texture.position.y = reference_point_a.position.y
	
func transitión_active(valide,transition):
	transition_down = valide
	start_transition = true
	if valide == true:
		reference = reference_point_b #definir donde se destinara la transición
	else:
		reference = reference_point_a
	
	if transition == false: #Es forzar la posicion de la transicion, es para lograr un resultado inmediato sin el movimiento
		transition_texture.position.y = reference.position.y
	
	if abs(transition_texture.position.y - reference.position.y) > 1: #Es la transicion normal, mientras la transicion no se encuentre en su lugar, la misma se dirijira a esta
		transition_texture.position.y = lerp(transition_texture.position.y, reference.position.y, 0.2)
	else:
		start_transition = false


"""Fin transición"""


func _on_timer_controls_timeout() -> void:
	check_android_buttons = 0
