extends Node2D

var settings_location = "user://settings.dc"
var save_file # El archivo de guardado en cuestión

func save_diccionary(location,diccionary):
	save_file = FileAccess.open(save_location, FileAccess.WRITE) #Abrimos el archivo en la ubicacion anteriormente mencionada
	save_file.store_var(diccionary) #Guardamos el diccionario
	print(diccionary, location)
	save_file = null #Cerramos
