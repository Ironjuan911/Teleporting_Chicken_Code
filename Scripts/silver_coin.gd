extends Node2D

@onready var animation = $Animation
@onready var animation_collected = $AnimationCollected
@onready var game_manager = GameManajer
@onready var area = $Area2D
@onready var sound_coin = $"Coin sound"

func _ready():
	animation.play("Play")


func _on_area_2d_body_entered(body):
	if body is Player:
		sound_coin.play()
		area.queue_free()
		remove_from_group("silver_coin")
		game_manager.coin_collected()
		animation_collected.play("Collected")
		

func end_animation_collected():
	queue_free()
