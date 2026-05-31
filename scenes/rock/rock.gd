class_name Rock
extends Node2D

@export var speed: float = 500.0;
@export var max_virtual_height: float = 120.0;
@onready var virtual: Node2D = $Virtual;
@onready var sprite: Sprite2D = $Virtual/Sprite2D;
@onready var rock_collision_sound: AudioStreamPlayer2D = $Virtual/RockCollisionSound;
@onready var animation_player: AnimationPlayer = $AnimationPlayer;
@onready var animated_sprite_one: AnimatedSprite2D = $AnimatedSprite2D1;
@onready var animated_sprite_two: AnimatedSprite2D = $AnimatedSprite2D2;

var initial_virtual_height: float = 60.0;
var start_position: Vector2 = Vector2.ZERO;
var end_position: Vector2 = Vector2.ZERO;
var animation_started: bool = false;

var enemies_in_range: Array[Mob] = [];
var target: Mob = null;
var progress: float = 0.0;
var duration: float = 0.5;
var damage: float = 0;
var finished: bool = false;

func setup(
	_start_position: Vector2, 
	_target: Mob,
	_damage: float,
	origin: Vector2
) -> void:
	self.damage = _damage;
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

func finish() -> void:
	self.finished = true;
	if is_instance_valid(self.target):
		self.target.hurt(self.damage, Mob.DamageType.PHYSICAL);
	for _target in self.get_targets():
		if _target != self.target:
			_target.hurt(self.damage * 0.8, Mob.DamageType.PHYSICAL);
	self.rock_collision_sound.play();
	if self.rock_collision_sound.playing:
		await self.rock_collision_sound.finished;
	if self.animation_player.is_playing():
		await self.animation_player.animation_finished;
	self.queue_free();

func _process(delta: float) -> void:
	self.progress = clamp(self.progress + (delta / self.duration), 0.0, 1.0);
	if is_instance_valid(self.target) && !self.finished:
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

	#var tangent: Vector2 = (
		#2 * (1 - self.progress) * (visual_mid - visual_start)
	#) + (2 * self.progress * (self.end_position - visual_mid));
	
	if self.progress >= 0.5 && self.progress < 0.75:
		self.sprite.z_index = 1;
	elif self.progress >= 0.75:
		self.sprite.z_index = 0;
	
	if !self.finished:
		self.virtual.rotation += delta * 5.0;
	
	var time_remaining: float = (1.0 - self.progress) * self.duration;
	if !self.finished && !self.animation_started && time_remaining <= 0.2:
		self.animation_started = true;
		self.animation_player.play("explosion");
		
	if !self.finished:
		self.sprite.visible = true;
	if self.progress >= 1.0 && !self.finished:
		self.finish();
	self.visible = true;

#region Target
func get_targets() -> Array[Mob]:
	self.enemies_in_range = self.enemies_in_range.filter(func(enemy: Mob) -> bool:
		return is_instance_valid(enemy);
	);
	return self.enemies_in_range;
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		self.enemies_in_range.append(body as Mob);
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		self.enemies_in_range.erase(body as Mob);
#endregion
