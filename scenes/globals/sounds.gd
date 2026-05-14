extends Node

# TODO: Crie os nós para cada som, coloque o arquivo de som neles
# e chame o método de play deles no método correspondente que esteja 
# aqui, se oriente pelo nome dos método deixados aqui
# NOTE: A tarefa envolve escolher os sons e a música
# NOTE: Pode pegar do itch.io
# NOTE: Deixei um exemplo aqui, logo abaixo, mas ainda precisa colocar
# a música do jogo no nó Music
# NOTE: Não se preocupe com a chamada desses métodos

@onready var music: AudioStreamPlayer = $Music;
@onready var spawn: AudioStreamPlayer = $Spawn;
@onready var base_damage: AudioStreamPlayer = $"Base Damage"
@onready var swords_collision: AudioStreamPlayer = $"Swords collision";
@onready var throw_arrow: AudioStreamPlayer = $"Throw arrow";
@onready var arrow_collision: AudioStreamPlayer = $"Arrow collision";
@onready var magic_ball_collision: AudioStreamPlayer = $"Magic ball collision";
@onready var throw_magic_ball: AudioStreamPlayer = $"Throw magic ball";


func play_music() -> void:
	self.music.play();

func play_base_damage_sound() -> void:
	self.base_damage.play();

func play_swords_collision_sound() -> void:
	self.swords_collision.play();

func play_throw_arrow_sound() -> void:
	self.throw_arrow.play();

func play_arrow_collision_sound() -> void:
	self.arrow_collision.play();

func play_throw_magic_ball_sound() -> void:
	self.throw_magic_ball.play();

func play_magic_ball_collision_sound() -> void:
	self.magic_ball_collision.play();
	
func play_spawn_sound() -> void:
	self.spawn.play();
