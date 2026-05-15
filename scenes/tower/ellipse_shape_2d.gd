@tool
class_name EllipseShape2D
extends CollisionPolygon2D

@export var radius_x: float = 32.0:
	set(value):
		radius_x = value;
		self._update_polygon();

@export var radius_y: float = 16.0:
	set(value):
		radius_y = value;
		self._update_polygon();

@export var segments: int = 32:
	set(value):
		segments = clampi(value, 8, 128);
		self._update_polygon();

func _ready() -> void:
	self._update_polygon();

func _update_polygon() -> void:
	if self.radius_x <= 0.1 || self.radius_y <= 0.1: return;
	var new_polygon: PackedVector2Array = PackedVector2Array();
	for i in range(self.segments):
		var angle: float = (float(i) / self.segments) * TAU;
		var x: float = self.radius_x * cos(angle);
		var y: float = self.radius_y * sin(angle);
		new_polygon.append(Vector2(x, y));
	self.polygon = Geometry2D.convex_hull(new_polygon);
