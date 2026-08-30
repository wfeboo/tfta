# Controlador de movimiento libre (2D) para personaje en vuelo / combate.
#
# Administra la velocidad horizontal y vertical utilizando una máquina de estados 
# basada en enums. Incluye modo "Focus" (Shift) para reducir la velocidad y permitir 
# un control de precisión, además de aceleración suave con 'move_toward'.
extends CharacterBody2D

# Configuración de velocidades según la acción o estado actual del jugador.
const BRAKE_SPEED: float = 150.0
const BASE_SPEED_X: float = 280.0
const BASE_SPEED_Y: float = 220.0
const FORWARD_SPEED: float = 380.0
const SHIFT_SPEED: float = 180.0

# Bandera que indica si el modo de precisión / Focus (tecla Shift) está activo.
var is_focused: bool = false

# Estados posibles para el movimiento horizontal.
enum HorizontalState {
	BRAKING,
	BASE,
	FORWARD,
	FOCUSED
}

# Estados posibles para el movimiento vertical.
enum VerticalState {
	NEUTRAL,
	UP,
	DOWN
}

# Estado actual del personaje en cada eje.
var horizontal_state: HorizontalState = HorizontalState.BASE
var vertical_state: VerticalState = VerticalState.NEUTRAL


func _physics_process(delta: float) -> void:
	# Obtener la entrada vectorial del jugador (-1.0, 0.0, o 1.0)
	var direction_x: float = Input.get_axis("move_left", "move_right")
	var direction_y: float = Input.get_axis("move_up", "move_down")
	
	# Detectar si la tecla de modificación (Focus) está presionada
	is_focused = Input.is_action_pressed("modifier")
	var target_speed_x: float = BASE_SPEED_X
	
	# Determinar el estado horizontal y asignar la velocidad objetivo en X
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

	# Aplicar interpolación suave hacia la velocidad objetivo en X
	velocity.x = move_toward(velocity.x, target_speed_x, 1000.0 * delta)
	
	# Ajustar la velocidad del eje Y según el estado del modo Focus
	var current_speed_y: float = SHIFT_SPEED if is_focused else BASE_SPEED_Y
	velocity.y = direction_y * current_speed_y

	# Actualizar el estado vertical
	if direction_y < 0:
		vertical_state = VerticalState.UP
	elif direction_y > 0:
		vertical_state = VerticalState.DOWN
	else:
		vertical_state = VerticalState.NEUTRAL

	# Ejecutar el movimiento físico del personaje
	move_and_slide()
