# Controlador de cinemática con presentación de personajes en paneles (INTRO-01).
#
# Administra la revelación progresiva de cuatro paneles gráficos estilo cómic,
# la sincronización de nombres/diálogos mediante 'triggers' ("intro1_first_panel",
# "intro1_desivinte_panel", etc.) y la atenuación de paneles en segundo plano.
extends Node2D


# Muestra y anima mediante transparencia (fade-in) el panel gráfico indicado por su índice.
#
# Parámetros:
#   - panel_index: Índice del panel objetivo (0: Panel1, 1: Panel2, 2: Panel3, 3: Panel4).
func show_panel(panel_index: int) -> void:
	var panels: Array = [$Panel1, $Panel2, $Panel3, $Panel4]
	for i in range(panels.size()):
		if i == panel_index:
			panels[i].visible = true
			panels[i].modulate.a = 0.0
			var panel_tween := create_tween()
			panel_tween.tween_property(panels[i], "modulate:a", 1.0, 0.8)


func _ready() -> void:
	# Ocultar inicialmente los paneles de ilustración y los elementos de UI
	$UILayer/Control/SpeakerBox.modulate.a = 0.0
	$UILayer/Control/DialogueBox.modulate.a = 0.0
	$Panel1.modulate.a = 0.0
	$Panel2.modulate.a = 0.0
	$Panel3.modulate.a = 0.0
	$Panel4.modulate.a = 0.0
	$UILayer/Control/DialogueBox/ProgressIndicate.visible = false

	# Estado inicial de la pantalla: Negro total
	$MemoryOverlay.color = Color.BLACK

	# Transición 1: Revelado de pantalla (fade-in desde negro hacia blanco)
	var screen_tween := create_tween()
	screen_tween.tween_property($MemoryOverlay, "color", Color.WHITE, 2.0)
	await screen_tween.finished

	# Transición 2: Aparición paralela de las cajas de diálogo
	var ui_tween := create_tween()
	ui_tween.set_parallel(true)
	ui_tween.tween_property($UILayer/Control/SpeakerBox, "modulate:a", 1.0, 1.0)
	ui_tween.tween_property($UILayer/Control/DialogueBox, "modulate:a", 1.0, 1.0)
	await ui_tween.finished

	# Iniciar la secuencia de diálogo de la cinemática
	show_dialogue()


# Procesa la conversación INTRO-01, gestionando el flujo de líneas y la entrada de personajes.
func show_dialogue() -> void:
	var conversation: Array = DialogueDatabase.get_conversation("INTRO-01")
	var progress_indicate: Control = $UILayer/Control/DialogueBox/ProgressIndicate
	var speaker_box: Control = $UILayer/Control/SpeakerBox
	var dialogue_box: Control = $UILayer/Control/DialogueBox
	var speaker_label: Label = $UILayer/Control/SpeakerBox/SpeakerLabel
	var dialogue_label: Label = $UILayer/Control/DialogueBox/DialogueLabel

	for line: Dictionary in conversation:
		progress_indicate.visible = false
		
		# Actualizar las etiquetas de hablante y texto
		speaker_label.text = line["character"]
		dialogue_label.text = line["text"]
		dialogue_label.visible_ratio = 0.0

		# Calcular tiempo de tipeo dinámico según la longitud del texto
		var text_length: int = line["text"].length()
		var duration: float = text_length * 0.065

		# Evaluación de triggers visuales para la aparición de paneles
		match line["trigger"]:
			"intro1_first_panel":
				show_panel(0)
			"intro1_desivinte_panel":
				# Oscurecer ligeramente el primer panel al aparecer el de Vint
				var panel_tween := create_tween()
				panel_tween.tween_property($Panel1, "modulate:a", 0.3, 1.0)
				show_panel(1)
			"intro1_kathjules_panel":
				show_panel(2)
			"intro1_hetheline_panel":
				show_panel(3)

		# Animación de la máquina de escribir
		var typewriter_tween := create_tween()
		typewriter_tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)

		# Acelerar velocidad si se mantiene presionado 'ui_accept'
		while typewriter_tween.is_running():
			if Input.is_action_pressed("ui_accept"):
				typewriter_tween.set_speed_scale(2.5)
			else:
				typewriter_tween.set_speed_scale(1.0)
			await get_tree().process_frame

		await get_tree().create_timer(1.0).timeout
		progress_indicate.visible = true

		# Tiempo límite para cambio automático de línea si el jugador no presiona un botón
		var total_wait: float = 2.0 + (text_length * 0.009)
		var wait_timer: float = 0.0

		while wait_timer < total_wait:
			if Input.is_action_just_pressed("ui_accept"):
				break
			await get_tree().process_frame
			wait_timer += get_process_delta_time()

	# Ocultar interfaz al terminar las líneas de texto
	speaker_box.visible = false
	dialogue_box.visible = false

	# Transición de salida hacia color oscuro
	var screen_tween := create_tween()
	screen_tween.tween_property($MemoryOverlay, "color", Color("1a1a1a"), 2.0)
	await screen_tween.finished

	_on_scene_finished()


# Cierra la escena actual y pasa a la secuencia de cómics/paneles siguiente.
func _on_scene_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/intro/intro_scenes/intro_sequence_scenes/scn_comic_panels.tscn")
