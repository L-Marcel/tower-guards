class_name SpawnManager
extends Node2D

static var _instance: SpawnManager;
static func get_instance() -> SpawnManager:
	return SpawnManager._instance;

var _spawns: Array[Spawn] = [];
var _wave: int = 0;

func _ready() -> void:
	self._instance = self;

#region Controle geral
func _go_next_wave() -> void:
	self._wave += 1
	
	Base.get_instance().update_waves()

	var finished: bool = self._spawns.all(func(spawn: Spawn): 
		return spawn.is_finished();
	)

	if !finished:
		for spawn in self._spawns:
			spawn._start_next_wave.call_deferred(self._wave)
	else:
		while Enemies.get_instance().get_child_count() > 0:
			await Base.get_instance().get_tree().create_timer(1.0, false).timeout
			if !self.is_inside_tree():
				return

		if self.is_inside_tree(): 
			Base.get_instance().win()
func _check_current_waves() -> void:
	for spawn in self._spawns:
		if spawn._waves_in_queue > 0:
			return;
	self._go_next_wave();
func start_waves() -> void:
	if self._wave < 1:
		self._go_next_wave();
func get_current_wave() -> int:
	return self._wave;
func reset_waves() -> void:
	self._wave = 0;
	self._spawns.clear();
#endregion
