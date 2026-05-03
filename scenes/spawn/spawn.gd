class_name Spawn
extends Node2D

@onready var timer: SpawnTimer = $SpawnTimer;
@export var _paths: Array[Path2D];
@export var _waves: Array[Wave];
var _waves_in_queue: int = 0;

#region Controle individual
func is_finished() -> bool:
	return SpawnManager.get_instance()._wave > self._waves.size() && self._waves_in_queue < 1;
func _ready() -> void:
	SpawnManager.get_instance()._spawns.append(self);
func _start_next_wave(wave_index: int) -> void:
	self._waves_in_queue += 1;
	# não é necessário subtrair 1 para verificar o tamanho, 
	# considere que comeca na onda 1, então não mexa
	if wave_index > self._waves.size(): 
		self._waves_in_queue -= 1;
		SpawnManager.get_instance()._check_current_waves();
		return;
	assert(self._paths.size() > 0);
	var wave: Wave = self._waves[wave_index - 1];
	await self.timer.start(wave.start_delay).timeout;
	for enemy in wave.enemies:
		var amount: int = enemy.amount;
		while amount > 0:
			self._spawn(enemy.enemy);
			amount -= 1;
			await self.get_tree().create_timer(enemy.interval, false).timeout;
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
