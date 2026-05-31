class_name PoisonPotion
extends TextureButton

@export var area: PoisonArea;

var used: bool = true;

func _ready() -> void:
	self.update.call_deferred();

func update() -> void:
	await self.get_tree().create_timer(0.1).timeout;
	self.used = !Level.get_instance().poison;

func use() -> void:
	if !self.used && !self.area.active && !self.area.focused:
		self.area.focused = true;
	elif self.area.focused:
		self.area.focused = false;

func _pressed() -> void:
	self.use();

func _process(_delta: float) -> void:
	if self.used:
		self.modulate.a = 0.2;
	else:
		self.modulate.a = 1.0;
	if Input.is_action_just_pressed("poison_potion"):
		self.use();
	if self.area.focused:
		self.modulate.a = 0.75;
	elif self.area.active || self.area.finished:
		self.modulate.a = 0.2;
