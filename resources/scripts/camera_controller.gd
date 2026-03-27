class_name CameraController
extends Node2D

@export var speed: float = 1000.0;
@export var edge_margin: float = 40.0;

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
