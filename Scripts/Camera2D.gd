extends Camera2D
class_name Camera

@export var is_player_focus = true
@export var movement_y = true
@export var movement_x = true
@export var flip_position = 20.0

var lerp_flip_position = 0.0
var focus

var real_zoom
var real_resolution = GameManajer.real_resolution
var base_resolution = GameManajer.base_resolution

@export_category("Limit_camera")
@export var cape = 1 #la capa de donde se encuentran los limites

func camera_focus():
	for node in get_tree().get_nodes_in_group("Camera_focus"):
		focus = node
		break

func _ready():
	camera_focus()
	real_zoom = zoom
	if focus: # posiciona al jugador de manera inmediata
		if movement_x == true:
			position.x = focus.position.x
		if movement_y == true:
			position.y == focus.position.y
	zoom_resolution_camara()
	set_limits(cape)
	
func set_limits(limit_cape): #Estos for se encargan de buscar segun una lista de grupos fijar los limites correspondientes
	for limit in get_tree().get_nodes_in_group("Up_Limits"): 
		if limit.cape == limit_cape:
			limit_top = limit.position.y
			break

	for limit in get_tree().get_nodes_in_group("Down_Limits"):
		if limit.cape == limit_cape:
			limit_bottom = limit.position.y
			break
			
	for limit in get_tree().get_nodes_in_group("Left_Limits"):
		if limit.cape == limit_cape:
			limit_left = limit.position.x
			break
			
	for limit in get_tree().get_nodes_in_group("Right_Limits"):
		if limit.cape == limit_cape:
			limit_right = limit.position.x
			break
		

func _process(delta):
	zoom_resolution_camara()
	"""Movimiento en y de la camara"""
	if focus and movement_y == true:
		if focus.is_on_floor():
			position.y = focus.position.y
		else:
			if focus.velocity.y > 250 and focus.jump_bounce == false:# basicamente, que si supera cierta velocidad de caida el objeto enfocado, la camara se pege a este inmediatamente
				position.y = lerp(position.y , focus.position.y , 1)
			else:
				if focus.jump_bounce == false: #Que la camara no se mueva si el salto es generado por una resortera
					position.y = lerp(position.y , focus.position.y , 0.06)
	
	"""Movimiento en x de la camara"""
	if focus and movement_x == true:
		
		if is_player_focus == true:
			if focus.flip_right == true:
				lerp_flip_position = lerp(lerp_flip_position , flip_position , 0.07)
			else:
				lerp_flip_position = lerp(lerp_flip_position , -flip_position , 0.07)
			
		position.x = lerp(position.x, (focus.position.x + lerp_flip_position), 0.2)
	
func zoom_resolution_camara():
	real_resolution = GameManajer.real_resolution
	zoom = (real_zoom*real_resolution)/base_resolution
	pass
