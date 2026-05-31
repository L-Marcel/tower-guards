class_name Level
extends Node2D

static var _instance: Level;
static func get_instance() -> Level:
	return Level._instance;

@export var max_tower_level: int = 1;
@export var next_level: PackedScene;

@export_group("Potions")
@export var rage: bool = true;
@export var poison: bool = false;
@export var freeze: bool = false;

func _ready() -> void:
	Level._instance = self;
	Tower.global_interval_reduction = 0;
