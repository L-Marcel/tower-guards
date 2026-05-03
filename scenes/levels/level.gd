class_name Level
extends Node2D

static var _instance: Level;
static func get_instance() -> Level:
	return Level._instance;

@export var next_level: PackedScene;

func _ready() -> void:
	Level._instance = self;
