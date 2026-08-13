extends Node2D

var hover_scale: Vector2 = Vector2(1.1, 1.1)
var normal_scale: Vector2 = Vector2(1.0, 1.0)
var animation_duration: float = 0.35

var tweens: Dictionary = {}
var settings_group: Node2D

func _ready() -> void:
	await get_tree().process_frame
	
	settings_group = find_child("SettingsGroup", true, false) as Node2D

	if settings_group != null:
		settings_group.visible = false

	var found_buttons: Array[Node] = find_children("*", "BaseButton", true, false)
	
	for btn in found_buttons:
		if btn is BaseButton:
			# Si el botón está dentro del menú de ajustes, ignoramos la apertura/cierre
			if settings_group != null and settings_group.is_ancestor_of(btn):
				continue
				
			btn.mouse_filter = Control.MOUSE_FILTER_STOP
			
			if "size" in btn and btn.size != Vector2.ZERO:
				btn.pivot_offset = btn.size / 2.0
			
			# LIMPIEZA TOTAL DE CONEXIONES DUPLICADAS EN GODOT 4
			for conn in btn.pressed.get_connections():
				btn.pressed.disconnect(conn.callable)
			for conn in btn.mouse_entered.get_connections():
				btn.mouse_entered.disconnect(conn.callable)
			for conn in btn.mouse_exited.get_connections():
				btn.mouse_exited.disconnect(conn.callable)
			
			# Conectamos limpiamente una sola vez
			btn.mouse_entered.connect(_on_button_hover_enter.bind(btn))
			btn.mouse_exited.connect(_on_button_hover_exit.bind(btn))
			btn.pressed.connect(_on_any_button_pressed.bind(btn))

# --- ANIMACIONES HOVER ---

func _on_button_hover_enter(btn: BaseButton) -> void:
	if "size" in btn and btn.size != Vector2.ZERO:
		btn.pivot_offset = btn.size / 2.0
	_animate_scale(btn, hover_scale)

func _on_button_hover_exit(btn: BaseButton) -> void:
	_animate_scale(btn, normal_scale)

func _animate_scale(btn: BaseButton, target_scale: Vector2) -> void:
	if tweens.has(btn) and tweens[btn] != null and tweens[btn].is_running():
		tweens[btn].kill()
		
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tweens[btn] = tween
	tween.tween_property(btn, "scale", target_scale, animation_duration)

# --- MANEJADOR DE CLICS ---


func _on_any_button_pressed(btn: BaseButton) -> void:
	var btn_name: String = btn.name.strip_edges().to_lower()
	
	if btn_name == "settings":
		if settings_group != null:
			settings_group.visible = !settings_group.visible
			print(" Visibilidad actual del menú: ", settings_group.visible)
			
	elif btn_name == "quitgame":
		get_tree().quit()
