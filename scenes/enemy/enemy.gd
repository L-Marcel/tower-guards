class_name Enemy
extends CharacterBody2D

@export_range(100, 500, 1) var speed: float = 100;
var current_point: int = 0;
var path_points: PackedVector2Array;

func _ready() -> void:
	self._setup.call_deferred();

func _setup() -> void:
	await self.get_tree().physics_frame;
	self._update_path();

func _update_path() -> void:
	var paths: Array[Path2D] = Paths.get_instance().get_paths();
	if paths:
		var path: Path2D = paths.pick_random();
		var local_points: PackedVector2Array = path.curve.get_baked_points();
		self.path_points.resize(local_points.size());
		for i in range(local_points.size()):
			self.path_points[i] = path.to_global(local_points[i]);
	else:
		await self.get_tree().create_timer(1.0).timeout;
		self._update_path();

func _physics_process(delta: float) -> void:
	if self.path_points.is_empty() || self.current_point >= self.path_points.size(): 
		return;
	
	var target: Vector2 = self.path_points[self.current_point];
	if self.global_position.distance_to(target) < 4.0:
		self.current_point += 1;
		return;
	
	self.velocity = self.global_position.direction_to(target) * self.speed * delta * 25;
	self.move_and_slide();
