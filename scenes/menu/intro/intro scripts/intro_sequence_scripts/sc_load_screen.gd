extends Node2D


func _ready() -> void:
	if GameData.intro_seen:
		get_tree().change_scene_to_file("res://scenes/menu/menu_files/scn_blurry_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/menu/intro/intro_scenes/intro_sequence_scenes/scn_destiny.tscn")
