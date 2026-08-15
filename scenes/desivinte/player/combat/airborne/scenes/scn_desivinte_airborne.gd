extends CharacterBody2D

# Configuración de velocidades según la acción o estado
const BRAKE_SPEED = 150.0
const BASE_SPEED_X = 280.0
const BASE_SPEED_Y = 220.0
const FORWARD_SPEED = 380.0
# Ahora es menor porque cuando vuela, shift disminuye la velocidad del jugador (focus mode)
const SHIFT_SPEED = 180.0

# Bandera para saber si el modo "Focus" (Shift) está activo
var is_focused = false

# Estados relacionados con el movimiento horizontal
enum HorizontalState {
	BRAKING,
	BASE,
	FORWARD,
	FOCUSED
}

# Estados relacionados con el movimiento vertical
enum VerticalState {
	NEUTRAL,
	UP,
	DOWN
}

# Estado actual del personaje (por defecto empieza en BASE)
var horizontal_state: HorizontalState = HorizontalState.BASE
var vertical_state: VerticalState = VerticalState.NEUTRAL

func _physics_process(delta: float) -> void:
	# Obtiene las entradas del jugador (-1, 0, o 1 en cada eje)
	var direction_x := Input.get_axis("move_left", "move_right")
	var direction_y := Input.get_axis("move_up", "move_down")
	
	# Revisa si la tecla de modificación (ej. Shift) está presionada
	is_focused = Input.is_action_pressed("modifier")
	var target_speed_x: float = BASE_SPEED_X
	
	# Evalúa el estado horizontal y asigna la velocidad objetivo en X
	if is_focused:
		horizontal_state = HorizontalState.FOCUSED
		target_speed_x = SHIFT_SPEED
	elif direction_x < 0:
		horizontal_state = HorizontalState.BRAKING
		target_speed_x = BRAKE_SPEED
	elif direction_x > 0:
		horizontal_state = HorizontalState.FORWARD
		target_speed_x = FORWARD_SPEED
	else:
		horizontal_state = HorizontalState.BASE
		target_speed_x = BASE_SPEED_X

	# Aplica una aceleración suave (suavizado de movimiento) hacia la velocidad objetivo en X
	velocity.x = move_toward(velocity.x, target_speed_x, 1000.0 * delta)
	
	# Determina la velocidad vertical dependiendo de si está en modo "Focus"
	var current_speed_y = SHIFT_SPEED if is_focused else BASE_SPEED_Y
	velocity.y = direction_y * current_speed_y

	# Cambia el estado a UP o DOWN si hay movimiento vertical
	# (Nota: Esto sobreescribirá los estados FOCUSED, BRAKING o FORWARD en el enum)
	if direction_y < 0:
		vertical_state = VerticalState.UP

	elif direction_y > 0:
		vertical_state = VerticalState.DOWN

	else:
		vertical_state = VerticalState.NEUTRAL

	# Ejecuta la física de movimiento del motor Godot
	move_and_slide()
