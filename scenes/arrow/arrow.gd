class_name Arrow
extends Node2D

@export var speed: float = 500.0;
@export var max_virtual_height: float = 120.0;
@onready var virtual: Node2D = $Virtual;
@onready var sprite: Sprite2D = $Virtual/Sprite2D;

var initial_virtual_height: float = 60.0;
var start_position: Vector2 = Vector2.ZERO;
var end_position: Vector2 = Vector2.ZERO;

var target: Mob = null;
var progress: float = 0.0;
var duration: float = 0.5;
var damage: int = 0;
var finished: bool = false;

func setup(
	start_position: Vector2, 
	target: Mob,
	damage: int,
	origin: Vector2
) -> void:
	self.damage = damage;
	self.start_position = start_position + Vector2(origin.x, 0);
	self.initial_virtual_height = -origin.y;
	self.start_position = start_position;
	self.target = target;
	if is_instance_valid(self.target):
		self.end_position = self.target.global_position;
	var distance: float = self.start_position.distance_to(self.end_position);
	if self.speed > 0:
		self.duration = distance / self.speed;
	else:
		self.duration = 0.1;
	self.global_position = self.start_position;

func _process(delta: float) -> void:
	self.progress = clamp(self.progress + (delta / self.duration), 0.0, 1.0);
	if is_instance_valid(self.target):
		self.end_position = self.target.global_position;
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
	
	if self.progress >= 1.0 && !self.finished:
		self.finished = true;
		await self.get_tree().create_timer(1).timeout;
		self.queue_free();

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		var mob: Mob = body as Mob;
		if self.target == mob:
			mob.hurt(self.damage, Mob.DamageType.PHYSICAL);
			Sounds.play_arrow_collision_sound();
			self.queue_free();
