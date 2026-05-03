class_name Spawns
extends Node2D

func _ready() -> void:
	self._start_spawns.call_deferred();

func _start_spawns() -> void:
	await self.get_tree().create_timer(1).timeout;
	SpawnManager.get_instance().start_waves();
