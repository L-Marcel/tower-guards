class_name Wave
extends Resource

@export_custom(PROPERTY_HINT_NONE, "suffix:s") var start_delay: int = 10;
@export var enemies: Array[WaveEnemyData] = [];
