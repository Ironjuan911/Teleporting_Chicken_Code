extends Node2D
class_name Limit_camera

enum limit_tipe{
	Up,
	Down,
	Left,
	Right
}

@export var set_limit : limit_tipe
@export var cape = 1

var group_template = "_Limits"
var set_limit_tipe
var group

func _ready():
	set_limit_tipe = limit_tipe.find_key(set_limit)
	group = str(set_limit_tipe) + group_template
	add_to_group(group)
