extends Node2D


func _ready() -> void:
	await get_tree().create_timer(3.5).timeout
	get_tree().change_scene_to_file("res://scenes/menu/intro/intro_scenes/intro_sequence_scenes/scn_load_screen.tscn")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scenes/menu/intro/intro_scenes/intro_sequence_scenes/scn_load_screen.tscn")
