extends Node

@onready var music: AudioStreamPlayer = $Music;
@onready var base_damage: AudioStreamPlayer = $BaseDamage;

func play_music() -> void:
	self.music.play();

func play_base_damage_sound() -> void:
	self.base_damage.play();
