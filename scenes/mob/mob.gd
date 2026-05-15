class_name Mob
extends CharacterBody2D

var life_damage: int = 0;
var damage: int = 5;
var damage_type: DamageType = DamageType.PHYSICAL;
var attack_type: AttackType = AttackType.MELEE;
var attack_interval: int = 4;
var attack_interval_randomness: float = 0.1;
var _attack_timer: float = 0.0;
var speed: int = 50;
var health: int = 30;
var physical_resistance: float = 0.0;
var magical_resistance: float = 0.0;
var is_enemy: bool = true;
var value_in_money: int = 0;

@onready var attack_area_collision_shape: CollisionShape2D = $AttackArea2D/CollisionShape2D;
@onready var agro_area_collision_shape: CollisionShape2D = $AgroArea2D/CollisionShape2D;
@onready var sprite: Sprite2D = $Directionals/Sprite2D;
@onready var directionals: Node2D = $Directionals;
@onready var state_machine: StateChart = $StateMachine;
@onready var walking_state: AtomicState = $StateMachine/CompoundState/Walking;
@onready var animation_player: AnimationPlayer = $AnimationPlayer;

var targets: Array[Mob] = [];
var targets_in_attack_range: Array[Mob] = [];
var tower: Tower;
var initial_data: MobData;
var target: Mob;
var focused_by: Mob;
var current_point: int = 0;
var path_points: PackedVector2Array;
var movement_is_priority: bool = false;

enum AttackType {
	MELEE,
	RANGED
}

enum DamageType {
	MAGICAL,
	PHYSICAL
}

#region Definir destino
func set_path(path: Path2D) -> void:
	self.current_point = 0;
	var count: int = path.curve.point_count;
	self.path_points.resize(count);
	for i in range(count):
		self.path_points[i] = path.to_global(path.curve.get_point_position(i));
	self.movement_is_priority = false;
func set_data(mob: MobData) -> void:
	self.life_damage = mob.life_damage;
	self.damage = mob.damage;
	self.damage_type = mob.damage_type;
	self.attack_type = mob.attack_type;
	self.attack_interval_randomness = mob.attack_interval_randomness;
	var interval_reduction: int = randi_range(
		0, 
		int(self.attack_interval * self.attack_interval_randomness)
	);
	self.attack_interval = mob.attack_interval;
	self._attack_timer = self.attack_interval - interval_reduction;
	if self.attack_area_collision_shape.shape is CircleShape2D:
		var circle: CircleShape2D = self.attack_area_collision_shape.shape as CircleShape2D;
		circle.radius = mob.attack_range;
	if self.agro_area_collision_shape.shape is CircleShape2D:
		var circle: CircleShape2D = self.agro_area_collision_shape.shape as CircleShape2D;
		circle.radius = mob.agro_range;
	self.speed = mob.speed;
	self.health = mob.health;
	self.physical_resistance = mob.physical_resistance;
	self.magical_resistance = mob.magical_resistance;
	self.is_enemy = mob.is_enemy;
	self.sprite.texture = mob.texture;
	self.sprite.offset = mob.texture_offset;
	self.sprite.modulate = mob.modulate;
	self.visible = true;
	self.movement_is_priority = false;
	self.value_in_money = mob.value_in_money;
func move_back() -> void:
	if (
		self.tower && is_instance_valid(self.tower) && 
		self.tower.type == Tower.TowerType.BARRACK &&
		self.tower.tower_barrack_spawn_point.distance_to(self.global_position) >= 26.0
	):
		var units: Node2D = self.tower.units;
		var index: int = units.get_children().find(self);
		if index >= 0:
			self.move_to_point(self.tower.tower_barrack_spawn_point, index);
func move_to_point(global_point: Vector2, triangle: int = -1) -> void:
	var target_point: Vector2 = global_point;
	if triangle >= 0 && triangle <= 2:
		var angle: float = (TAU / 3.0) * triangle;
		var offset: Vector2 = (Vector2.UP * 26.0).rotated(angle);
		target_point += offset;
	self.path_points.resize(1);
	self.current_point = 0;
	self.path_points[0] = target_point;
	self.movement_is_priority = true;
#endregion

#region Movimentação
func _ready() -> void:
	self.visible = false;
	if self.initial_data:
		self.set_data(self.initial_data);
func _process(delta: float) -> void:
	if self._attack_timer > 0.0: 
		self._attack_timer = max(self._attack_timer - delta, 0);
	if (
		self.velocity.is_zero_approx() && 
		self.walking_state.active &&
		self.animation_player.current_animation != "RESET"
	):
		self.animation_player.play("RESET");
	elif self.walking_state.active: 
		self.animation_player.play("walking");
	if !is_zero_approx(self.velocity.x):
		self.directionals.scale.x = -1.0 if self.velocity.x > 0 else 1.0;
	elif self.target && is_instance_valid(self.target):
		self.directionals.scale.x = -1.0 if self.global_position.x < self.target.global_position.x else 1.0;
func _follow_path(delta: float) -> void:
	if !self.visible || self.path_points.is_empty() || self.current_point >= self.path_points.size(): 
		self.velocity = Vector2.ZERO;
		self.movement_is_priority = false;
		self.move_and_slide();
		return;
	var destiny: Vector2 = self.path_points[self.current_point];
	var distance: float = self.global_position.distance_to(destiny);
	if self.global_position.distance_to(destiny) < 4.0:
		self.current_point += 1;
		if self.current_point >= self.path_points.size():
			self.velocity = Vector2.ZERO;
			self.movement_is_priority = false;
			self.move_and_slide();
			return;
		else: 
			destiny = self.path_points[self.current_point];
			distance = self.global_position.distance_to(destiny);
	var max_speed: float = distance / delta;
	self.velocity = self.global_position.direction_to(destiny) * min(
		self.speed, 
		max_speed
	);
	self.move_and_slide();
func _on_walking_state_physics_processing(delta: float) -> void:
	if !self.visible || self.path_points.is_empty() || self.current_point >= self.path_points.size(): 
		self.velocity = Vector2.ZERO;
		if !self.check_agro(): self.move_back();
		self.move_and_slide();
		return;
	elif !self.movement_is_priority:
		self.check_agro();
	self._follow_path(delta);
func _on_attacking_state_physics_processing(delta: float) -> void:
	var target_is_valid: bool = self.target && is_instance_valid(self.target);
	var target_is_in_attack_range: bool = target_is_valid && self.targets_in_attack_range.has(self.target);
	if target_is_valid && !target_is_in_attack_range: 
		if self.is_enemy: 
			self.velocity = Vector2.ZERO;
			self.move_and_slide();
		else:
			var distance: float = self.global_position.distance_to(self.target.global_position);
			var max_speed: float = distance / delta;
			self.velocity = self.global_position.direction_to(self.target.global_position) * min(
				self.speed, 
				max_speed
			);
			self.move_and_slide();
	elif target_is_in_attack_range:
		self.velocity = Vector2.ZERO;
		self.move_and_slide();
#endregion

#region Ataque
func attack() -> void:
	if is_instance_valid(self.target):
		match self.attack_type:
			AttackType.MELEE:
				self.target.hurt(damage, damage_type);
			AttackType.RANGED:
				pass;
func check_agro() -> bool:
	var has_target_in_agro_range: bool = false;
	for _target in self.targets:
		if self.is_valid_target(_target):
			has_target_in_agro_range = true;
			break;
	var has_target_in_attack_range: bool = false;
	for _target in self.targets_in_attack_range:
		if self.is_valid_target(_target):
			has_target_in_attack_range = true;
			break;
	if (!self.is_enemy && has_target_in_agro_range) || has_target_in_attack_range:
		self.state_machine.send_event("to_attack");
		return true;
	return false;
func _on_attacking_state_processing(_delta: float) -> void:
	var target_is_valid: bool = self.target && is_instance_valid(self.target);
	var target_is_in_attack_range: bool = target_is_valid && self.targets_in_attack_range.has(self.target);
	if !target_is_valid && self.targets.size() > 0:
		self.clear_target();
		self.target = null;
		var nearest: Mob = self.targets[0];
		var nearest_distance: float = nearest.global_position.distance_to(self.global_position);
		for _target in self.targets:
			if self.is_valid_target(_target):
				var distance: float = _target.global_position.distance_to(self.global_position);
				if distance < nearest_distance:
					nearest_distance = distance;
					nearest = _target;
		self.try_set_target(nearest);
		target_is_valid = self.is_valid_target(self.target);
	if !target_is_valid || self.movement_is_priority:
		self.state_machine.send_event("to_walk");
	elif target_is_in_attack_range:
		if self._attack_timer <= 0.8 && self.animation_player.current_animation != "attacking":
			self.animation_player.play("attacking");
			var interval_reduction: int = randi_range(
				0, 
				int(self.attack_interval * self.attack_interval_randomness)
			);
			self._attack_timer = self.attack_interval - interval_reduction;
	elif !target_is_in_attack_range:
		self.movement_is_priority = false;
func _on_agro_area_2d_body_entered(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy != self.is_enemy:
		var mob: Mob = body as Mob; 
		if !self.targets.has(mob):
			self.targets.append(mob);
func _on_agro_area_2d_body_exited(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy != self.is_enemy:
		var mob: Mob = body as Mob;
		if self.targets.has(mob):
			self.targets.erase(mob);
func _on_attack_area_2d_body_entered(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy != self.is_enemy:
		var mob: Mob = body as Mob;
		if !self.targets_in_attack_range.has(mob):
			self.targets_in_attack_range.append(mob);
func _on_attack_area_2d_body_exited(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy != self.is_enemy:
		var mob: Mob = body as Mob;
		if self.targets_in_attack_range.has(mob):
			self.targets_in_attack_range.erase(mob);
#endregion

#region Damage
func try_set_target(mob: Mob) -> void:
	if self.is_valid_target(mob):
		self.target = mob;
		mob.focused_by = self;
		self.focused_by = mob;
		mob.target = self;
func is_valid_target(mob: Mob) -> bool:
	if !mob || !is_instance_valid(mob): return false;
	var not_focused_by_other: bool = (mob.focused_by == null || mob.focused_by == self);
	var not_targeting_other: bool = (mob.target == null || mob.target == self);
	return not_focused_by_other && not_targeting_other;
func clear_target() -> void:
	if self.target && is_instance_valid(self.target):
		if self.target.focused_by == self:
			self.target.focused_by = null;
		if self.target.target == self:
			self.target.target = null;
	self.target = null;
	self.focused_by = null;
func hurt(hit_damage: int, type: DamageType,):
	match type:
		DamageType.PHYSICAL:
			self.health -= round(hit_damage * (1.0 - self.physical_resistance));
		DamageType.MAGICAL:
			self.health -= round(hit_damage * (1.0 - self.magical_resistance));
	if self.health <= 0:
		self.die();
func die():
	self.clear_target();
	if self.is_enemy:
		Base.get_instance().money += self.value_in_money;
	self.queue_free();
#endregion Damage
