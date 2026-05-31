@tool
class_name FreezeArea
extends AttackArea2D

@export_range(0.0, 0.4) var resistence_reduction: float;
@export_range(0.0, 0.8) var slow: float;
@export var duration: float = 12.0;
@onready var area_sound: AudioStreamPlayer2D = $FreezeAreaSound;

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
			target.resistence_reduction = 0;
			target.freeze_slow = 0;
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
			target.resistence_reduction = self.resistence_reduction;
			target.freeze_slow = self.slow;
		await self.get_tree().create_timer(self.duration).timeout;
		self.finished = true;
		for target in self.get_targets():
			target.resistence_reduction = 0;
			target.freeze_slow = 0;

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
			mob.resistence_reduction = self.resistence_reduction;
			mob.freeze_slow = self.slow;
func _on_2d_body_exited(body: Node2D) -> void:
	if body is Mob && (body as Mob).is_enemy:
		var mob: Mob = body as Mob;
		self.enemies_in_range.erase(mob);
		if self.active && !self.finished:
			mob.resistence_reduction = 0;
			mob.freeze_slow = 0;
