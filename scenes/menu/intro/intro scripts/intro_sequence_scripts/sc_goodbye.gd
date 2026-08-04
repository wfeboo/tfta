extends Node2D

var animation_speed : float = 0.9
var time_passed : float = 0.0
var showing_sprite_a : bool = true


func _ready() -> void:
	# Instanciar las cajas pero son invisibles
	$UILayer/Control/SpeakerBox.modulate.a = 0.0
	$UILayer/Control/DialogueBox.modulate.a = 0.0
	$UILayer/Control/DialogueBox/ProgressIndicate.visible = false
	$Librarian.modulate.a = 0.0
	# La pantalla está completamente oscura
	$MemoryOverlay.color = Color.BLACK
	
	
	
	# Con un segundo de transición, aparecen las cajas
	var ui_tween := create_tween()
	# Que aparezcan al mismo tiempo con set_parallel
	ui_tween.set_parallel(true) 
	ui_tween.tween_property($UILayer/Control/SpeakerBox, "modulate:a", 1.0,2)
	ui_tween.tween_property($UILayer/Control/DialogueBox, "modulate:a", 1.0, 2)
	await ui_tween.finished
	
	# Iniciar el diálogo
	show_dialogue()

func _on_scene_finished() -> void:
	# Solo cambia de escena - NO toca el guardado en disco
	get_tree().change_scene_to_file("res://scenes/menu/intro/intro_scenes/intro_sequence_scenes/scn_comic_panels.tscn")



func show_dialogue() -> void:
	var conversation: Array = DialogueDatabase.get_conversation("INTRO-03")
	var progress_indicate = $UILayer/Control/DialogueBox/ProgressIndicate
	for line in conversation:
		progress_indicate.visible = false
		# Actualizar los labels
		$UILayer/Control/SpeakerBox/SpeakerLabel.text = line["character"]
		$UILayer/Control/DialogueBox/DialogueLabel.text = line["text"]
		# Son invisibles los contenidos del diálogo
		$UILayer/Control/DialogueBox/DialogueLabel.visible_ratio = 0.0
		# Calcular la velocidad dinámica basado en la longitud del texto
		var text_length = line["text"].length()
		var duration = text_length * 0.065
		
		match line["trigger"]:
			"intro3_fade_back":
				# La pantalla aparece con una transición
				var memory_tween := create_tween()
				memory_tween.tween_property($MemoryOverlay, "color", Color.WHITE, 3.0)
				await memory_tween.finished
			"librarian_great_pose":
				var character_tween := create_tween()
				character_tween.tween_property($Librarian,"modulate:a", 1.0,2)
				await character_tween.finished
		
		# Una variable que actualiza cada letra a ser visible
		var typewriter_tween := create_tween()
		typewriter_tween.tween_property($UILayer/Control/DialogueBox/DialogueLabel,"visible_ratio",1.0,duration)
		# Hasta que termine de escribirse todo el diálogo
		await typewriter_tween.finished
		await get_tree().create_timer(1.0).timeout
		# Le mostramos progress_indicate
		progress_indicate.visible = true
		# Guardamos el tiempo de espera para que el diálogo se pase automáticamente
		var total_wait = 2.0 + (line["text"].length() * 0.009)
		# Guardamos cuanto tiempo ha pasado en total
		var time_passed = 0.0
		# Mientras que el tiempo que ha pasado sea menor al tiempo de espera
		while time_passed < total_wait:
			# Si se presiona "ui_accept" se rompe el while
			if Input.is_action_just_pressed("ui_accept"):
				break
			# Si eso no pasa, sumamos un frame al tiempo pasado, cuando este llegue a lo mismo que total_wait, este romperá el while
			await get_tree().process_frame
			time_passed += get_process_delta_time()
	# Escondemos SpeakerBox y DialogueBox para finalizar la escena
	$UILayer/Control/SpeakerBox.visible = false
	$UILayer/Control/DialogueBox.visible = false
	var screen_tween := create_tween()
	screen_tween.tween_property($MemoryOverlay, "color", Color("1a1a1a"), 2.0)
	await screen_tween.finished
	GameData.mark_intro_seen()
	_on_scene_finished()
