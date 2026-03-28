class_name BaseAlias
extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		var mob: Mob = body as Mob;
		mob.queue_free();
		Base.get_instance().lifes -= mob.life_damage;
