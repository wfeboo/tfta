extends Node2D

# Scale settings
var hover_scale: Vector2 = Vector2(1.2, 1.2)
var normal_scale: Vector2 = Vector2(1.0, 1.0)
var animation_duration: float = 0.35

# Dictionary to manage smooth transitions per button
var tweens: Dictionary = {}

func _ready() -> void:
	# Small delay to ensure Godot has calculated the visual size of all UI elements
	await get_tree().process_frame
	
	# Find all buttons under Node2D and CanvasLayer
	var found_buttons: Array[Node] = find_children("*", "Button", true, false)
	
	for btn in found_buttons:
		if btn is Button:
			# Ensure mouse events are active on the control
			btn.mouse_filter = Control.MOUSE_FILTER_STOP
			
			# Set the transform pivot to the center of each button
			btn.pivot_offset = btn.size / 2.0
			
			# Connect hover events
			btn.mouse_entered.connect(_on_button_hover_enter.bind(btn))
			btn.mouse_exited.connect(_on_button_hover_exit.bind(btn))
			
			# Connect click event if this button is the quit button
			if btn.name == "QuitGame":
				btn.pressed.connect(_on_quit_game_pressed)

func _on_button_hover_enter(btn: Button) -> void:
	btn.pivot_offset = btn.size / 2.0
	_animate_scale(btn, hover_scale)

func _on_button_hover_exit(btn: Button) -> void:
	_animate_scale(btn, normal_scale)

func _animate_scale(btn: Button, target_scale: Vector2) -> void:
	if tweens.has(btn) and tweens[btn] != null and tweens[btn].is_running():
		tweens[btn].kill()
		
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tweens[btn] = tween
	tween.tween_property(btn, "scale", target_scale, animation_duration)

func _on_quit_game_pressed() -> void:
	get_tree().quit()
