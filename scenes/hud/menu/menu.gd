class_name Menu
extends Control

@onready var textlabel: Label = $PanelContainer/textlabel
@onready var buttoncontainer: VBoxContainer = $PanelContainer/buttoncontainer
@onready var nextlevel: Button = $PanelContainer/buttoncontainer/nextlevel
@onready var restart: Button = $PanelContainer/buttoncontainer/restart
@onready var menu: Button = $PanelContainer/buttoncontainer/menu
@onready var quit: Button = $PanelContainer/buttoncontainer/quit
const gameover: String = "GAME OVER!"
const congratulation: String = "CONGRATULATIONS!"

func handle_menu(option: String) -> void:
	match option:
		"next": pass
		"restart": pass
		"mainmenu": pass
		"quit": get_tree().quit()

func setgameovertext() -> void:
	textlabel.text = gameover

func setwintext() -> void:
	textlabel.text = congratulation
