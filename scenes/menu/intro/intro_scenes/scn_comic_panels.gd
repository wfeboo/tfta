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
	get_tree().change_scene_to_file("res://scenes/menu/intro/intro_scenes/scn_third_person.tscn")


func show_dialogue() -> void:
	var conversation: Array = DialogueDatabase.get_conversation("INTRO-01")
	var total_lines: int = conversation.size()
	var panel_count: int = 3
	var base: int = total_lines / panel_count
	var remainder: int = total_lines % panel_count

	var lines_per_panel: Array[int] = []
	for panel_i in range(panel_count):
		var count: int = base
		if panel_i < remainder:
			count += 1
		lines_per_panel.append(count)

	var current_panel: int = 0
	var lines_shown_in_panel: int = 0

	for i in range(conversation.size()):
		var line = conversation[i]

		# Si arrancamos un panel nuevo, lo revelamos
		if lines_shown_in_panel == 0:
			show_panel(current_panel)

		# Actualizar los labels
		$UILayer/Control/SpeakerBox/SpeakerLabel.text = line["character"]
		$UILayer/Control/DialogueBox/DialogueLabel.text = line["text"]
		$UILayer/Control/DialogueBox/DialogueLabel.visible_ratio = 0.0

		var text_length = line["text"].length()
		var duration = text_length * 0.07
		var typewriter_tween := create_tween()
		typewriter_tween.tween_property(
			$UILayer/Control/DialogueBox/DialogueLabel,
			"visible_ratio",
			1.0,
			duration
		)
		await typewriter_tween.finished
		await get_tree().create_timer(2.0 + (line["text"].length() * 0.009)).timeout

		lines_shown_in_panel += 1
		if lines_shown_in_panel >= lines_per_panel[current_panel]:
			current_panel += 1
			lines_shown_in_panel = 0
	$UILayer/Control/SpeakerBox.visible = false
	$UILayer/Control/DialogueBox.visible = false
	var screen_tween := create_tween()
	screen_tween.tween_property($MemoryOverlay, "color", Color("1a1a1a"), 2.0)
	await screen_tween.finished
	_on_scene_finished()
