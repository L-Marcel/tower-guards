class_name Base
extends Node2D

@onready var label_money = get_node("CanvasLayer/Control/MarginContainer/HBoxContainer/Money")
@onready var label_life = get_node("CanvasLayer/Control/MarginContainer/HBoxContainer/Lifes")


var _money: int = 30
var _lifes: int = 3

@export var money: int:
	set(value):
		_money = value
		update_money()
	get:
		return _money

@export var lifes: int:
	set(value):
		_lifes = value
		update_lifes()
		Sounds.play_base_damage_sound()
		if value < 1:
			game_over()
	get:
		return _lifes

static var _instance: Base
static func get_instance() -> Base:
	return _instance

func _ready() -> void:
	_instance = self
	Sounds.play_music()
	
	# Atualiza HUD quando tudo já existe
	update_money()
	update_lifes()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Mob and (body as Mob).is_enemy:
		var mob: Mob = body as Mob
		mob.queue_free()
		lifes -= mob.life_damage

# TODO
func update_waves() -> void:
	pass

func update_lifes() -> void:
	if label_life:
		label_life.text = "VIDAS: %d" % _lifes

func update_money() -> void:
	if label_money:
		label_money.text = "$%d" % _money

func game_over() -> void:
	# TODO: Tela de game over
	pass
