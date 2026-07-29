extends Node2D

const CONVERSATION_IDS: Array[String] = [
	"INTRO-DSTNY-0000",
	"INTRO-DSTNY-0001",
	"INTRO-DSTNY-0002",
	"INTRO-DSTNY-0003",
	"INTRO-DSTNY-0004",
	"INTRO-DSTNY-0005",
	"INTRO-DSTNY-0006"
]

func _ready() -> void:
	$UILayer/Control/DialogueBox.modulate.a = 0.0
	$UILayer/Control/DialogueBox/ProgressIndicate.visible = false
	
	# Aparece la caja de diálogo (sin el fade de pantalla, ya que esta escena no usa MemoryOverlay)
	var ui_tween := create_tween()
	ui_tween.tween_property($UILayer/Control/DialogueBox,"modulate:a",1.0,2.5)
	await ui_tween.finished

	# Recorre las conversaciones en orden
	for conversation_id: String in CONVERSATION_IDS:
		await show_dialogue_manual(conversation_id)
	$UILayer/Control/DialogueBox.visible = false
	_on_scene_finished()


func show_dialogue_manual(conversation_id: String) -> void:
	var conversation: Array = DialogueDatabase.get_conversation(conversation_id)
	var dialogue_label = $UILayer/Control/DialogueBox/DialogueLabel
	var progress_indicate = $UILayer/Control/DialogueBox/ProgressIndicate

	# Sirve para detectar IDs incorrectos o inexistentes
	if conversation.is_empty():
		push_warning("No se encontró la conversación: " + conversation_id)
		return

	# Recorre todas las filas que tengan este Conversation ID
	for line in conversation:
		dialogue_label.text = line["text"]
		dialogue_label.visible_ratio = 0.0

		var text_length: int = line["text"].length()
		var duration: float = text_length * 0.09

		var typewriter_tween := create_tween()
		typewriter_tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)

		# La línea debe terminar de escribirse por completo
		# Esperar a que termine de escribirse.
		await typewriter_tween.finished

		# Esperar 2.5 segundos antes de mostrar el indicador.
		await get_tree().create_timer(2.5).timeout

		# Mostrar el indicador hasta que el jugador continúe.
		progress_indicate.visible = true

		while not Input.is_action_just_pressed("ui_accept"):
			await get_tree().process_frame

		# Ocultarlo después de presionar.
		progress_indicate.visible = false

		# Evitar que la misma pulsación salte la siguiente línea.
		await get_tree().process_frame


func _on_scene_finished() -> void:
	# Solo cambia de escena - NO toca el guardado en disco
	get_tree().change_scene_to_file("res://scenes/menu/intro/intro_scenes/scn_welcome.tscn")
