# Controlador de secuencia cinemática para la introducción narrativa.
#
# Coordina la reproducción secuencial de diálogos, efectos de parpadeo de la interfaz,
# generación procedimental de raíces flotantes/crecientes en pantalla a intervalos 
# dinámicos y la transición final con despliegue de logotipo.
extends Node2D

# Tiempo de parpadeo de la interfaz de diálogo.
var blink_timer: float = 0.0

# Bandera y tiempo entre apariciones para la generación continua de raíces.
var roots_growing: bool = false
var spawn_interval: float = 1000.0

# Arreglo ordenado con los IDs de conversación a reproducir en secuencia.
const CONVERSATION_IDS: Array[String] = [
	"INTRO-DSTNY-0000",
	"INTRO-DSTNY-0001",
	"INTRO-DSTNY-0002",
	"INTRO-DSTNY-0003",
	"INTRO-DSTNY-0004",
	"INTRO-DSTNY-0005",
	"INTRO-DSTNY-0006"
]

# Precarga de escenas de raíces para instanciación aleatoria durante la escena.
var ROOTS: Array[PackedScene] = [
	preload("res://scenes/menu/intro/intro_scenes/intro_sequence_scenes/roots_dstny/scn_roots_a.tscn"),
	preload("res://scenes/menu/intro/intro_scenes/intro_sequence_scenes/roots_dstny/scn_roots_b.tscn"),
	preload("res://scenes/menu/intro/intro_scenes/intro_sequence_scenes/roots_dstny/scn_roots_c.tscn")
]


func _ready() -> void:
	# Inicialización de visibilidad y opacidad de la interfaz
	$UILayer/Control/DialogueBox.modulate.a = 0.0
	$UILayer/BlackScreen.visible = false
	$UILayer/Control/DialogueBox/ProgressIndicate.visible = false
	$UILayer/BlackScreen/LogoSprite.visible = false

	# Transición inicial: Aparición progresiva de la caja de diálogo
	await get_tree().create_timer(2.5).timeout
	var ui_tween := create_tween()
	ui_tween.tween_property($UILayer/Control/DialogueBox, "modulate:a", 1.0, 4.5)
	await ui_tween.finished

	# Reproducción de cada conversación definida en la lista secuencial
	for conversation_id: String in CONVERSATION_IDS:
		await show_dialogue_manual(conversation_id)

	$UILayer/Control/DialogueBox.visible = false


# Procesa y reproduce manualmente un bloque de conversación línea por línea.
#
# Parámetros:
#   - conversation_id: ID String de la conversación a solicitar a DialogueDatabase.
func show_dialogue_manual(conversation_id: String) -> void:
	var conversation: Array = DialogueDatabase.get_conversation(conversation_id)
	var dialogue_label: Label = $UILayer/Control/DialogueBox/DialogueLabel
	var progress_indicate: Control = $UILayer/Control/DialogueBox/ProgressIndicate

	# Validación defensiva por si la ID no existe en la base de datos
	if conversation.is_empty():
		push_warning("IntroSequence: No se encontró la conversación con ID: " + conversation_id)
		return

	# Procesamiento línea por línea
	for line: Dictionary in conversation:
		dialogue_label.text = line["text"]
		dialogue_label.visible_ratio = 0.0

		# Evaluación de eventos/triggers narrativos
		match line["trigger"]:
			"bar_appears":
				pass
			"initial_dialogue":
				pass
			"roots_start":
				roots_growing = true
				spawn_interval = 5.8
				grow_roots()
			"bar_blinks":
				blink_dialogue()
			"roots_intensify":
				spawn_interval = 2.2
			"name_trigger_question":
				pass
			"yes_no_question":
				pass
			"roots_strengthen":
				spawn_interval = 0.6
			"roots_cover_screen":
				pass

		var text_length: int = line["text"].length()
		var duration: float = text_length * 0.09

		# Pausa dramática previa al tipeo
		await get_tree().create_timer(0.3).timeout

		# Animación de escritura de texto (máquina de escribir)
		var typewriter_tween := create_tween()
		typewriter_tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)

		# Control de aceleración de lectura al presionar 'ui_accept'
		while typewriter_tween.is_running():
			if Input.is_action_pressed("ui_accept"):
				typewriter_tween.set_speed_scale(1.6)
			else:
				typewriter_tween.set_speed_scale(1.0)
			await get_tree().process_frame

		# Trigger especial de cierre con presentación del logo del juego
		if line["trigger"] == "title_drop":
			await get_tree().create_timer(0.5).timeout
			roots_growing = false
			$UILayer/BlackScreen.visible = true
			$UILayer/BlackScreen/LogoSprite.visible = true
			
			await get_tree().create_timer(5.5).timeout
			var logo_tween := create_tween()
			logo_tween.tween_property($UILayer/BlackScreen/LogoSprite, "modulate:a", 0.0, 4.0)
			await logo_tween.finished
			
			await get_tree().create_timer(1.5).timeout
			_on_scene_finished()
		else:
			# Pausa tras completar la línea de texto antes de habilitar la entrada del usuario
			await get_tree().create_timer(1.5).timeout

			# Mostrar el indicador y esperar la confirmación del jugador
			progress_indicate.visible = true
			while not Input.is_action_just_pressed("ui_accept"):
				await get_tree().process_frame
				
			progress_indicate.visible = false
			# Evita que la misma pulsación de avance arrastre al siguiente frame
			await get_tree().process_frame


# Genera instancias de raíces aleatorias en posiciones de pantalla mientras 'roots_growing' sea verdadero.
func grow_roots() -> void:
	while roots_growing:
		await get_tree().create_timer(spawn_interval).timeout
		if not roots_growing:
			break
			
		var root: Node2D = ROOTS.pick_random().instantiate()
		root.position.x = randf_range(0.0, get_viewport().get_visible_rect().size.x)
		root.position.y = [0.0, 500.0].pick_random()
		add_child(root)


# Realiza un efecto de parpadeo alternando la visibilidad de la caja de diálogo.
#
# Parámetros:
#   - duration: Duración total del parpadeo en segundos.
#   - blink_interval: Frecuencia con la que se conmuta la visibilidad.
func blink_dialogue(duration: float = 0.55, blink_interval: float = 0.1) -> void:
	var dialogue_box: Control = $UILayer/Control/DialogueBox
	var time_passed: float = 0.0

	while time_passed < duration:
		dialogue_box.visible = not dialogue_box.visible
		await get_tree().create_timer(blink_interval).timeout
		time_passed += blink_interval

	dialogue_box.visible = true


# Transición de cierre de la secuencia cinemática.
func _on_scene_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/intro/intro_scenes/intro_sequence_scenes/scn_welcome.tscn")
