class_name Bullet
extends Node2D

@export var speed: float = 300.0;
@export var max_virtual_height: float = 60.0;
@export var trail_length: int = 15;

@onready var virtual: Node2D = $Virtual;
@onready var sprite: Sprite2D = $Virtual/Sprite2D;
@onready var bullet_collision_sound: AudioStreamPlayer2D = $Virtual/BulletCollisionSound;
@onready var trail: Line2D = $Virtual/Line2D;

var initial_virtual_height: float = 60.0;
var start_position: Vector2 = Vector2.ZERO;
var end_position: Vector2 = Vector2.ZERO;
var enemies_in_range: Array[Mob] = [];

var target: Mob = null;
var progress: float = 0.0;
var duration: float = 0.5;
var damage: float = 0;
var finished: bool = false;
var jumps: int = 0;

func setup(
	_start_position: Vector2, 
	_target: Mob,
	_damage: float,
	origin: Vector2,
	_jumps: int,
) -> void:
	self.damage = _damage;
	if randi() % 2 == 0:
		self.max_virtual_height *= -1;
	self.start_position = _start_position + Vector2(origin.x, 0);
	self.initial_virtual_height = -origin.y;
	self.target = _target;
	if is_instance_valid(self.target):
		self.end_position = self.target.global_position - Vector2(0, 25);
	var distance: float = self.start_position.distance_to(self.end_position);
	if self.speed > 0:
		self.duration = distance / self.speed;
	else:
		self.duration = 0.1;
	self.global_position = self.start_position;
	self.jumps = _jumps;

func finish() -> void:
	self.finished = true;
	if is_instance_valid(self.target):
		self.target.hurt(self.damage, Mob.DamageType.MAGICAL);
	if self.jumps > 0:
		var next_target: Mob = self.get_target(1);
		if is_instance_valid(next_target):
			self.shot_bullet(next_target);
	self.bullet_collision_sound.play();
	var tween: Tween = self.get_tree().create_tween();
	tween.tween_property(self.trail, "modulate:a", 0.0, 0.3);
	if self.bullet_collision_sound.playing:
		await self.bullet_collision_sound.finished;
	if tween.is_running():
		await tween.finished;
	self.queue_free();

func _ready() -> void:
	self.trail.top_level = true;
	self.trail.clear_points();

func _process(delta: float) -> void:
	self.progress = clamp(self.progress + (delta / self.duration), 0.0, 1.0);
	var eased_progress: float = self.progress * self.progress;
	if is_instance_valid(self.target):
		self.end_position = self.target.global_position - Vector2(0, 25);
	self.global_position = self.start_position.lerp(self.end_position, eased_progress);
	
	var visual_start: Vector2 = self.start_position + Vector2(0, -self.initial_virtual_height);
	var visual_mid: Vector2 = (visual_start + self.end_position) / 2.0;
	visual_mid.y -= self.max_virtual_height;
	
	var virtual_position: Vector2 = (
		(1 - eased_progress) * (1 - eased_progress) * visual_start
	) + (2 * (1 - eased_progress) * eased_progress * visual_mid) + (
		eased_progress * eased_progress * self.end_position
	);
	
	self.virtual.global_position = virtual_position;
	
	var tangent: Vector2 = (
		2 * (1 - eased_progress) * (visual_mid - visual_start)
	) + (2 * eased_progress * (self.end_position - visual_mid));
	
	self.virtual.rotation = tangent.angle() + PI / 2;
	
	if eased_progress >= 0.5 && eased_progress < 0.75:
		self.sprite.z_index = 1;
	
	if self.visible:
		self.trail.add_point(self.virtual.global_position);
		if self.trail.get_point_count() > self.trail_length:
			self.trail.remove_point(0);
	
	if eased_progress >= 1.0 && !self.finished:
		self.finish();
	self.visible = eased_progress < 1.0;

func shot_bullet(_target: Mob) -> void:
	var scene: PackedScene = Preloader.get_resource("bullet");
	var bullet: Bullet = scene.instantiate();
	bullet.visible = false;
	self.get_parent().add_child(bullet);
	for point in self.trail.points:
		bullet.trail.add_point(point);
	bullet.setup(
		self.global_position, 
		_target,
		self.damage * 0.75,
		Vector2.ZERO,
		self.jumps - 1
	);

#region Target
func get_target(index: int = 0) -> Mob:
	self.enemies_in_range = self.enemies_in_range.filter(func(enemy: Mob) -> bool:
		return is_instance_valid(enemy);
	);
	
	if self.enemies_in_range.size() < index + 1: return null;
	return self.enemies_in_range[index];
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		self.enemies_in_range.append(body as Mob);
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		self.enemies_in_range.erase(body as Mob);
#endregion
