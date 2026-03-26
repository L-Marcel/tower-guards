class_name Enemy
extends CharacterBody2D

@export_range(100, 500, 1) var speed: float = 100;

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D;

func _ready() -> void:
	self._setup.call_deferred();

func _setup() -> void:
	await self.get_tree().physics_frame;
	self._update_target();

func _update_target() -> void:
	var base: Base = Base.get_instance();
	if base: 
		self.navigation_agent.target_position = base.position;
	else:
		await self.get_tree().create_timer(1.0).timeout;
		self._update_target();

func _physics_process(delta: float) -> void:
	if self.navigation_agent.is_navigation_finished(): return;
	
	var next_position: Vector2 = self.navigation_agent.get_next_path_position();
	self.velocity = self.global_position.direction_to(next_position) * self.speed * delta * 25;;
	
	self.move_and_slide();
