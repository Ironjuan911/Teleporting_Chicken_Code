extends Area2D
class_name Box_teleport

enum button_type{ #Lista de botones que tendra que detectar
	Red,
	Blue,
	Green
}

@export var detect_button : button_type #Exportar dicla lista mencionada anteriormente
var group_template = "_Buttons_Unpressed"
var set_detect_button

@onready var animation = $Animation
@onready var sound_spawn: AudioStreamPlayer2D = $SoundSpawn

var spawn = false #Nos dise si la caja a aparesido o no
var process = false # define si inicio el proseso para cambiar de esena
var activate = false #Define si la caja ya se a activado y se esta cambiando de escena
var player
var ready_node = false

func _ready():
	await get_tree().create_timer(0.1).timeout
	ready_node = true
	set_detect_button = button_type.find_key(detect_button)
	
	if get_tree().get_nodes_in_group(set_detect_button + group_template) == []:
		animation.play("Force_Spawn")
		spawn = true
	else:
		animation.play("Un_Spawn")

func _physics_process(delta):
	if ready_node == true:
		physics_process_ready(delta)

func physics_process_ready(delta):
	if get_tree().get_nodes_in_group(set_detect_button + group_template) == [] and spawn == false:
		spawn = true
		spawn_sound()
		animation.play("Spawn")
	
	if player and process == true: #Basicamente, atraer el jugador a la caja.
		player.position = lerp(player.position, position, 0.15)
		
		if abs(player.position.x - position.x) < 0.15 and abs(player.position.y - position.y) < 0.25: #Cuando el jugador se encuentre aproximadamente en la misma posicion que oloa caja, que se llame la función de cambiar nivel del GameManager
			if activate == false:
				activate = true
				GameManajer.change_level()
			
	

func _on_body_entered(body):
	if body is Player and spawn == true: #Basicamente, que hacer cuando el jugador toque la caja cuando esta este activa
		player = body
		if process == false:  #Esta segunda comprobacion hace que esto solo se ejecute una sola ves
			body.can_player_movement = false
			body.end_animation(true)
			process = true

func spawn_sound():
	sound_spawn.playing = true
