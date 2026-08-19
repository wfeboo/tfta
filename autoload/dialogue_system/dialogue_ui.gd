# Gestor de interfaz de usuario para la visualización de diálogos.
#
# Se encarga de mostrar la caja de texto, animar la aparición de las letras
# (efecto máquina de escribir) y coordinar los tiempos de espera e interacción
# del jugador antes de pasar a la siguiente línea.
extends CanvasLayer

# Indica si actualmente hay una conversación en progreso.
var dialogue_active: bool = false


func _ready() -> void:
	_hide_dialogue_ui()


# Inicia y gestiona la secuencia visual de una conversación completa.
#
# Parámetros:
#   - conversation_id: String con el identificador de la conversación a mostrar.
#   - caller: Nodo que invocó el diálogo (debe implementar la función 'handle_trigger').
func show_dialogue(conversation_id: String, caller: Node) -> void:
	var conversation: Array = DialogueDatabase.get_conversation(conversation_id)
	
	if conversation.is_empty():
		push_warning("DialogueUI: Se intentó mostrar una conversación vacía o inexistente: " + conversation_id)
		return

	$Control/DialogueBox.visible = true
	dialogue_active = true

	var speaker_box := $Control/SpeakerBox
	var dialogue_box := $Control/DialogueBox
	var speaker_label := $Control/SpeakerBox/SpeakerLabel
	var dialogue_label := $Control/DialogueBox/DialogueLabel
	var progress_indicate := $Control/DialogueBox/ProgressIndicate

	for line: Dictionary in conversation:
		# Mostrar u ocultar la caja del personaje según si hay un nombre asignado
		speaker_box.visible = (line["character"] != "")
		progress_indicate.visible = false
		
		speaker_label.text = line["character"]
		dialogue_label.text = line["text"]
		dialogue_label.visible_ratio = 0.0

		# Notificar eventos/desencadenantes al nodo llamador
		if caller and caller.has_method("handle_trigger"):
			caller.handle_trigger(line["trigger"])

		# Animar la aparición del texto carácter por carácter
		var text_length: int = line["text"].length()
		var duration: float = text_length * 0.065
		
		var typewriter_tween := create_tween()
		typewriter_tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)
		await typewriter_tween.finished

		# Breve pausa antes de habilitar el indicador de avance
		await get_tree().create_timer(1.5).timeout
		progress_indicate.visible = true

		# Esperar a que el jugador avance de línea o transcurra el tiempo máximo
		var total_wait: float = 2.0 + (text_length * 0.009)
		var time_passed: float = 0.0

		while time_passed < total_wait:
			if Input.is_action_just_pressed("ui_accept"):
				break
			await get_tree().process_frame
			time_passed += get_process_delta_time()

	_hide_dialogue_ui()


# Oculta todos los elementos de la interfaz de diálogo y restablece el estado.
func _hide_dialogue_ui() -> void:
	$Control/SpeakerBox.visible = false
	$Control/DialogueBox.visible = false
	$Control/DialogueBox/ProgressIndicate.visible = false
	dialogue_active = false
