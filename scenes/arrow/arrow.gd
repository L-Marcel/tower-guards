class_name Arrow
extends Area2D

var start_position: Vector2 = Vector2.ZERO;
var target: Mob = null;
var progress: float = 0.0;
var duration: float = 0.5
var damage: int = 0;
var finished: bool = false;

func setup(start: Vector2, target: Mob) -> void:
	self.start_position = start;
	self.target = target;
	self.global_position = self.start_position;

func _process(delta: float) -> void:
	if self.target == null || !is_instance_valid(self.target):
		self.queue_free();
		return;
	
	self.progress += delta / self.duration;
	var end_position: Vector2 = self.target.global_position;
	
	var mid: Vector2 = (self.start_position + end_position) / 2.0;
	mid.y -= 100.0;
	
	var new_position: Vector2 = (
		(1 - progress) * (1 - progress) * self.start_position
	) + (2 * (1 - progress) * progress * mid) + (
		progress * progress * end_position
	);
	
	self.global_position = new_position;
	var direction: Vector2 = self.target.global_position - self.global_position;
	self.rotation = direction.angle() + PI/2;
	if self.progress >= 1.0 && !self.finished:
		self.finished = true;
		await self.get_tree().create_timer(1).timeout;
		self.queue_free();

func _on_body_entered(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		var mob: Mob = body as Mob;
		if self.target == mob:
			mob.hurt(self.damage, Mob.DamageType.PHYSICAL);
			self.queue_free();
