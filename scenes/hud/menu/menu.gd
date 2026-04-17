class_name Menu
extends Control

static var _instance: Menu;
static func get_instance() -> Menu:
	return Menu._instance;
	
@onready var textlabel: Label = $PanelContainer/textlabel
@onready var buttoncontainer: VBoxContainer = $PanelContainer/buttoncontainer
@onready var resume: Button = $PanelContainer/buttoncontainer/resume
@onready var nextlevelbutton: Button = $PanelContainer/buttoncontainer/nextlevel
@onready var restartbutton: Button = $PanelContainer/buttoncontainer/restart
@onready var menubutton: Button = $PanelContainer/buttoncontainer/menu
@onready var quitbutton: Button = $PanelContainer/buttoncontainer/quit
const gameover: String = "GAME OVER!"
const congratulation: String = "CONGRATULATIONS!"

func handle_menu(option: String) -> void:
	match option:
		"next": next()
		"restart": restart()
		"mainmenu": mainmenu()
		"quit": quit()

func setgameovertext() -> void:
	textlabel.text = gameover

func setwintext() -> void:
	textlabel.text = congratulation

func end(win: bool):
	match win:
		true:
			setwintext()
		false:
			setgameovertext()
	self.resumebutton.visible = false
	textlabel.visible = true
	self.visible = true
	
func next():
	pass
func restart():
	get_tree().reload_current_scene()
func mainmenu():
	pass
func quit():
	get_tree().quit()
