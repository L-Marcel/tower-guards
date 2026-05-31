@tool
class_name AttackArea2D
extends Area2D

@export var border_color: Color = Color.from_rgba8(46, 34, 47):
	set(value):
		border_color = value;
		self.queue_redraw();
@export var fill_color: Color = Color.from_rgba8(86, 152, 210):
	set(value):
		fill_color = value;
		self.queue_redraw();
@export var alternative_color: Color = Color.from_rgba8(154, 171, 178):
	set(value):
		alternative_color = value;
		self.queue_redraw();
@export var is_alternative: bool = false :
	set(value):
		is_alternative = value;
		self.queue_redraw();
@export var border_is_visible: bool = false :
	set(value):
		border_is_visible = value;
		self.queue_redraw();

@onready var collision_shape: EllipseShape2D = $CollisionPolygon2D;

var enemies_in_range: Array[Mob] = [];

func _ready() -> void:
	self.queue_redraw();
	self.body_entered.connect(self._on_2d_body_entered);
	self.body_exited.connect(self._on_2d_body_exited);

func _draw() -> void:
	if self.collision_shape && self.border_is_visible:
		if self.collision_shape.radius_x > 1.0 && self.collision_shape.radius_y > 1.0:
			var color: Color = self.alternative_color if self.is_alternative else self.fill_color;
			color.a = 0.5;
			var points: PackedVector2Array = self.collision_shape.polygon;
			if points.is_empty(): return;
			self.draw_colored_polygon(points, color);
			var border_points: PackedVector2Array = points.duplicate();
			border_points.append(points[0]);
			self.draw_polyline(border_points, self.border_color, 8.0, true);
	
#region Target
func get_targets() -> Array[Mob]:
	self.enemies_in_range = self.enemies_in_range.filter(func(enemy: Mob) -> bool:
		return is_instance_valid(enemy);
	);
	return self.enemies_in_range;
func get_target(index: int = 0) -> Mob:
	self.enemies_in_range = self.enemies_in_range.filter(func(enemy: Mob) -> bool:
		return is_instance_valid(enemy);
	);
	if self.enemies_in_range.size() < index + 1: return null;
	return self.enemies_in_range[index];
func _on_2d_body_entered(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		self.enemies_in_range.append(body as Mob);
func _on_2d_body_exited(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		self.enemies_in_range.erase(body as Mob);
#endregion
