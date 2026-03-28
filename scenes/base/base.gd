class_name Base
extends Node2D

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
		Sounds.play_base_damage_sound();
		if value < 1:
			self.game_over();

static var _instance: Base;
static func get_instance() -> Base:
	return Base._instance;

func _ready() -> void:
	Base._instance = self;
	Sounds.play_music();

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		var mob: Mob = body as Mob;
		mob.queue_free();
		self.lifes -= mob.life_damage;

func update_waves() -> void:
	# TODO: Atualizar visualização das ondas
	pass;

func update_lifes() -> void:
	# TODO: Atualizar visualização das vidas
	pass;

func update_money() -> void:
	# TODO: Atualizar visualização das moedas
	pass;

func game_over() -> void:
	# TODO: Fazer a tela de game over e com botão 
	# de reiniciar o nível
	pass;
