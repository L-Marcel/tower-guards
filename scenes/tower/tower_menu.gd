class_name TowerMenu
extends Node2D

@export var tower: Tower;
@onready var base_menu: Node2D = $BaseMenu;
@onready var upgrade_menu: Node2D = $UpgradeMenu;
@onready var end_menu: Node2D = $EndMenu;
@onready var label: Label = $Label;
@onready var sprite: Sprite2D = $Sprite2D;

@onready var upgrade_menu_spawn_point_option: Node2D = $UpgradeMenu/SpawnPoint;
@onready var end_menu_spawn_point_option: Node2D = $EndMenu/SpawnPoint;
@onready var areas: Array[Area2D] = [
	$BaseMenu/Archer/Archer,
	$BaseMenu/Wizard/Wizard,
	$BaseMenu/Soldier/Soldier,
	$UpgradeMenu/Upgrade/Upgrade,
	$UpgradeMenu/Sell/Sell,
	$UpgradeMenu/SpawnPoint/SpawnPoint,
	$EndMenu/Sell/Sell,
	$EndMenu/SpawnPoint/SpawnPoint
];

func open_base_menu() -> void:
	self.base_menu.visible = true;
	self.upgrade_menu.visible = false;
	self.end_menu.visible = false;
	self.sprite.visible = true;
	self.label.visible = true;
	self.upgrade_menu_spawn_point_option.visible = false;
	self.end_menu_spawn_point_option.visible = false;

func open_upgrade_menu() -> void:
	self.base_menu.visible = false;
	self.upgrade_menu.visible = true;
	self.end_menu.visible = false;
	self.sprite.visible = true;
	self.label.visible = true;
	if self.tower.type == Tower.TowerType.BARRACK:
		self.upgrade_menu_spawn_point_option.visible = true;
	self.end_menu_spawn_point_option.visible = false;

func open_end_menu() -> void:
	self.base_menu.visible = false;
	self.upgrade_menu.visible = false;
	self.end_menu.visible = true;
	self.sprite.visible = true;
	self.label.visible = true;
	if self.tower.type == Tower.TowerType.BARRACK:
		self.end_menu_spawn_point_option.visible = true;
	self.upgrade_menu_spawn_point_option.visible = false;

func close_menu() -> void:
	self.base_menu.visible = false;
	self.upgrade_menu.visible = false;
	self.end_menu.visible = false;
	self.sprite.visible = false;
	self.label.visible = false;
	self.upgrade_menu_spawn_point_option.visible = false;
	self.end_menu_spawn_point_option.visible = false;

func _on_spawn_point_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		self.tower.start_change_spawn_point_mode();
		self.close_menu();

func _on_wizard_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		self.tower.buy_wizard();
		self.close_menu();

func _on_soldier_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		self.tower.buy_barrack();
		self.close_menu();

func _on_archer_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		self.tower.buy_archer();
		self.close_menu();

func _on_upgrade_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		match self.tower.type:
			Tower.TowerType.ARCHER: self.tower.buy_archer();
			Tower.TowerType.WIZARD: self.tower.buy_wizard();
			_: self.tower.buy_barrack();
		self.close_menu();

func _on_sell_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		self.tower.sell();
		self.close_menu();

func _on_wizard_mouse_entered() -> void:
	self.label.text = "-$" + String.num_int64(
		self.tower.tower_wizard_datas[0].cost
	);

func _on_soldier_mouse_entered() -> void:
	self.label.text = "-$" + String.num_int64(
		self.tower.tower_barrack_datas[0].cost
	);

func _on_archer_mouse_entered() -> void:
	self.label.text = "-$" + String.num_int64(
		self.tower.tower_archer_datas[0].cost
	);

func _on_upgrade_mouse_entered() -> void:
	if self.tower.level >= 3: 
		self.label.text = "";
		return;
	match self.tower.type:
		Tower.TowerType.ARCHER: 
			self.label.text = "-$" + String.num_int64(
				self.tower.tower_archer_datas[self.tower.level].cost
			);
		Tower.TowerType.WIZARD: 
			self.label.text = "-$" + String.num_int64(
				self.tower.tower_wizard_datas[self.tower.level].cost
			);
		_: 
			self.label.text = "-$" + String.num_int64(
				self.tower.tower_barrack_datas[self.tower.level].cost
			);

func _on_sell_mouse_entered() -> void:
	match self.tower.type:
		Tower.TowerType.ARCHER: 
			self.label.text = "+$" + String.num_int64(
				self.tower.current_tower_archer_data.sell_value
			);
		Tower.TowerType.WIZARD: 
			self.label.text = "+$" + String.num_int64(
				self.tower.current_tower_wizard_data.sell_value
			);
		_: 
			self.label.text = "+$" + String.num_int64(
				self.tower.current_tower_barrack_data.sell_value
			);

func _on_option_mouse_exited() -> void:
	self.label.text = "";
