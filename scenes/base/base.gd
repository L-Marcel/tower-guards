class_name Base
extends Node2D

@onready var label_money: Label = $CanvasLayer/Control/MarginContainer/HBoxContainer/Money;
@onready var label_life: Label = $CanvasLayer/Control/MarginContainer/HBoxContainer/HBoxContainer/Lifes;
@onready var menu: Menu = $CanvasLayer/Menu;

# TODO: Só para não esquecer... Quando não restar mais tarefas, 
# o último a cantar, é quem fecha a porta.
# POR FAVOR, LEMBRAR DE DEFINIR O MONEY NAS CENAS DOS NÍVEIS
# AO FECHAR A PORTA POIS EU DEIXEI COM 3000 PARA FINS DE TESTE

@export var money: int = 30:
	set(value):
		money = value;
		self.update_money();
@export var lifes: int = 3:
	set(value):
		lifes = value;
		self.update_lifes();
		Sounds.play_base_damage_sound()
		if value < 1: self.game_over();

static var _instance: Base;
static func get_instance() -> Base:
	return _instance;

func _ready() -> void:
	_instance = self;
	Sounds.play_music();
	self.update_money();
	self.update_lifes();
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Mob and (body as Mob).is_enemy:
		var mob: Mob = body as Mob;
		mob.queue_free();
		self.lifes -= mob.life_damage;

func update_waves() -> void:
	# TODO: Atualizar visualização das ondas
	pass
func update_lifes() -> void:
	if self.label_life:
		self.label_life.text = "%d" % self.lifes;
func update_money() -> void:
	if self.label_money:
		self.label_money.text = "$%d" % self.money;

func win() -> void:
	self.menu.end(true);
func game_over() -> void:
	self.menu.end(false);
