class_name Base
extends Node2D

@onready var label_money: Label = $CanvasLayer/Control/PanelContainer/MarginContainer/HBoxContainer/MoneyContainer/Money;
@onready var first_life: TextureRect = $CanvasLayer/Control/PanelContainer/MarginContainer/HBoxContainer/RightContainer/LifesContainer/TextureRect;
@onready var second_life: TextureRect = $CanvasLayer/Control/PanelContainer/MarginContainer/HBoxContainer/RightContainer/LifesContainer/TextureRect2;
@onready var third_life: TextureRect = $CanvasLayer/Control/PanelContainer/MarginContainer/HBoxContainer/RightContainer/LifesContainer/TextureRect3;
@onready var menu: Menu = $CanvasLayer/Menu;
@onready var label_wave: Label = $CanvasLayer/Control/PanelContainer/MarginContainer/HBoxContainer/WaveContainer/Waves;
@onready var option_button: OptionButton = $CanvasLayer/Control/PanelContainer/MarginContainer/HBoxContainer/RightContainer/SpeedContainer/OptionButton;

@export var money: int = 30:
	set(value):
		money = value;
		self.update_money();
@export var lifes: int = 3:
	set(value):
		lifes = value;
		self.update_lifes();
		Sounds.play_base_damage_sound();
		if value < 1: self.game_over();

static var _instance: Base;
static func get_instance() -> Base:
	return _instance;

func _ready() -> void:
	_instance = self;
	Sounds.play_music();
	self.update_money();
	self.update_lifes();
	await get_tree().process_frame
	self.update_waves();

func _process(_delta: float) -> void:
	self.update_waves();
	if Input.is_action_pressed("speed_one"):
		self.option_button.select(0);
		Engine.time_scale = 1;
	elif Input.is_action_pressed("speed_two"):
		self.option_button.select(1);
		Engine.time_scale = 2;
	elif Input.is_action_pressed("speed_three"):
		self.option_button.select(2);
		Engine.time_scale = 3;
	elif Input.is_action_pressed("speed_four"):
		self.option_button.select(3);
		Engine.time_scale = 4;
func _on_option_button_item_selected(index: int) -> void:
	var speed: int = index + 1;
	Engine.time_scale = float(speed);
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Mob and (body as Mob).is_enemy:
		var mob: Mob = body as Mob;
		mob.queue_free();
		self.lifes -= mob.life_damage;

func update_waves() -> void:
	self.label_wave.text = "Wave: %d/%d" % [
		SpawnManager.get_instance().get_current_wave(),
		SpawnManager.get_instance().get_max_wave()
	];
func update_lifes() -> void:
	if self.first_life && self.second_life && self.third_life:
		self.first_life.visible = self.lifes >= 3;
		self.second_life.visible = self.lifes >= 2;
		self.third_life.visible = self.lifes >= 1;
func update_money() -> void:
	if self.label_money:
		self.label_money.text = "$%d" % self.money;

func win() -> void:
	self.menu.end(true);
func game_over() -> void:
	self.menu.end(false);
