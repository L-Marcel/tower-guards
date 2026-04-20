extends Area2D

var start_position: Vector2
var target = null
var progress := 0.0
var duration : float = 0.5
var damage : int

func setup(start, t_target):
	start_position = start
	target = t_target
	global_position = start_position

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if target == null or !is_instance_valid(target):
		queue_free()
		return	
	progress += delta / duration
	
	var end_position = target.global_position
	
	var mid = (start_position + end_position) / 2
	mid.y -= 100
	
	var position = (1 - progress) * (1 - progress) * start_position \
		+ 2 * (1 - progress) * progress * mid \
		+ progress * progress * end_position

	
	global_position = position

	var direction = target.global_position - global_position
	rotation = direction.angle() + PI/2
	
	if progress >= 1.0:
		queue_free()


# POR ENQUANTO, quando o mob é atingido pela fecha ele some imediatamente
# Fiz isso pq estou morrendo de sono e preciso muito dormir
func _on_body_entered(body: Node2D) -> void:
	if body.is_enemy:
		body.queue_free()
		queue_free()
