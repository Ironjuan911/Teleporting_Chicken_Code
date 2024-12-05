extends Node2D

@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite2D

func _ready(): #Basicamente, que susede cuando la "particula" que genera el dash aparece
	sprite.visible = true #Se hace invisible por un leve instante mientras se cargan todos los parametros
	animation.play("RESET")
	animation.play("Unspawn")
	
func flip_sprite(flip):
	if flip == true:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	sprite.visible = true 

func total_unspawn():
	queue_free()
