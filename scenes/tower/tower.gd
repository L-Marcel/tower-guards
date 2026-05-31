class_name Tower
extends Node2D

static var global_interval_reduction: float = 0.0;

@onready var area: Area2D = $Area2D;
@onready var attack_area: AttackArea2D = $TowerAttackArea2D;
@onready var menu: TowerMenu = $TowerMenu;
@onready var sprite: Sprite2D = $Sprite2D;
@onready var timer: Timer = $Timer;
@onready var units: Node2D = $Units;
@onready var projectiles: Node2D = $Projectiles;
@onready var bow: Node2D = $Bow;
@onready var bow_sprite: AnimatedSprite2D = $Bow/Sprite2D;
@onready var throw_arrow_sound: AudioStreamPlayer2D = $ThrowArrowSound;
@onready var throw_bullet_sound: AudioStreamPlayer2D = $ThrowBulletSound;
@onready var throw_rock_sound: AudioStreamPlayer2D = $ThrowRockSound;
@onready var spawn_sound: AudioStreamPlayer2D = $SpawnSound;
@onready var click_area_shape: CollisionShape2D = $Area2D/CollisionShape2D;

var attack_cooldown: float = 0.0;

var level: int = 0;
var type: TowerType = TowerType.NONE;

enum TowerType {
	NONE,
	ARCHER,
	WIZARD,
	BARRACK,
	QUARY
}

#region Dados de cada torre
@export_group("Archer")
@export var tower_archer_datas: Array[TowerArcherData] = [];
var current_tower_archer_data: TowerArcherData;

@export_group("Wizard")
@export var tower_wizard_datas: Array[TowerWizardData] = [];
var current_tower_wizard_data: TowerWizardData;

@export_group("Quary")
@export var tower_quary_datas: Array[TowerQuaryData] = [];
var current_tower_quary_data: TowerQuaryData;

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
	if Tower.global_interval_reduction != 0:
		self.modulate = Color.from_string("#ffbc27", Color.WHITE);
	else:
		self.modulate = Color.WHITE;
	self.attack_cooldown -= delta * (1.0 + Tower.global_interval_reduction);
	match self.type:
		TowerType.ARCHER:
			var origin: Vector2 = self.bow_sprite.global_position;
			var target: Mob = self.attack_area.get_target();
			if target != null:
				var end_position: Vector2 = (origin + target.global_position) / 2.0;
				end_position.y -= 120.0;
				var tangent: Vector2 = 2.0 * (end_position - origin);
				var target_angle: float = tangent.angle() + PI / 2;
				self.bow.rotation = lerp_angle(self.bow.rotation, target_angle, delta * 5.0);
			if self.attack_cooldown <= 0:
				if is_instance_valid(target):
					self.bow_sprite.play("shotting");
					self.attack_cooldown = self.current_tower_archer_data.attack_interval;
					await self.get_tree().create_timer(1.0 / 4.5).timeout;
					for i in range(0, self.get_archer_shot_count()):
						target = self.attack_area.get_target(i);
						if is_instance_valid(target):
							self.shot_arrow(target, self.to_local(self.bow_sprite.global_position));
				elif !self.bow_sprite.is_playing():
					self.bow_sprite.play("with_arrow");
			elif !self.bow_sprite.is_playing():
				self.bow_sprite.play("no_arrow");
		TowerType.WIZARD:
			var target: Mob = self.attack_area.get_target();
			if self.attack_cooldown <= 0 && is_instance_valid(target):
				self.attack_cooldown = self.current_tower_wizard_data.attack_interval;
				self.shot_bullet(target);
		TowerType.QUARY:
			var target: Mob = self.attack_area.get_target();
			if self.attack_cooldown <= 0 && is_instance_valid(target):
				self.attack_cooldown = self.current_tower_quary_data.attack_interval;
				self.shot_rock(target);
		TowerType.BARRACK:
			if self.timer.is_stopped() && self.units.get_child_count() < self.current_tower_barrack_data.max_units:
				self.timer.start();
func _on_timer_timeout() -> void:
	if self.type == TowerType.BARRACK && self.units.get_child_count() < self.current_tower_barrack_data.max_units:
		self.spawn_unit();
func get_archer_shot_count() -> int:
	var shot_count: int = 1;
	var roll: float = randf();
	match self.level:
		2:
			if roll <= 0.75:
				shot_count = 2;
		3:
			if roll <= 0.50:
				shot_count = 3;
			elif roll <= 0.75:
				shot_count = 2;
	return shot_count;
func shot_arrow(target: Mob, origin: Vector2) -> void:
	var scene: PackedScene = Preloader.get_resource("arrow");
	var arrow: Arrow = scene.instantiate();
	arrow.visible = false;
	self.projectiles.add_child(arrow);
	arrow.setup(
		self.global_position, 
		target,
		self.current_tower_archer_data.damage,
		origin
	);
	self.throw_arrow_sound.play();
func shot_bullet(target: Mob) -> void:
	var scene: PackedScene = Preloader.get_resource("bullet");
	var bullet: Bullet = scene.instantiate();
	bullet.visible = false;
	self.projectiles.add_child(bullet);
	bullet.setup(
		self.global_position, 
		target,
		self.current_tower_wizard_data.damage,
		self.current_tower_wizard_data.origin,
		self.level
	);
	self.throw_bullet_sound.play();
func shot_rock(target: Mob) -> void:
	var scene: PackedScene = Preloader.get_resource("rock");
	var rock: Rock = scene.instantiate();
	rock.visible = false;
	self.projectiles.add_child(rock);
	rock.setup(
		self.global_position, 
		target,
		self.current_tower_quary_data.damage,
		self.current_tower_quary_data.origin
	);
	self.throw_rock_sound.play();
func set_timer():
	var wait_time: float = 0;
	match self.type:
		TowerType.BARRACK:
			wait_time = self.current_tower_barrack_data.unit_respawn_interval;
		TowerType.ARCHER:
			wait_time = self.current_tower_archer_data.attack_interval;
		TowerType.WIZARD:
			wait_time = self.current_tower_wizard_data.attack_interval;
		TowerType.QUARY:
			wait_time = self.current_tower_quary_data.attack_interval;
	self.timer.set_wait_time(wait_time * (1.0 - Tower.global_interval_reduction));
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
	self.spawn_sound.play();
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
		if self.attack_area.collision_shape:
			self.attack_area.collision_shape.radius_x = data.attack_range;
			self.attack_area.collision_shape.radius_y = self.attack_area.collision_shape.radius_x / 2.0;
			self.attack_area.queue_redraw();
		self.tower_barrack_spawn_point = self.global_position;
		self.bow.visible = false;
		self.sprite.offset = data.offset;
		self.click_area_shape.position = data.offset;
		self.set_timer();
func buy_quary() -> void:
	if self.level > 2: return;
	var data: TowerQuaryData = self.tower_quary_datas[self.level];
	var cost: int = data.cost;
	if cost <= Base.get_instance().money:
		Base.get_instance().money -= cost;
		self.current_tower_quary_data = data;
		self.type = TowerType.QUARY;
		self.level += 1;
		self.sprite.texture = data.texture;
		if self.attack_area.collision_shape:
			self.attack_area.collision_shape.radius_x = data.attack_range;
			self.attack_area.collision_shape.radius_y = self.attack_area.collision_shape.radius_x / 2.0;
			self.attack_area.queue_redraw();
		self.tower_barrack_spawn_point = self.global_position;
		self.sprite.offset = data.offset;
		self.click_area_shape.position = data.offset;
		self.bow.visible = false;
		self.set_timer();
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
		if self.attack_area.collision_shape:
			self.attack_area.collision_shape.radius_x = data.attack_range;
			self.attack_area.collision_shape.radius_y = self.attack_area.collision_shape.radius_x / 2.0;
			self.attack_area.queue_redraw();
		self.tower_barrack_spawn_point = self.global_position;
		self.bow.position.y = data.origin.y;
		self.sprite.offset = data.offset;
		self.click_area_shape.position = data.offset;
		self.bow.visible = true;
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
		if self.attack_area.collision_shape:
			self.attack_area.collision_shape.radius_x = data.unit_place_range;
			self.attack_area.collision_shape.radius_y = self.attack_area.collision_shape.radius_x / 2.0;
			self.attack_area.queue_redraw();
		if self.level == 1:
			self.calculate_initial_spawn_point();
		self.bow.visible = false;
		self.sprite.offset = data.offset;
		self.click_area_shape.position = data.offset;
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
		TowerType.QUARY:
			sell_value = self.current_tower_quary_data.sell_value;
	self.bow.visible = false;
	self.level = 0;
	self.type = TowerType.NONE;
	self.current_tower_archer_data = null;
	self.current_tower_wizard_data = null;
	self.current_tower_barrack_data = null;
	self.current_tower_quary_data = null;
	self.sprite.texture = null;
	self.sprite.offset = Vector2(0, -36);
	self.click_area_shape.position = Vector2(0, -36);
	Base.get_instance().money += sell_value;
	if self.attack_area.collision_shape:
		self.attack_area.collision_shape.radius_x = 1.0;
		self.attack_area.collision_shape.radius_y = 1.0;
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
		query.position = self.get_global_mouse_position();
		query.collide_with_areas = true;
		query.collide_with_bodies = false;
		var space_state: PhysicsDirectSpaceState2D = self.get_world_2d().direct_space_state;
		var result: Array[Dictionary] = space_state.intersect_point(query);
		
		var hit_menu: bool = result.any(func(hit: Dictionary): return self.menu.areas.has(hit["collider"]) || !self.menu.enabled);
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
					1, 2: 
						if Level.get_instance().max_tower_level > self.level:
							self.menu.open_upgrade_menu();
						else: self.menu.open_end_menu();
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
