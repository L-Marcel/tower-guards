@tool
class_name PoisonArea
extends AttackArea2D

@export_custom(PROPERTY_HINT_NONE, "suffix:health/s") var damage: float = 5;
@export_range(0.0, 0.4) var slow: float;
@export var duration: float = 12.0;
@onready var area_sound: AudioStreamPlayer2D = $PoisonAreaSound;

var focused: bool = false;
var active: bool = false;
var finished: bool = false;

func _ready() -> void:
	super._ready();
	self.collision_shape.updated.connect(self.queue_redraw);

func _process(_delta: float) -> void:
	self.visible = self.focused || self.active;
	if self.finished:
		self.visible = false;
		for target in self.get_targets():
			target.regeneration = 0;
			target.poison_slow = 0;
		self.process_mode = Node.PROCESS_MODE_DISABLED;

func _physics_process(_delta: float) -> void:
	if self.focused && !self.active:
		self.global_position = self.get_global_mouse_position();

func activate() -> void:
	if !self.active:
		self.area_sound.play();
		self.active = true;
		self.focused = false;
		self.is_alternative = false;
		for target in self.get_targets():
			target.regeneration = -self.damage;
			target.poison_slow = self.slow;
		await self.get_tree().create_timer(self.duration).timeout;
		self.finished = true;
		for target in self.get_targets():
			target.regeneration = 0;
			target.poison_slow = 0;

func _unhandled_input(event: InputEvent) -> void:
	if self.focused && event is InputEventMouseButton && event.is_pressed():
		if event.button_index == MOUSE_BUTTON_RIGHT:
			self.focused = false;
		if event.button_index == MOUSE_BUTTON_LEFT:
			self.activate();

func _on_2d_body_entered(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		var mob: Mob = body as Mob;
		self.enemies_in_range.append(mob);
		if self.active && !self.finished:
			mob.regeneration = -self.damage;
			mob.poison_slow = self.slow;
func _on_2d_body_exited(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		var mob: Mob = body as Mob;
		self.enemies_in_range.erase(mob);
		if self.active && !self.finished:
			mob.regeneration = 0;
			mob.poison_slow = 0;
