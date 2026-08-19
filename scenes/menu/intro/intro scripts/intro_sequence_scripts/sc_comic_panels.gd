# Controlador de escena narrativa / cinemática con secuencia de paneles.
#
# Coordina la transición inicial de pantalla, el desvanecimiento (fade-in) de la UI,
# la visualización progresiva de paneles gráficos mediante eventos ('triggers')
# y la lectura del diálogo hasta la transición final hacia la siguiente escena.
extends Node2D


func _ready() -> void:
	# Inicializar visibilidad y transparencia de la UI y de los paneles de ilustración
	$UILayer/Control/SpeakerBox.modulate.a = 0.0
	$UILayer/Control/DialogueBox.modulate.a = 0.0
	$Panel1.modulate.a = 0.0
	$Panel2.modulate.a = 0.0
	$Panel3.modulate.a = 0.0
	$UILayer/Control/DialogueBox/ProgressIndicate.visible = false

	# Estado inicial: Pantalla en negro absoluto
	$MemoryOverlay.color = Color.BLACK

	# Transición 1: Fundido de pantalla (fade-in desde negro hacia blanco)
	var screen_tween := create_tween()
	screen_tween.tween_property($MemoryOverlay, "color", Color.WHITE, 2.0)
	await screen_tween.finished

	# Transición 2: Aparecen las cajas de interfaz de forma paralela
	var ui_tween := create_tween()
	ui_tween.set_parallel(true)
	ui_tween.tween_property($UILayer/Control/SpeakerBox, "modulate:a", 1.0, 1.0)
	ui_tween.tween_property($UILayer/Control/DialogueBox, "modulate:a", 1.0, 1.0)
	await ui_tween.finished

	# Comenzar la secuencia de diálogos de la cinemática
	show_dialogue()


# Muestra y anima mediante transparencia el panel gráfico indicado por su índice.
#
# Parámetros:
#   - panel_index: Índice del panel a activar (0 para Panel1, 1 para Panel2, etc.).
func show_panel(panel_index: int) -> void:
	var panels: Array = [$Panel1, $Panel2, $Panel3]
	for i in range(panels.size()):
		if i == panel_index:
			panels[i].visible = true
			panels[i].modulate.a = 0.0
			var panel_tween := create_tween()
			panel_tween.tween_property(panels[i], "modulate:a", 1.0, 0.8)


# Carga la conversación y procesa la animación de texto, triggers y tiempos de espera.
func show_dialogue() -> void:
	var conversation: Array = DialogueDatabase.get_conversation("INTRO-02")
	var progress_indicate := $UILayer/Control/DialogueBox/ProgressIndicate
	var speaker_box := $UILayer/Control/SpeakerBox
	var dialogue_box := $UILayer/Control/DialogueBox
	var speaker_label := $UILayer/Control/SpeakerBox/SpeakerLabel
	var dialogue_label := $UILayer/Control/DialogueBox/DialogueLabel

	for line: Dictionary in conversation:
		progress_indicate.visible = false
		
		# Asignar textos a las etiquetas
		speaker_label.text = line["character"]
		dialogue_label.text = line["text"]
		dialogue_label.visible_ratio = 0.0

		# Calcular la duración del efecto de la máquina de escribir
		var text_length: int = line["text"].length()
		var duration: float = text_length * 0.065

		# Procesar eventos visuales desencadenados por la línea de diálogo actual
		match line["trigger"]:
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

		# Animar la revelación gradual del texto
		var typewriter_tween := create_tween()
		typewriter_tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)

		# Permitir acelerar la animación de texto si el jugador mantiene presionado 'ui_accept'
		while typewriter_tween.is_running():
			if Input.is_action_pressed("ui_accept"):
				typewriter_tween.set_speed_scale(2.5)
			else:
				typewriter_tween.set_speed_scale(1.0)
			await get_tree().process_frame

		# Mostrar indicador de avance al finalizar la animación
		progress_indicate.visible = true

		# Tiempo de lectura dinámico según la longitud del texto
		var total_wait: float = 2.0 + (text_length * 0.009)
		var time_passed: float = 0.0

		# Esperar a que transcurra el tiempo de lectura o a que el jugador presione avanzar
		while time_passed < total_wait:
			if Input.is_action_just_pressed("ui_accept"):
				break
			await get_tree().process_frame
			time_passed += get_process_delta_time()

	# Ocultar la interfaz al finalizar todas las líneas de diálogo
	speaker_box.visible = false
	dialogue_box.visible = false

	# Transición de salida: Fundido hacia un color oscuro
	var screen_tween := create_tween()
	screen_tween.tween_property($MemoryOverlay, "color", Color("1a1a1a"), 2.0)
	await screen_tween.finished

	_on_scene_finished()


# Evento de cierre de la secuencia narrativa: Cambia a la siguiente escena del juego.
func _on_scene_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/intro/intro_scenes/intro_sequence_scenes/scn_goodbye.tscn")
