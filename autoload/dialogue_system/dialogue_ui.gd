extends CanvasLayer

var dialogue_active: bool = false

func _ready() -> void:
	$Control/SpeakerBox.visible = false
	$Control/DialogueBox.visible = false
	$Control/DialogueBox/ProgressIndicate.visible = false
	 

func show_dialogue(conversation_id: String, caller: Node) -> void:
	var conversation: Array = DialogueDatabase.get_conversation(conversation_id)
	$Control/DialogueBox.visible = true
	dialogue_active = true
	var progress_indicate = $Control/DialogueBox/ProgressIndicate
	for line in conversation:
		if line["character"] != "":
			$Control/SpeakerBox.visible = true
		else:
			$Control/SpeakerBox.visible = false
		$Control/DialogueBox/ProgressIndicate.visible = false
		$Control/SpeakerBox/SpeakerLabel.text = line["character"]
		$Control/DialogueBox/DialogueLabel.text = line["text"]
		$Control/DialogueBox/DialogueLabel.visible_ratio = 0.0
		var text_length = line["text"].length()
		var duration = text_length * 0.065
		caller.handle_trigger(line["trigger"])
		# Una variable que actualiza cada letra a ser visible
		var typewriter_tween := create_tween()
		typewriter_tween.tween_property($Control/DialogueBox/DialogueLabel,"visible_ratio",1.0,duration)
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
	$Control/SpeakerBox.visible = false
	$Control/DialogueBox.visible = false
	dialogue_active = false
