class_name Menu
extends Control
	
@onready var text_label: Label = $PanelContainer/VBoxContainer/CenterContainer/TextLabel;
@onready var button_container: VBoxContainer = $PanelContainer/VBoxContainer/ButtonContainer;
@onready var resume_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/Resume;
@onready var next_level_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/NextLevel;
@onready var restart_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/Restart;
@onready var quit_button: Button = $PanelContainer/VBoxContainer/ButtonContainer/Quit;
var ended: bool = false;

func _ready() -> void:
	self.visible = false;
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") && !self.ended:
		if self.get_tree().paused: self.resume();
		else: self.pause();
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
	self.visible = true;
func resume() -> void:
	self.visible = false;
	self.get_tree().paused = false;
func next() -> void:
	self.resume();
	pass;
func restart() -> void:
	self.resume();
	self.get_tree().reload_current_scene();
	Spawn.reset_waves();
func quit() -> void:
	self.get_tree().quit();
