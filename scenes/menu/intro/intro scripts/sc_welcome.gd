extends Node2D

const CROWD_A = preload("res://assets/sprites/intro_scene/welcome/crowdpeople_a.png") 
const CROWD_B = preload("res://assets/sprites/intro_scene/welcome/crowdpeople_b.png") 
const CROWD_C = preload("res://assets/sprites/intro_scene/welcome/crowdpeople_c.png")

var animation_speed : float = 0.9
var time_passed : float = 0.0
var showing_sprite_a : bool = true

func _process(delta):
	time_passed += delta
	if time_passed >= animation_speed:
		time_passed = 0.0
		showing_sprite_a = !showing_sprite_a
		if showing_sprite_a:
			$BackgroundPeople.texture = CROWD_A
		else:
			if randf() <= 0.03:
				$BackgroundPeople.texture = CROWD_B
			else:
				$BackgroundPeople.texture = CROWD_C

func _ready() -> void:
	# Instanciar las cajas pero son invisibles
	$UILayer/Control/SpeakerBox.modulate.a = 0.0
	$UILayer/Control/DialogueBox.modulate.a = 0.0
	
	# La pantalla está completamente oscura
	$MemoryOverlay.color = Color.BLACK
	
	# La pantalla aparece con una transición
	var screen_tween := create_tween()
	screen_tween.tween_property($MemoryOverlay, "color", Color.WHITE, 2.0)
	await screen_tween.finished
	
	# Con un segundo de transición, aparecen las cajas
	var ui_tween := create_tween()
	# Que aparezcan al mismo tiempo con set_parallel
	ui_tween.set_parallel(true) 
	ui_tween.tween_property($UILayer/Control/SpeakerBox, "modulate:a", 1.0, 1)
	ui_tween.tween_property($UILayer/Control/DialogueBox, "modulate:a", 1.0, 1)
	await ui_tween.finished
	
	# Iniciar el diálogo
	show_dialogue()

func _on_scene_finished() -> void:
	# Solo cambia de escena - NO toca el guardado en disco
	get_tree().change_scene_to_file("res://scenes/menu/intro/intro_scenes/scn_comic_panels.tscn")



func show_dialogue() -> void:
	var conversation: Array = DialogueDatabase.get_conversation("INTRO-00")
	for line in conversation:
		# Actualizar los labels
		$UILayer/Control/SpeakerBox/SpeakerLabel.text = line["character"]
		$UILayer/Control/DialogueBox/DialogueLabel.text = line["text"]
		# Son invisibles los contenidos del diálogo
		$UILayer/Control/DialogueBox/DialogueLabel.visible_ratio = 0.0
		# Calcular la velocidad dinámica basado en la longitud del texto
		var text_length = line["text"].length()
		var duration = text_length * 0.07
		# Una variable que actualiza cada letra a ser visible
		var typewriter_tween := create_tween()
		typewriter_tween.tween_property(
			$UILayer/Control/DialogueBox/DialogueLabel, 
			"visible_ratio", 
			1.0, 
			duration
		)
		# Hasta que termine de escribirse todo el diálogo
		await typewriter_tween.finished
		# Luego esperar a pasar a la siguiente línea de diálogo
		await get_tree().create_timer(2.0 + (line["text"].length() * 0.009)).timeout
	# 1. Hide the UI boxes instantly
	$UILayer/Control/SpeakerBox.visible = false
	$UILayer/Control/DialogueBox.visible = false
	var screen_tween := create_tween()
	screen_tween.tween_property($MemoryOverlay, "color", Color("1a1a1a"), 2.0)
	await screen_tween.finished
	_on_scene_finished()
