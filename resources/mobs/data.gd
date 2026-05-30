class_name MobData
extends Resource

@export var is_enemy: bool = true;

@export_group("Texture")
@export var texture: Texture;
@export var texture_offset: Vector2;
@export var modulate: Color = Color.WHITE;

@export_group("Attributes")
@export_range(1, 3, 1) var life_damage: int = 3;
@export_range(0, 75, 1) var damage: float = 5;
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var attack_interval: int = 4;
@export_range(0.5, 1.0) var attack_interval_randomness: float = 0.75;
@export var damage_type: Mob.DamageType = Mob.DamageType.PHYSICAL;
@export var attack_type: Mob.AttackType = Mob.AttackType.MELEE;
@export var attack_range: float = 40.0;
@export var agro_range: float = 125.0;

@export_range(0, 10, 1) var value_in_money: int = 1;
@export_range(0, 300, 1) var speed: int = 50;
@export_range(1, 300, 1) var health: float = 30;
@export_custom(PROPERTY_HINT_NONE, "suffix:health/s") var regeneration: float = 1;
@export_range(0.0, 1.0, 0.1) var physical_resistance: float = 0.0;
@export_range(0.0, 1.0, 0.1) var magical_resistance: float = 0.0;
