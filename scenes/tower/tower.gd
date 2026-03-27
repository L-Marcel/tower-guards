class_name Tower
extends Node2D

@onready var area: Area2D = $Area2D;

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new();
		query.position = get_global_mouse_position();
		query.collide_with_areas = true;
		query.collide_with_bodies = false;
		var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state;
		var result: Array[Dictionary] = space_state.intersect_point(query);
		var hit_self: bool = result.any(func(hit: Dictionary): return hit["collider"] == self.area);
		if hit_self:
			get_viewport().set_input_as_handled();
