# Controlador de la escena de bienvenida con multitud animada (INTRO-00).
#
# Administra la animación en bucle de la multitud en el fondo (con variación
# probabilística de sprites) y la secuencia inicial de diálogo hasta revelar
# la pantalla ("eyes_open") y dar paso a la siguiente cinemática.
extends Node2D

# Precarga de los fotogramas/sprites de la multitud de fondo
const CROWD_A: Texture2D = preload("res://assets/sprites/intro_scene/intro_sequence/welcome/crowdpeople_a.png")
const CROWD_B: Texture2D = preload("res://assets/sprites/intro_scene/intro_sequence/welcome/crowdpeople_b.png")
const CROWD_C: Texture2D = preload("res://assets/sprites/intro_scene/intro_sequence/welcome/crowdpeople_c.png")

# Configuración del temporizador para la animación de la multitud
var animation_speed: float = 0.9
var animation_timer: float = 0.0
var showing_sprite_a: bool = true


func _process(delta: float) -> void:
	# Alternar el sprite de la multitud según el tiempo transcurrido
	animation_timer += delta
	if animation_timer >= animation_speed:
		animation_timer = 0.0
		showing_sprite_a = !showing_sprite_a
		
		if showing_sprite_a:
			$BackgroundPeople.texture = CROWD_A
		else:
			# 3% de probabilidad de mostrar la variante de multitud B, de lo contrario muestra la C
			if randf() <= 0.03:
				$BackgroundPeople.texture = CROWD_B
			else:
				$BackgroundPeople.texture = CROWD_C


func _ready() -> void:
	# Ocultar la UI inicialmente
	$UILayer/Control/SpeakerBox.modulate.a = 0.0
	$UILayer/Control/DialogueBox.modulate.a = 0.0
	$UILayer/Control/DialogueBox/ProgressIndicate.visible = false

	# Pantalla en negro al iniciar
	$MemoryOverlay.color = Color.BLACK

	# Aparecen las cajas de interfaz en paralelo mediante un Tween
	var ui_tween := create_tween()
	ui_tween.set_parallel(true)
	ui_tween.tween_property($UILayer/Control/SpeakerBox, "modulate:a", 1.0, 2.0)
	ui_tween.tween_property($UILayer/Control/DialogueBox, "modulate:a", 1.0, 2.0)
	await ui_tween.finished

	# Iniciar la secuencia de diálogos
	show_dialogue()


# Procesa la conversación INTRO-00 y maneja la transición "eyes_open" para revelar la pantalla.
func show_dialogue() -> void:
	var conversation: Array = DialogueDatabase.get_conversation("INTRO-00")
	var progress_indicate: Control = $UILayer/Control/DialogueBox/ProgressIndicate
	var speaker_box: Control = $UILayer/Control/SpeakerBox
	var dialogue_box: Control = $UILayer/Control/DialogueBox
	var speaker_label: Label = $UILayer/Control/SpeakerBox/SpeakerLabel
	var dialogue_label: Label = $UILayer/Control/DialogueBox/DialogueLabel

	for line: Dictionary in conversation:
		progress_indicate.visible = false
		
		# Actualizar textos
		speaker_label.text = line["character"]
		dialogue_label.text = line["text"]
		dialogue_label.visible_ratio = 0.0

		# Calcular velocidad dinámica de tipeo
		var text_length: int = line["text"].length()
		var duration: float = text_length * 0.065

		# Procesar triggers específicos
		match line["trigger"]:
			"eyes_open":
				# Revelar la pantalla mediante un fundido hacia blanco (abrir los ojos)
				var memory_tween := create_tween()
				memory_tween.tween_property($MemoryOverlay, "color", Color.WHITE, 3.0)
				await memory_tween.finished

		# Animación del texto estilo máquina de escribir
		var typewriter_tween := create_tween()
		typewriter_tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)

		# Permitir acelerar la velocidad al presionar 'ui_accept'
		while typewriter_tween.is_running():
			if Input.is_action_pressed("ui_accept"):
				typewriter_tween.set_speed_scale(2.5)
			else:
				typewriter_tween.set_speed_scale(1.0)
			await get_tree().process_frame

		await get_tree().create_timer(1.0).timeout
		progress_indicate.visible = true

		# Tiempo límite de espera para la línea actual
		var total_wait: float = 2.0 + (text_length * 0.009)
		var wait_timer: float = 0.0

		while wait_timer < total_wait:
			if Input.is_action_just_pressed("ui_accept"):
				break
			await get_tree().process_frame
			wait_timer += get_process_delta_time()

	# Ocultar cajas de diálogo al concluir
	speaker_box.visible = false
	dialogue_box.visible = false

	# Transición de salida a color oscuro
	var screen_tween := create_tween()
	screen_tween.tween_property($MemoryOverlay, "color", Color("1a1a1a"), 2.0)
	await screen_tween.finished

	_on_scene_finished()


# Cierra la escena y cambia a la perspectiva de tercera persona en la secuencia de intro.
func _on_scene_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/intro/intro_scenes/intro_sequence_scenes/scn_third_person.tscn")
