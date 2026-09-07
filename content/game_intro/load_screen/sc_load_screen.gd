extends Node2D


func _ready() -> void:
	if GameData.intro_seen:
		get_tree().change_scene_to_file("res://content/game_menu/scn_main_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://content/game_intro/destiny_scene/scn_destiny.tscn")
