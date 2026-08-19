# Controlador de la cinemática de cierre de la introducción (Secuencia del Bibliotecario).
#
# Administra la aparición de la UI sobre pantalla oscura, la transición visual
# hacia blanco (recuerdo), el desvanecimiento del personaje del bibliotecario
# mediante 'triggers' y, al finalizar, guarda el progreso global en disco
# (mark_intro_seen) antes de redirigir al menú principal.
extends Node2D

# Variables para control de animaciones secundarias
var animation_speed: float = 0.9
var time_passed: float = 0.0
var showing_sprite_a: bool = true


func _ready() -> void:
	# Inicializar la opacidad y visibilidad de los elementos de UI y personajes
	$UILayer/Control/SpeakerBox.modulate.a = 0.0
	$UILayer/Control/DialogueBox.modulate.a = 0.0
	$UILayer/Control/DialogueBox/ProgressIndicate.visible = false
	$Librarian.modulate.a = 0.0

	# Estado inicial de la pantalla: Negro total
	$MemoryOverlay.color = Color.BLACK

	# Transición inicial: Aparición paralela de las cajas de diálogo
	var ui_tween := create_tween()
	ui_tween.set_parallel(true)
	ui_tween.tween_property($UILayer/Control/SpeakerBox, "modulate:a", 1.0, 2.0)
	ui_tween.tween_property($UILayer/Control/DialogueBox, "modulate:a", 1.0, 2.0)
	await ui_tween.finished

	# Iniciar la conversación de la cinemática
	show_dialogue()


# Procesa la conversación INTRO-03, animando el texto y ejecutando triggers visuales.
func show_dialogue() -> void:
	var conversation: Array = DialogueDatabase.get_conversation("INTRO-03")
	var progress_indicate: Control = $UILayer/Control/DialogueBox/ProgressIndicate
	var speaker_box: Control = $UILayer/Control/SpeakerBox
	var dialogue_box: Control = $UILayer/Control/DialogueBox
	var speaker_label: Label = $UILayer/Control/SpeakerBox/SpeakerLabel
	var dialogue_label: Label = $UILayer/Control/DialogueBox/DialogueLabel

	for line: Dictionary in conversation:
		progress_indicate.visible = false
		
		# Actualizar las etiquetas de texto
		speaker_label.text = line["character"]
		dialogue_label.text = line["text"]
		dialogue_label.visible_ratio = 0.0

		# Duración dinámica de la animación de escritura
		var text_length: int = line["text"].length()
		var duration: float = text_length * 0.065

		# Evaluación de los eventos/triggers narrativos de esta escena
		match line["trigger"]:
			"intro3_fade_back":
				# Revelar el fondo con un fundido hacia blanco
				var memory_tween := create_tween()
				memory_tween.tween_property($MemoryOverlay, "color", Color.WHITE, 3.0)
				await memory_tween.finished

			"librarian_great_pose":
				# Hacer aparecer la figura del bibliotecario mediante opacidad
				var character_tween := create_tween()
				character_tween.tween_property($Librarian, "modulate:a", 1.0, 2.0)
				await character_tween.finished

		# Animación de la máquina de escribir
		var typewriter_tween := create_tween()
		typewriter_tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)

		# Permitir acelerar el texto si se mantiene presionado 'ui_accept'
		while typewriter_tween.is_running():
			if Input.is_action_pressed("ui_accept"):
				typewriter_tween.set_speed_scale(2.5)
			else:
				typewriter_tween.set_speed_scale(1.0)
			await get_tree().process_frame

		await get_tree().create_timer(1.0).timeout
		progress_indicate.visible = true

		# Tiempo de lectura dinámico según la longitud de la línea
		var total_wait: float = 2.0 + (text_length * 0.009)
		var wait_timer: float = 0.0

		# Esperar la confirmación del usuario o el tiempo limite de lectura
		while wait_timer < total_wait:
			if Input.is_action_just_pressed("ui_accept"):
				break
			await get_tree().process_frame
			wait_timer += get_process_delta_time()

	# Ocultar la UI al concluir los diálogos
	speaker_box.visible = false
	dialogue_box.visible = false

	# Transición de salida a pantalla oscura
	var screen_tween := create_tween()
	screen_tween.tween_property($MemoryOverlay, "color", Color("1a1a1a"), 2.0)
	await screen_tween.finished

	# Marcar en el guardado que la introducción ya fue vista por el usuario
	GameData.mark_intro_seen()
	_on_scene_finished()


# Cierra la cinemática y redirige al menú principal del juego.
func _on_scene_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/menu_files/scn_main_menu.tscn")
