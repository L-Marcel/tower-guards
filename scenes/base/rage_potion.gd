class_name RagePotion
extends TextureButton

@export var rage_potion: AudioStreamPlayer;

var used: bool = true;

func _ready() -> void:
	self.update.call_deferred();

func update() -> void:
	await self.get_tree().create_timer(0.1).timeout;
	self.used = !Level.get_instance().rage;

func use() -> void:
	if !self.used:
		self.rage_potion.play();
		Tower.global_interval_reduction = 0.75;
		self.used = true;
		await self.get_tree().create_timer(12).timeout;
		Tower.global_interval_reduction = 0;

func _pressed() -> void:
	self.use();

func _process(_delta: float) -> void:
	if self.used:
		self.modulate.a = 0.2;
	else:
		self.modulate.a = 1.0;
	if Input.is_action_pressed("rage_potion"):
		self.use();
