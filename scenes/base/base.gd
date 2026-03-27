class_name Base
extends Node2D

@export var money: int = 30;
@export var lifes: int = 3:
	set(value):
		lifes = value;
		if value < 1:
			self.game_over();

static var _instance: Base;
static func get_instance() -> Base:
	return Base._instance;

func _ready() -> void:
	Base._instance = self;

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		var mob: Mob = body as Mob;
		mob.queue_free();
		self.lifes -= mob.life_damage;

func game_over() -> void:
	# TODO: Fazer a tela de game over
	pass;
