extends Node2D

var save_location = "user://savegame.dc" #Ubicación del archivo de guardado
var settings_location = "user://settings.dc"
var save_file # El archivo de guardado en cuestión
var UI_node

@export var force_save_data = false

@export var game_data : Dictionary = { #Contenido del archivo de guardado
	"zone_number" : 1,
	"level_number" : 1,
}

@export var game_settings : Dictionary = {
	"android_buttons" : false,
}


func save_diccionary(location, diccionary):
	save_file = FileAccess.open(location, FileAccess.WRITE) #Abrimos el archivo en la ubicacion anteriormente mencionada
	save_file.store_var(diccionary) #Guardamos el diccionario
	print(diccionary," ",location, " [save]")
	save_file = null #Cerramos
	

func load_diccionary(location,diccionary):
	
	if force_save_data == true:
		force_save_data = false
		return diccionary
	else:
		if (FileAccess.file_exists(location)): #Comprobamos si el archico en cuestion existe
			save_file = FileAccess.open(location, FileAccess.READ) #Abrimos el archivo
			diccionary = save_file.get_var() #Cargamos las variables en el diccionario
			save_file = null #Cerramos
			print(diccionary," ",location, " [load]")
			return diccionary
		else:
			return {}

func erase_game():
	save_file = FileAccess.open(save_location, FileAccess.WRITE) #Abrimos el archivo
	save_file.store_var({}) #Guardamos un diccionario vacio
	save_file.close() #Cerramos el archivo
	get_tree().quit() #Cerramos el juego

func load_var_game():
	if game_data.get("level_number"):
		GameManajer.level_number = game_data["level_number"]
	if game_data.get("zone_number"):
		GameManajer.zone_number = game_data["zone_number"]

func load_var_settings():
	await get_tree().create_timer(0.1).timeout
	if game_settings.get("android_buttons"):
		UI_node.android_controls = game_settings["android_buttons"]
		UI_node.android_buttons_mode()
	else:
		UI_node.android_buttons_mode()

func save_game():
	game_data["level_number"] = GameManajer.level_number #Añadimos variables al diccionario, el cual guardaremos
	game_data["zone_number"] = GameManajer.zone_number
	
	save_diccionary(save_location,game_data)

func load_game():
	game_data = load_diccionary(save_location,game_data)
	load_var_game() #Cargamos las variables del diccionario
	
func save_settings():
	save_diccionary(settings_location, game_settings)
	
func load_settings():
	game_settings = load_diccionary(settings_location, game_settings)
	load_var_settings()
