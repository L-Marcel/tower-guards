extends Node

@onready var music: AudioStreamPlayer = $Music;
@onready var spawn: AudioStreamPlayer = $Spawn;
@onready var base_damage: AudioStreamPlayer = $BaseDamage;

func play_music() -> void:
	self.music.play();

func play_base_damage_sound() -> void:
	self.base_damage.play();

func play_spawn_sound() -> void:
	self.spawn.play();
