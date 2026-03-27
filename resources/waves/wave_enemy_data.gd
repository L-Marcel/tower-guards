class_name WaveEnemyData
extends Resource

@export var enemy: MobData;
@export var amount: int = 1;
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var interval: int = 1;
