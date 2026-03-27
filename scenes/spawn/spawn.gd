class_name Spawn
extends Node2D

@export var _paths: Array[Path2D];
@export var _waves: Array[Wave];
var _waves_in_queue: int = 0;

static var _spawns: Array[Spawn] = [];
static var _wave: int = 0;
static func _go_next_wave() -> void:
	Spawn._wave += 1;
	for spawn in Spawn._spawns:
		spawn._start_next_wave(Spawn._wave);
static func _check_current_waves() -> void:
	for spawn in Spawn._spawns:
		if spawn._waves_in_queue > 0:
			return;
	Spawn._go_next_wave();
static func start_waves() -> void:
	if Spawn._wave < 1:
		Spawn._go_next_wave();
static func get_current_wave() -> int:
	return Spawn._wave;

func _ready() -> void:
	Spawn._spawns.append(self);

func _start_next_wave(wave_index: int) -> void:
	self._waves_in_queue += 1;
	# não é necessário subtrair 1 para verificar o tamanho, 
	# considere que comeca na onda 1
	if wave_index > self._waves.size(): return;
	assert(self._paths.size() > 0);
	var wave: Wave = self._waves[wave_index - 1];
	await self.get_tree().create_timer(wave.start_delay).timeout;
	for enemy in wave.enemies:
		var amount: int = enemy.amount;
		while amount > 0:
			self._spawn(enemy.enemy);
			amount -= 1;
			await self.get_tree().create_timer(enemy.interval).timeout;
	self._waves_in_queue -= 1;
	Spawn._check_current_waves();

func _spawn(enemy: MobData) -> void:
	var packed_scene: PackedScene = Preloader.get_resource("mob");
	var instance: Mob = packed_scene.instantiate();
	instance.global_position = self.global_position;
	instance.set_path(self._paths.pick_random());
	instance.ready.connect(func(): instance.set_data(enemy), CONNECT_ONE_SHOT);
	Enemies.get_instance().add_child(instance);
