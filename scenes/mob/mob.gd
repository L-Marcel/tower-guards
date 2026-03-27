class_name Mob
extends CharacterBody2D

var life_damage: int = 0;
var damage: int = 5;
var damage_type: DamageType = DamageType.PHYSICAL;
var attack_type: AttackType = AttackType.MELEE;
var attack_interval: int = 4;
var _attack_timer: float = 0.0;
var speed: int = 50;
var life: int = 30;
var physical_resistance: float = 0.0;
var magical_resistance: float = 0.0;
var is_enemy: bool = true;

@onready var attack_area_collision_shape: CollisionShape2D = $AttackArea2D/CollisionShape2D;
@onready var sprite: Sprite2D = $Sprite2D;
@onready var state_machine: StateChart = $StateMachine;
@onready var animation_player: AnimationPlayer = $AnimationPlayer;

var targets: Array[Mob] = [];
var target: Mob;
var current_point: int = 0;
var path_points: PackedVector2Array;

enum AttackType {
	MELEE,
	RANGED
}

enum DamageType {
	MAGICAL,
	PHYSICAL
}

func set_path(path: Path2D) -> void:
	self.current_point = 0;
	var count: int = path.curve.point_count;
	self.path_points.resize(count);
	for i in range(count):
		self.path_points[i] = path.to_global(path.curve.get_point_position(i));

func set_data(mob: MobData) -> void:
	self.life_damage = mob.life_damage;
	self.damage = mob.damage;
	self.damage_type = mob.damage_type;
	self.attack_type = mob.attack_type;
	self.attack_interval = mob.attack_interval;
	if self.attack_area_collision_shape.shape is CircleShape2D:
		var circle: CircleShape2D = self.attack_area_collision_shape.shape as CircleShape2D;
		circle.radius = mob.attack_range;
	self.speed = mob.speed;
	self.life = mob.life;
	self.physical_resistance = mob.physical_resistance;
	self.magical_resistance = mob.magical_resistance;
	self.is_enemy = mob.is_enemy;
	self.sprite.texture = mob.texture;
	self.sprite.offset = mob.texture_offset;
	self.sprite.modulate = mob.modulate;
	self.visible = true;

func move_to_point(global_point: Vector2) -> void:
	self.path_points.resize(1);
	self.path_points[0] = global_point;
	self.current_point = 0;

func move_to_mob(mob: Mob) -> void:
	self.path_points.resize(1);
	self.path_points[0] = mob.global_position;
	self.current_point = 0;

func attack() -> void:
	# NOTE: Use o self.target para obter os dados do alvo
	# TODO: Atáque a distância físico
	# TODO: Atáque adistância mágico
	# TODO: Atáque ataque corpor a corpo físico
	# TODO: Atáque ataque corpor a corpo mágico
	pass;

func _ready() -> void:
	self.visible = false;

func _process(delta: float) -> void:
	if self.velocity.is_zero_approx():
		self.animation_player.stop(true);
	else:
		self.animation_player.play("walking");

func _on_attacking_state_processing(delta: float) -> void:
	if _attack_timer > 0.0: _attack_timer -= delta;
	var target_is_valid: bool = self.target && is_instance_valid(self.target);
	if !target_is_valid && self.targets.size() > 0:
		self.target = null;
		var nearest: Mob = self.targets[0];
		var nearest_distance: float = nearest.global_position.distance_to(self.global_position);
		for target in self.targets.filter(func(candidate: Mob): return is_instance_valid(candidate)):
			if is_instance_valid(target):
				var distance: float = target.global_position.distance_to(self.global_position);
				if distance < nearest_distance:
					distance = nearest_distance;
					nearest = target;
		if is_instance_valid(nearest):
			self.target = nearest;
	elif target_is_valid && _attack_timer <= 0.0:
		self.attack();
		_attack_timer = attack_interval;

func _on_walking_state_physics_processing(delta: float) -> void:
	if !self.visible || self.path_points.is_empty() || self.current_point >= self.path_points.size(): 
		self.velocity = Vector2.ZERO;
		self.move_and_slide();
		return;
	
	var destiny: Vector2 = self.path_points[self.current_point];
	var distance: float = self.global_position.distance_to(destiny);
	
	if self.global_position.distance_to(destiny) < 4.0:
		self.current_point += 1;
		if self.current_point >= self.path_points.size():
			self.velocity = Vector2.ZERO;
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

func _on_attack_area_2d_body_entered(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy != self.is_enemy:
		var mob: Mob = body as Mob; 
		self.targets.append(mob);
		self.state_machine.send_event("to_attack");

func _on_attack_area_2d_body_exited(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy != self.is_enemy:
		var mob: Mob = body as Mob;
		if self.targets.has(mob):
			self.targets.erase(mob);
