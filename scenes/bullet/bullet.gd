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

var target: Mob = null;
var progress: float = 0.0;
var duration: float = 0.5;
var damage: int = 0;
var finished: bool = false;

func setup(
	_start_position: Vector2, 
	_target: Mob,
	_damage: int,
	origin: Vector2
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

func finish(mob : Mob = null) -> void:
	self.finished = true;
	if mob != null && is_instance_valid(mob):
		mob.hurt(self.damage, Mob.DamageType.MAGICAL);
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
	if is_instance_valid(self.target):
		self.end_position = self.target.global_position - Vector2(0, 25);
	self.global_position = self.start_position.lerp(self.end_position, self.progress);
	
	var visual_start: Vector2 = self.start_position + Vector2(0, -self.initial_virtual_height);
	var visual_mid: Vector2 = (visual_start + self.end_position) / 2.0;
	visual_mid.y -= self.max_virtual_height;
	
	var virtual_position: Vector2 = (
		(1 - self.progress) * (1 - self.progress) * visual_start
	) + (2 * (1 - self.progress) * self.progress * visual_mid) + (
		self.progress * self.progress * self.end_position
	);
	
	self.virtual.global_position = virtual_position;
	
	var tangent: Vector2 = (
		2 * (1 - self.progress) * (visual_mid - visual_start)
	) + (2 * progress * (self.end_position - visual_mid));
	
	self.virtual.rotation = tangent.angle() + PI / 2;
	
	if self.progress >= 0.5 && self.progress < 0.75:
		self.sprite.z_index = 1;
	elif self.progress >= 0.75:
		self.sprite.z_index = 0;
	
	if !self.finished:
		self.trail.add_point(self.virtual.global_position);
		if self.trail.get_point_count() > self.trail_length:
			self.trail.remove_point(0);
	
	if self.progress >= 1.0 && !self.finished:
		self.finish();
	self.visible = self.progress < 1.0;

func _on_area_2d_body_entered(body: Node2D) -> void:
	if self.finished && body is Mob && (body as Mob).is_enemy:
		var mob: Mob = body as Mob;
		if self.target == mob:
			self.finish(self.target);
