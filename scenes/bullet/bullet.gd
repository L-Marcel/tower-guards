extends Area2D

var target = null
var speed: float = 400
var damage: int

func setup(start_position: Vector2, t_target):
	global_position = start_position
	target = t_target

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if target == null or !is_instance_valid(target):
		queue_free()
		return
	
	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_enemy:
		body.queue_free()
		queue_free()
