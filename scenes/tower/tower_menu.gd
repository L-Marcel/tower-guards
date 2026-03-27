class_name TowerMenu
extends Node2D

@onready var base_menu: Node2D = $BaseMenu;
@onready var upgrade_menu: Node2D = $UpgradeMenu;
@onready var end_menu: Node2D = $EndMenu;
@onready var label: Label;

func _on_mage_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		print("MAGE!");

func _on_soldier_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		print("SOLDIER!");

func _on_archer_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		print("ARCHER!");

func _on_upgrade_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		print("UPGRADE!");

func _on_sell_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		print("SELL!");

func _on_mage_mouse_entered() -> void:
	print("MAGE MOUSE!");
	pass;

func _on_soldier_mouse_entered() -> void:
	print("SOLDIER MOUSE!");
	pass;

func _on_archer_mouse_entered() -> void:
	print("ARCHER MOUSE!");
	pass;

func _on_upgrade_mouse_entered() -> void:
	print("UPGRADE MOUSE!");
	pass;

func _on_sell_mouse_entered() -> void:
	print("SELL MOUSE!");
	pass;

func _on_option_mouse_exited() -> void:
	print("CLEAR!");
	pass;
