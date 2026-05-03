class_name SpawnTimer
extends TextureProgressBar

@onready var timer: Timer = $Timer;

signal timeout;

func _ready() -> void:
	self.timer.timeout.connect(self.timeout.emit);

func start(time: float) -> SpawnTimer:
	self.timer.start(time);
	return self;

func skip() -> void:
	var stopped: bool = self.timer.is_stopped();
	self.timer.stop();
	if !stopped: self.timeout.emit();

func _process(_delta: float) -> void:
	if self.timer && self.timer.wait_time > 0:
		self.value = (
			(self.timer.wait_time - self.timer.time_left) / self.timer.wait_time
		) * 100.0;
	else:
		self.value = 0;
	self.visible = !self.timer.is_stopped();

func _on_gui_input(event: InputEvent) -> void:
	if self.visible && event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		self.skip();
