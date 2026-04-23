class_name Tower
extends Node2D

@onready var area: Area2D = $Area2D;
@onready var attack_area: TowerAttackArea2D = $TowerAttackArea2D;
@onready var menu: TowerMenu = $TowerMenu;
@onready var sprite: Sprite2D = $Sprite2D;
@onready var timer: Timer = $Timer;
@onready var units: Node2D = $Units;

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
var tower_barrack_spawn_point: Vector2 :
	set(value):
		tower_barrack_spawn_point = value;
		if self.units.is_node_ready():
			var count: int = 0;
			for child in self.units.get_children():
				if child is Mob:
					child.move_to_point(value, count);
					count += 1;

var is_changing_spawn_point: bool = false;
static var is_any_changing_spawn_point: bool = false;
#endregion

func _ready() -> void:
	self.is_any_changing_spawn_point = false;
	self.add_to_group("towers");

#region Lógicas de ataque
func _process(delta: float) -> void:
	match self.type:
		TowerType.NONE: pass;
		TowerType.ARCHER: 
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
			pass;
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
			if self.timer.is_stopped() && self.units.get_child_count() < self.current_tower_barrack_data.max_units:
				self.spawn_unit();
				if self.units.get_child_count() < self.current_tower_barrack_data.max_units:
					self.timer.start();
func set_timer():
	match self.type:
		TowerType.BARRACK:
			self.timer.set_wait_time(self.current_tower_barrack_data.unit_respawn_interval);
		TowerType.ARCHER:
			self.timer.set_wait_time(self.current_tower_archer_data.attack_interval);
		TowerType.WIZARD:
			self.timer.set_wait_time(self.current_tower_wizard_data.attack_interval);
func clear_units() -> void:
	for child in self.units.get_children():
		if child is Mob:
			child.die();
func spawn_unit(index: int = self.units.get_child_count()) -> void:
	var scene: PackedScene = Preloader.get_resource("mob");
	var mob: Mob = scene.instantiate();
	mob.tower = self;
	mob.position = Vector2.ZERO;
	mob.initial_data = self.current_tower_barrack_data.unit_data;
	mob.move_to_point(self.tower_barrack_spawn_point, index);
	self.units.add_child(mob);
	Sounds.play_spawn_sound();
func sort_closest_point(array: Array[Vector2], point: Vector2):
	array.sort_custom(func(a: Vector2, b: Vector2) -> bool: 
		return a.distance_squared_to(point) < b.distance_squared_to(point);
	);
func calculate_initial_spawn_point() -> void:
	var paths: Paths = Paths.get_instance();
	var closest_points: Array[Vector2] = [];
	
	var midpoints: Array[Vector2] = [
		Vector2(120, 70),
		Vector2(120, -70),
		Vector2(-120, -70),
		Vector2(-120, 70)
	];
	
	for i in midpoints.size():
		var point: Vector2 = midpoints[i];
		midpoints[i] = self.to_global(point);
	
	for path in paths.get_children():
		if(path is Path2D):
			closest_points.push_back(
				path.to_global(
					path.curve.get_closest_point(
						path.to_local(self.global_position)
					)
				)
			);
	
	self.sort_closest_point(closest_points, self.global_position);
	self.sort_closest_point(midpoints, closest_points.front());
	self.tower_barrack_spawn_point = midpoints.front();
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
		self.set_timer()
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
		self.set_timer();
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
			self.calculate_initial_spawn_point();
		self.clear_units();
		for i in range(data.inital_units):
			self.spawn_unit(i);
		self.set_timer();
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
	self.clear_units();
#endregion

#region Detecção de clicks
func start_change_spawn_point_mode() -> void:
	self.is_changing_spawn_point = true;
	Tower.is_any_changing_spawn_point = true;
	self.attack_area.border_is_visible = true;
	self.attack_area.is_alternative = true;
	self.menu.close_menu();
func close_other_menus(active_tower: Tower) -> void:
	if self != active_tower:
		self.menu.close_menu();
		self.attack_area.border_is_visible = false;
		self.attack_area.is_alternative = false;
		self.is_changing_spawn_point = false;
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
		
		if !self.is_changing_spawn_point && !Tower.is_any_changing_spawn_point:
			var hit_self: bool = result.any(func(hit: Dictionary): return hit["collider"] == self.area);
			if hit_self:
				self.get_viewport().set_input_as_handled();
				self.get_tree().call_group("towers", "close_other_menus", self);
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
		elif self.is_changing_spawn_point:
			var hit_attack_area: bool = result.any(func(hit: Dictionary): return hit["collider"] == self.attack_area);
			if hit_attack_area:
				self.get_viewport().set_input_as_handled();
				self.tower_barrack_spawn_point = self.get_global_mouse_position();
			self.is_changing_spawn_point = false;
			Tower.is_any_changing_spawn_point = false;
			self.attack_area.border_is_visible = false;
			self.attack_area.is_alternative = false;
		else:
			self.attack_area.border_is_visible = false;
			self.attack_area.is_alternative = false;
#endregion
