extends Node2D

@onready var real_resolution = DisplayServer.window_get_size().y
var UI_node
var base_resolution = 648 # la resolución vertical de pantalla base usada para ajustar la camara y el UI
var coins = 0

var level_range = {
	1 : 1,
	2 : 1
}
var level_number = 1
var zone_number = 1
var end_transition = true #Define si la transicion de escenas a concluido
var process_set_world = false
var location_select_world = ""
var select_world

func _ready():
	await get_tree().create_timer(0.05).timeout
	GameData.load_game()
	GameData.load_settings()
	await get_tree().create_timer(0.02).timeout
	for node in get_tree().get_nodes_in_group("UI"): #Definir el nodo interfaz de usuario
		UI_node = node
		GameData.UI_node = UI_node
		break
	UI_node.transitión_active(true,false)
	set_world()

func _process(delta):
	update_variable()
	
func update_variable(): #variables que se actualizan constantemente
	real_resolution = DisplayServer.window_get_size().y

func coin_collected():
	coins = coins + 1
	coins_left()

func _input(event):
	if event.is_action_pressed("ui_exit"):
		get_tree().quit()

func coins_left():
	if get_tree().get_nodes_in_group("silver_coin") == []:
		print("total Coins Collected")

"""Admin worlds"""

func set_world():
	UI_node.transitión_active(true,true)
	await get_tree().create_timer(0.3).timeout
	if select_world:
		select_world.call_deferred("free")

		await get_tree().create_timer(0.1).timeout
	
	location_select_world = "res://Scenes/Worlds/world_" + str(zone_number) + "_" + str(level_number) + ".tscn"
	print(location_select_world)
	select_world = load(location_select_world).instantiate()
	
	add_child(select_world)
	await get_tree().create_timer(0.3).timeout
	#UI_node.android_buttons_mode()
	UI_node.transitión_active(false,true)
	

func change_level():
	if level_number < level_range.get(zone_number): #Basicamente, si so se a llegado al nivel maximo de la lista, se pase al siguiente nivel
		level_number = level_number + 1
	else:
		level_number = 1
		zone_number = zone_number + 1
		if not level_range.get(zone_number):
			zone_number = 1
	GameData.save_game()
	set_world()
	
