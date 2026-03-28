class_name CameraController
extends Camera2D

@export var speed: float = 1000.0;
@export var edge_margin: float = 40.0;
@export var zoom_step: float = 0.025;

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return;
	if event is InputEventMouseButton and event.pressed:
		var target_zoom: float = self.zoom.x;
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom += self.zoom_step;
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom -= self.zoom_step;
		
		target_zoom = clamp(target_zoom, 0.2, 0.8);
		self.zoom = Vector2(target_zoom, target_zoom);

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return;
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
	
	var viewport_size: Vector2 = self.get_viewport_rect().size;
	var mouse_position: Vector2 = self.get_viewport().get_mouse_position();
	
	if mouse_position.x < self.edge_margin: direction.x -= 1.0;
	elif mouse_position.x > viewport_size.x - self.edge_margin: direction.x += 1.0;
	
	if mouse_position.y < self.edge_margin: direction.y -= 1.0;
	elif mouse_position.y > viewport_size.y - self.edge_margin: direction.y += 1.0;
	
	self.global_position += direction.normalized() * self.speed * delta;
	var half_size: Vector2 = (viewport_size * 0.5) / self.zoom;
	
	self.global_position.x = clamp(self.global_position.x, self.limit_left + half_size.x, self.limit_right - half_size.x);
	self.global_position.y = clamp(self.global_position.y, self.limit_top + half_size.y, self.limit_bottom - half_size.y);
