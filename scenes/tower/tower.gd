class_name Tower
extends Node2D

@onready var area: Area2D = $Area2D;
@onready var attack_area: TowerAttackArea2D = $TowerAttackArea2D;
@onready var menu: TowerMenu = $TowerMenu;
@onready var sprite: Sprite2D = $Sprite2D;
@onready var enemies_in_range: Array = [];
var ArrowScene = preload("res://scenes/arrow/arrow.tscn")
var attack_cooldown: float = 0.0

var level: int = 0;
var type: TowerType = TowerType.NONE;

enum TowerType {
	NONE,
	ARCHER,
	WIZARD,
	BARRACK
}

#region Dados de cada torre
@export_group("Archer")
@export var tower_archer_datas: Array[TowerArcherData] = [];
var current_tower_archer_data: TowerArcherData;

@export_group("Wizard")
@export var tower_wizard_datas: Array[TowerWizardData] = [];
var current_tower_wizard_data: TowerWizardData;

@export_group("Barrack")
@export var tower_barrack_datas: Array[TowerBarrackData] = [];
var current_tower_barrack_data: TowerBarrackData;
var tower_barrack_spawn_point: Vector2;
var changing_spawn_point: bool = false;
#endregion

#region Lógicas de ataque
func _process(delta: float) -> void:
	attack_cooldown -= delta
	match self.type:
		TowerType.NONE:
			pass
		TowerType.ARCHER:
			if attack_cooldown <= 0:
				var target = get_target()
				# print("target:", target)
				if target != null:
					var arrow = ArrowScene.instantiate()
					
					get_tree().current_scene.add_child(arrow)
					arrow.setup(global_position, target)
					
					arrow.damage = current_tower_archer_data.damage
					attack_cooldown = current_tower_archer_data.attack_interval
			# TODO: Atáque a distância físico
			# use os dados de current_tower_archer_data
			# TODO: Criar cena das flechas, use area 2D nelas de alguma forma 
			# para detectar os inimigos e não se esqueça que um mob 
			# pode ser inimigo ou aliado, tem que verificar com o is_enemy
			# NOTE: Considere que o inimigo pode ser destruído antes do 
			# projétil chegar nele
			# NOTE: Ao contrário do projétil mágico, pode não ser interessante 
			# se a flecha seguir o caminho inteiro. Manter ela rápida pode resolver
			# NOTE: Experimente usar o global preloader
			# NOTE: Chame os métodos adequados do Sounds quando preciso

		TowerType.WIZARD: 
			# TODO: Atáque a distância mágico
			# use os dados de current_tower_wizard_data
			# TODO: Criar cena das bolas mágicas, use area 2D nelas de alguma forma 
			# para detectar os inimigos e não se esqueça que um mob 
			# pode ser inimigo ou aliado, tem que verificar com o is_enemy
			# NOTE: Considere que o inimigo pode ser destruído antes do 
			# projétil chegar nele
			# NOTE: Experimente usar o global preloader
			# NOTE: Chame os métodos adequados do Sounds quando preciso
			pass;
		TowerType.BARRACK:
			# TODO: Lógica de recriar soldados
			# use os dados de current_tower_barack_data
			# NOTE: Se você verificar em resources/towers/barrack verá que todas as variantes das 
			# barracas estão incompletas, você precisará definir os soldados aliados primeiro na 
			# tarefa correspondente
			# NOTE: A cena mob vale tanto para aliado como para inimigos
			# Ela já tem método para forçar os mobs a caminharem para 
			# um ponto especifico, ele se chamada move_to_point. 
			# Mas também tem o move_to_mob, para fazer o mob ir na 
			# direção de um outro mob
			# NOTE: Você vai precisar calcular o tower_barrack_spawn_point inicial, 
			# no método calculate_initial_spawn_point. Mas ele já muda sozinho 
			# quando o usuário clicar no botão de mudar da barraca e 
			# clicar no ponto dentro da área
			# NOTE: Experimente usar o global preloader
			# NOTE: Chame os métodos adequados do Sounds quando preciso
			pass;
func calculate_initial_spawn_point(radius: float) -> void:
	# TODO: Calcula o tower_barrack_spawn_point inicial usando o 
	# raio disponível
	pass;
#endregion

#region Compra e venda
func buy_wizard() -> void:
	if self.level > 2: return;
	var data: TowerWizardData = self.tower_wizard_datas[self.level];
	var cost: int = data.cost;
	if cost <= Base.get_instance().money:
		Base.get_instance().money -= cost;
		self.current_tower_wizard_data = data;
		self.type = TowerType.WIZARD;
		self.level += 1;
		self.sprite.texture = data.texture;
		if self.attack_area.collision_shape.shape is CircleShape2D:
			var circle: CircleShape2D = self.attack_area.collision_shape.shape;
			circle.radius = data.attack_range;
			self.attack_area.queue_redraw();
		self.tower_barrack_spawn_point = self.global_position;
func buy_archer() -> void:
	if self.level > 2: return;
	var data: TowerArcherData = self.tower_archer_datas[self.level];
	var cost: int = data.cost;
	if cost <= Base.get_instance().money:
		Base.get_instance().money -= cost;
		self.current_tower_archer_data = data;
		self.type = TowerType.ARCHER;
		self.level += 1;
		self.sprite.texture = data.texture;
		if self.attack_area.collision_shape.shape is CircleShape2D:
			var circle: CircleShape2D = self.attack_area.collision_shape.shape;
			circle.radius = data.attack_range;
			self.attack_area.queue_redraw();
		self.tower_barrack_spawn_point = self.global_position;
func buy_barrack() -> void:
	if self.level > 2: return;
	var data: TowerBarrackData = self.tower_barrack_datas[self.level];
	var cost: int = data.cost;
	if cost <= Base.get_instance().money:
		Base.get_instance().money -= cost;
		self.current_tower_barrack_data = data;
		self.type = TowerType.BARRACK;
		self.level += 1;
		self.sprite.texture = data.texture;
		if self.attack_area.collision_shape.shape is CircleShape2D:
			var circle: CircleShape2D = self.attack_area.collision_shape.shape;
			circle.radius = data.unit_place_range;
			self.attack_area.queue_redraw();
		if self.level == 1:
			self.calculate_initial_spawn_point(data.unit_place_range);
func sell() -> void:
	if self.level < 1: return;
	var sell_value: int = 0;
	match self.type:
		TowerType.ARCHER:
			sell_value = self.current_tower_archer_data.sell_value;
		TowerType.WIZARD:
			sell_value = self.current_tower_wizard_data.sell_value;
		TowerType.BARRACK:
			sell_value = self.current_tower_barrack_data.sell_value;
	self.level = 0;
	self.type = TowerType.NONE;
	self.current_tower_archer_data = null;
	self.current_tower_wizard_data = null;
	self.current_tower_barrack_data = null;
	self.sprite.texture = null;
	Base.get_instance().money += sell_value;
	if self.attack_area.collision_shape.shape is CircleShape2D:
		var circle: CircleShape2D = self.attack_area.collision_shape.shape;
		circle.radius = 0;
		self.attack_area.queue_redraw();
	self.tower_barrack_spawn_point = self.global_position;
#endregion

#region Detecção de clicks
func start_change_spawn_point_mode() -> void:
	self.changing_spawn_point = true;
	self.attack_area.border_is_visible = true;
	self.attack_area.is_alternative = true;
	self.menu.close_menu();
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new();
		query.position = get_global_mouse_position();
		query.collide_with_areas = true;
		query.collide_with_bodies = false;
		var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state;
		var result: Array[Dictionary] = space_state.intersect_point(query);
		
		var hit_menu: bool = result.any(func(hit: Dictionary): return self.menu.areas.has(hit["collider"]));
		if hit_menu:
			self.attack_area.border_is_visible = false;
			self.attack_area.is_alternative = false;
			return;
		
		if !self.changing_spawn_point:
			var hit_self: bool = result.any(func(hit: Dictionary): return hit["collider"] == self.area);
			if hit_self:
				get_viewport().set_input_as_handled();
				match self.level:
					0: self.menu.open_base_menu();
					1, 2: self.menu.open_upgrade_menu();
					_: self.menu.open_end_menu();
				self.attack_area.border_is_visible = true;
				self.attack_area.is_alternative = false;
			else:
				self.attack_area.border_is_visible = false;
				self.attack_area.is_alternative = false;
				self.menu.close_menu();
		else:
			var hit_attack_area: bool = result.any(func(hit: Dictionary): return hit["collider"] == self.attack_area);
			if hit_attack_area:
				get_viewport().set_input_as_handled();
				self.tower_barrack_spawn_point = get_global_mouse_position();
			self.changing_spawn_point = false;
			self.attack_area.border_is_visible = false;
			self.attack_area.is_alternative = false;
#endregion

func get_target():
	enemies_in_range = enemies_in_range.filter(func(e):
		return is_instance_valid(e)
	)
	
	if enemies_in_range.is_empty():
		return null
	
	return enemies_in_range[0]

func _on_tower_attack_area_2d_body_entered(body: Node2D) -> void:
	if body.is_enemy:
		enemies_in_range.append(body)
		# print("ENTROU:", body)


func _on_tower_attack_area_2d_body_exited(body: Node2D) -> void:
	enemies_in_range.erase(body)
	# print("SAIU:", body)
