class_name MobData
extends Resource

# TODO: Precisamos de mais variações de inimigos, sugiro:
# - 1 soldado básico (nível 1), 1 médio (nível 2), 1 avançado (nível 3)
# 	- Esse implicitamente resiste a dano físico depois do primeiro nível.
# - 1 soldado resistente a magia básico, 1 médio e 1 avançado
# Os avançados com resistência podem ter uma resistência altíssima, por exemplo, 75% (0.75). 
# Mas vamos evitar a ideia de 100% (1.0).
# TODO: Precisamos de soldados para as barracas:
# - 1 soldado básico (nível 1), 1 médio (nível 2), 1 avançado (nível 3)
# Eles tem que ser um pouco mais resistentes. Se necessário, conversem entre si 
# sobre os valores, separei as tarefas para ficar mais leve...
# NOTE: Alguns sprites tem tamanho anormal, mas a colisão de todos 
# os soldadinhos é a mesma. Brinque com o offset da textura para 
# ajustar corretamente. Você verá que eu fiz isso com o primeiro.
# NOTE: Para diferenciar os inimigos, um modulate diferente dos 
# aliados (que ficam com modulate branco padrão) é interessante, 
# por isso existe. Você precisará de 2 modulates: para o inimigo 
# padrão e para o resistente a magia.

@export var is_enemy: bool = true;

@export_group("Texture")
@export var texture: Texture;
@export var texture_offset: Vector2;
@export var modulate: Color = Color.WHITE;

@export_group("Attributes")
@export_range(1, 3, 1) var life_damage: int = 3;
@export_range(0, 75, 1) var damage: int = 5;
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var attack_interval: int = 4;
@export var damage_type: Mob.DamageType = Mob.DamageType.PHYSICAL;
@export var attack_type: Mob.AttackType = Mob.AttackType.MELEE;
@export var attack_range: float = 40.0;
@export_range(2, 10, 1) var value_in_money: int = 2;
@export_range(0, 300, 1) var speed: int = 50;
@export_range(1, 300, 1) var health: int = 30;
@export_range(0.0, 1.0, 0.25) var physical_resistance: float = 0.0;
@export_range(0.0, 1.0, 0.25) var magical_resistance: float = 0.0;
const RESISTANCE_MED: float = 0.33
const RESISTANCE_HIGH: float = 0.66
