class_name Wave
extends Resource

@export_custom(PROPERTY_HINT_NONE, "suffix:s") var start_delay: int = 10;
@export var enemies: Array[WaveEnemyData] = [];

# TODO: Depois de ter registrado as variações de inimigos em resources/mobs, precisamos crias as ondas propriamente ditas
# que ainda não foram criadas nos mapas. Take a look at resources/waves/level_01 and then 
# resources/waves/data to better understand how it works
# NOTE: Você pode reaproveitar alguns que estão no resources/waves/data,
# mas se for fazer o mesmo com os que estão nos level_0n, duplique e renomeie
# NOTE: Manter arquivo é chato, mas as vezes a Gogot buga e a gente perde mto 
# se não manter o mínimo que mais se repete em arquivos (já passei por isso)
