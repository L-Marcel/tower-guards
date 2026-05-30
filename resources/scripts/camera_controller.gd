class_name CameraController
extends Camera2D

@export var speed: float = 1000.0;
@export var edge_margin: float = 40.0;
@export var zoom_step: float = 0.025;

var dragging: bool = false;
var drag_start_mouse: Vector2 = Vector2.ZERO;
var drag_start_camera: Vector2 = Vector2.ZERO;

func increment_zoom(step: int = 0) -> void:
	var target_zoom: float = self.zoom.x;
	target_zoom += self.zoom_step * step;
	target_zoom = clamp(target_zoom, 0.2, 0.8);
	self.zoom = Vector2(target_zoom, target_zoom);;

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP && event.is_pressed():
			self.increment_zoom(1)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && event.is_pressed():
			self.increment_zoom(-1)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				self.dragging = true;
				self.drag_start_mouse = event.position;
				self.drag_start_camera = self.global_position;
			else:
				self.dragging = false;

func _process(delta: float) -> void:
	var scroll: float = Input.get_axis("zoom_out", "zoom_in");
	self.increment_zoom(sign(scroll));
		
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down");
	var viewport_size: Vector2 = self.get_viewport_rect().size;

	if self.dragging:
		var mouse_delta: Vector2 = self.drag_start_mouse - self.get_viewport().get_mouse_position();
		self.global_position = self.drag_start_camera + mouse_delta / self.zoom;
	
	self.global_position += direction.normalized() * (self.speed * delta) / max(1, Engine.time_scale);
	var half_size: Vector2 = (viewport_size * 0.5) / self.zoom;
	self.global_position.x = clamp(self.global_position.x, self.limit_left + half_size.x, self.limit_right - half_size.x);
	self.global_position.y = clamp(self.global_position.y, self.limit_top + half_size.y, self.limit_bottom - half_size.y);
