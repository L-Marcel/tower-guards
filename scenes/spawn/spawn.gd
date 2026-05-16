class_name Spawn
extends Node2D

@onready var timer: SpawnTimer = $SpawnTimer;
@export var _paths: Array[Path2D];
@export var _waves: Array[Wave];
var _waves_in_queue: int = 0;
var current_wave: int = 0;

#region Controle individual
func is_finished() -> bool:
	return SpawnManager.get_instance()._wave > self._waves.size() && self._waves_in_queue < 1;
func skip_wave() -> void:
	self.timer.skip();
func get_max_wave() -> int:
	return self._waves.size();
func _ready() -> void:
	self.current_wave = 0;
	SpawnManager.get_instance()._spawns.append(self);
func _start_next_wave(wave_index: int) -> void:
	self._waves_in_queue += 1;
	if wave_index > self._waves.size(): 
		self.current_wave += 1;
		self._waves_in_queue -= 1;
		SpawnManager.get_instance()._check_current_waves();
		return;
	assert(self._paths.size() > 0);
	var wave: Wave = self._waves[wave_index - 1];
	if wave.enemies.is_empty():
		self.current_wave += 1;
		self._waves_in_queue -= 1;
		SpawnManager.get_instance()._check_current_waves();
		return;
	await self.timer.start(wave.start_delay).timeout;
	self.current_wave += 1;
	for enemy in wave.enemies:
		var amount: int = enemy.amount;
		while amount > 0:
			self._spawn(enemy.enemy);
			amount -= 1;
			var interval: int = enemy.interval;
			var random_diff: float = randf_range(-0.3, 0.3);
			await self.get_tree().create_timer(float(interval) + random_diff, false).timeout;
	self._waves_in_queue -= 1;
	SpawnManager.get_instance()._check_current_waves();
func _spawn(enemy: MobData) -> void:
	var packed_scene: PackedScene = Preloader.get_resource("mob");
	var instance: Mob = packed_scene.instantiate();
	instance.global_position = self.global_position;
	instance.set_path(self._paths.pick_random());
	instance.ready.connect(func(): instance.set_data(enemy), CONNECT_ONE_SHOT);
	Enemies.get_instance().add_child(instance);
#endregion

func _on_spawn_timer_gui_input(event: InputEvent) -> void:
	if self.timer.visible && event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		SpawnManager.get_instance().skip_wave();
