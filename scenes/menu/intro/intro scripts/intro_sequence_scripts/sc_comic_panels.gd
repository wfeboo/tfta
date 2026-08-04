extends Node2D

func show_panel(panel_index: int) -> void:
	var panels: Array = [$Panel1, $Panel2, $Panel3]

	for i in range(panels.size()):
		if i == panel_index:
			panels[i].visible = true
			panels[i].modulate.a = 0.0
			var panel_tween := create_tween()
			panel_tween.tween_property(panels[i], "modulate:a", 1.0, 0.8)


func _ready() -> void:
	# Instanciar las cajas pero son invisibles
	$UILayer/Control/SpeakerBox.modulate.a = 0.0
	$UILayer/Control/DialogueBox.modulate.a = 0.0
	$Panel1.modulate.a = 0.0
	$Panel2.modulate.a = 0.0
	$Panel3.modulate.a = 0.0
	$UILayer/Control/DialogueBox/ProgressIndicate.visible = false

	# La pantalla está completamente oscura
	$MemoryOverlay.color = Color.BLACK

	# La pantalla aparece con una transición
	var screen_tween := create_tween()
	screen_tween.tween_property($MemoryOverlay, "color", Color.WHITE, 2.0)
	await screen_tween.finished

	# Con un segundo de transición, aparecen las cajas
	var ui_tween := create_tween()
	ui_tween.set_parallel(true)
	ui_tween.tween_property($UILayer/Control/SpeakerBox, "modulate:a", 1.0, 1)
	ui_tween.tween_property($UILayer/Control/DialogueBox, "modulate:a", 1.0, 1)
	await ui_tween.finished

	# Iniciar el diálogo
	show_dialogue()


func _on_scene_finished() -> void:
	# Solo cambia de escena - NO toca el guardado en disco
	get_tree().change_scene_to_file("res://scenes/menu/intro/intro_scenes/scn_goodbye.tscn")


func show_dialogue() -> void:
	var conversation: Array = DialogueDatabase.get_conversation("INTRO-02")
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
		# Si no tiene trigger no pasa nada a menos de que tenga uno en específico
		match line["trigger"]:
			# Se muestra el primer panel
			"intro2_intro_panel":
				show_panel(0)
			"intro2_second_panel":
				show_panel(1)
			"intro2_second_cheer":
				pass
			"intro2_second_embarrassed":
				pass
			"intro2_second_joy":
				pass
			"intro2_third_panel":
				show_panel(2)
		# Una variable que actualiza cada letra a ser visible
		var typewriter_tween := create_tween()
		typewriter_tween.tween_property($UILayer/Control/DialogueBox/DialogueLabel,"visible_ratio",1.0,duration)
			# Hasta que termine de escribirse todo el diálogo
		await typewriter_tween.finished
		await get_tree().create_timer(1.5).timeout
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
	_on_scene_finished()
