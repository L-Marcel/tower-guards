class_name Menu
extends Control

@onready var gameover: Label = $PanelContainer/gameover
@onready var buttoncontainer: VBoxContainer = $PanelContainer/buttoncontainer
@onready var nextlevel: Button = $PanelContainer/buttoncontainer/nextlevel
@onready var restart: Button = $PanelContainer/buttoncontainer/restart
@onready var menu: Button = $PanelContainer/buttoncontainer/menu
@onready var quit: Button = $PanelContainer/buttoncontainer/quit




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_nextlevel_pressed() -> void:
	pass # Replace with function body.


func _on_restart_pressed() -> void:
	pass # Replace with function body.


func _on_menu_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	pass # Replace with function body.
