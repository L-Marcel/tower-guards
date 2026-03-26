class_name Base
extends Node2D

static var _instance: Base;
static func get_instance() -> Base:
	return Base._instance;

func _ready() -> void:
	Base._instance = self;
