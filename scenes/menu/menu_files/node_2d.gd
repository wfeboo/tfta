extends Node2D

@export var buttons: Array[Button] = []

var hover_scale: Vector2 = Vector2(1.2, 1.2)
var normal_scale: Vector2 = Vector2(1.0, 1.0)
var tweens: Dictionary = {}

func _ready() -> void:
	# Si olvidaste asignar los botones en el Inspector, el código los buscará solo
	if buttons.is_empty():
		for child in get_children():
			if child is Button:
				buttons.append(child)
	
	# Si después de buscarlos sigue sin haber nada, recién ahí avisa
	if buttons.is_empty():
		push_error("No se encontraron botones como hijos de Node2D.")
		return

	await get_tree().process_frame

	for btn in buttons:
		if btn != null:
			btn.custom_minimum_size = btn.size
			btn.pivot_offset = btn.size / 2.0
			
			btn.mouse_entered.connect(_on_button_mouse_entered.bind(btn))
			btn.mouse_exited.connect(_on_button_mouse_exited.bind(btn))

# Se renombró _delta con guion bajo para quitar la advertencia amarilla
func _process(_delta: float) -> void:
	pass

func _on_button_mouse_entered(btn: Button) -> void:
	btn.pivot_offset = btn.size / 2.0
	_animate_scale(btn, hover_scale)

func _on_button_mouse_exited(btn: Button) -> void:
	_animate_scale(btn, normal_scale)

func _animate_scale(btn: Button, target_scale: Vector2) -> void:
	if tweens.has(btn) and tweens[btn] != null and tweens[btn].is_running():
		tweens[btn].kill()
		
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tweens[btn] = tween
	tween.tween_property(btn, "scale", target_scale, 0.4)
