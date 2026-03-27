@tool
class_name Paths
extends Node2D

static var _instance: Paths;
static func get_instance() -> Paths:
	return Paths._instance;

func _ready() -> void:
	Paths._instance = self;
	if Engine.is_editor_hint():
		self.child_entered_tree.connect(self._child_entered_tree);
		self.child_exiting_tree.connect(self._child_exiting_tree);
	else:
		self._update_paths_modulates();

func _get_configuration_warnings() -> PackedStringArray:
	for child in get_children():
		if not child is Path2D:
			return ["Este nó aceita exclusivamente filhos do tipo Path2D."];;
	return [];

func _child_entered_tree(node: Node) -> void:
	self.update_configuration_warnings();
	if node is Path2D:
		node.modulate = Color.from_hsv(randf(), 0.8, 1.0);

func _child_exiting_tree(_node: Node) -> void:
	self.update_configuration_warnings();

func _update_paths_modulates() -> void:
	for child in self.get_children():
		if child is Path2D:
			child.modulate = Color.from_hsv(randf(), 0.8, 1.0);
