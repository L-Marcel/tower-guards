class_name Menu
extends Control
	
@onready var text_label: Label = $PanelContainer/VBoxContainer/CenterContainer/TextLabel;
@onready var button_container: VBoxContainer = $PanelContainer/VBoxContainer/ButtonContainer;
@onready var resume_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/Resume;
@onready var next_level_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/NextLevel;
@onready var restart_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/Restart;
@onready var quit_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/Quit;
@onready var sound_slider: HSlider = $PanelContainer/VBoxContainer/ButtonContainer/SoundContainer/SoundSlider;
@onready var sound_lavel: Label = $PanelContainer/VBoxContainer/ButtonContainer/SoundContainer/SoundLabel;

var ended: bool = false;
var master_bus_index: int;

func _ready() -> void:
	self.visible = false;
	self.master_bus_index = AudioServer.get_bus_index("Master");
	self.sound_slider.value_changed.connect(self._on_volume_changed);
	self._load_volume();
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") && !self.ended:
		if self.get_tree().paused: self.resume();
		else: self.pause();

#region HUD
func grab_button_focus() -> void:
	for child in self.button_container.get_children():
		if child is Button && (child as Button).visible:
			(child as Button).grab_focus();
			break;
func handle_menu(option: String) -> void:
	match option:
		"resume": self.resume();
		"next": self.next();
		"restart": self.restart();
		"quit": self.quit();
func end(win: bool):
	if !self.ended:
		self.pause();
		self.ended = true;
		if win: self.text_label.text = "PARABÉNS!";
		else: self.text_label.text = "FIM DE JOGO!";
		self.resume_button.visible = false;
		self.text_label.visible = true;
		self.visible = true;
func pause() -> void:
	self.get_tree().paused = true;
	self.next_level_button.visible = !!Level.get_instance().next_level;
	self.visible = true;
	self.grab_button_focus();
func resume() -> void:
	self.visible = false;
	self.get_tree().paused = false;
func next() -> void:
	self.resume();
	var level: PackedScene = Level.get_instance().next_level;
	if level:
		self.get_tree().change_scene_to_packed(level);
func restart() -> void:
	self.resume();
	SpawnManager.get_instance().reset_waves();
	self.get_tree().reload_current_scene();
func quit() -> void:
	self.get_tree().quit();
#endregion

#region Sound
func _on_volume_changed(value: float) -> void:
	self.sound_lavel.text = String.num_int64(int(value)) + "%";
	value /= 100.0;
	AudioServer.set_bus_volume_db(self.master_bus_index, linear_to_db(value));
	self._save_volume(value);
func _save_volume(value: float) -> void:
	var config: ConfigFile = ConfigFile.new();
	config.set_value("audio", "master_volume", value);
	config.save("user://settings.cfg");
func _load_volume() -> void:
	var config: ConfigFile = ConfigFile.new();
	var default_volume: float = 1.0;
	if config.load("user://settings.cfg") == OK:
		default_volume = config.get_value("audio", "master_volume", 1.0);
	self.sound_slider.set_value_no_signal(default_volume * 100.0);
	self.sound_lavel.text = String.num_int64(int(default_volume * 100.0)) + "%";
	AudioServer.set_bus_volume_db(self.master_bus_index, linear_to_db(default_volume));
#endregion
