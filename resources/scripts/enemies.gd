class_name Enemies
extends Node2D

static var _instance: Enemies;
static func get_instance() -> Enemies:
	return Enemies._instance;

func _ready() -> void:
	Enemies._instance = self;
