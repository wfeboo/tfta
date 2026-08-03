extends Node2D

# Guardamos los paneles en una función
func show_panel(panel_index: int) -> void:
	var panels: Array = [$Panel1, $Panel2, $Panel3,$Panel4]
	for i in range(panels.size()):
		# Si la "i" se refiere a x panel en la lista, este será visible y hará un fade_in
		# Así si llamamos "show_panel(0)" hará todo esto para $Panel1
		if i == panel_index:
			panels[i].visible = true
			panels[i].modulate.a = 0.0
			var panel_tween := create_tween()
			panel_tween.tween_property(panels[i], "modulate:a", 1.0, 0.8)


func _ready() -> void:
	# Configuramos la visibilidad de los objetos a invisibles por medio de _ready
	$UILayer/Control/SpeakerBox.modulate.a = 0.0
	$UILayer/Control/DialogueBox.modulate.a = 0.0
	$Panel1.modulate.a = 0.0
	$Panel2.modulate.a = 0.0
	$Panel3.modulate.a = 0.0
	$Panel4.modulate.a = 0.0
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
	get_tree().change_scene_to_file("res://scenes/menu/intro/intro_scenes/scn_comic_panels.tscn")


func show_dialogue() -> void:
	# Conseguimos la conversación que queremos mostrar para esta escena
	var conversation: Array = DialogueDatabase.get_conversation("INTRO-01")
	# Guardamos ProgressIndicate en una variable para que sea más fácil de editar
	var progress_indicate = $UILayer/Control/DialogueBox/ProgressIndicate
	# Por todas las líneas en la conversación, al inicio ocultaremos progress_indicate
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
			"intro1_first_panel":
				show_panel(0)
			# Se muestra Vint y se oscurece el primer panel
			"intro1_desivinte_panel":
				var panel_tween := create_tween()
				panel_tween.tween_property($Panel1, "modulate:a", 0.3, 1)
				show_panel(1)
			# Se muestra KJ
			"intro1_kathjules_panel":
				show_panel(2)
			# Se muestra Heth
			"intro1_hetheline_panel":
				show_panel(3)
		# Una variable que actualiza cada letra a ser visible
		var typewriter_tween := create_tween()
		typewriter_tween.tween_property($UILayer/Control/DialogueBox/DialogueLabel,"visible_ratio",1.0,duration)
		# Hasta que termine de escribirse todo el diálogo
		await typewriter_tween.finished
		# Esperamos un segundo hasta para que el jugador pueda pasar de línea
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
	# Al igual que la pantalla entró, saldrá con un fade out
	var screen_tween := create_tween()
	screen_tween.tween_property($MemoryOverlay, "color", Color("1a1a1a"), 2.0)
	# Esperamos a que esto termine para pasar a la siguiente escena
	await screen_tween.finished
	_on_scene_finished()
