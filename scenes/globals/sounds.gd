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

func play_music() -> void:
	self.music.play();

func play_base_damage_sound() -> void:
	pass;

func play_swords_collision_sound() -> void:
	pass;

func play_throw_arrow_sound() -> void:
	pass;

func play_arrow_collision_sound() -> void:
	pass;

func play_throw_magic_ball_sound() -> void:
	pass;

func play_magic_ball_collision_sound() -> void:
	pass;
	
func play_spawn_sound() -> void:
	pass;
