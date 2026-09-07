# Controlador del personaje para fases de exploración y navegación fuera de combate.
#
# Administra el movimiento terrestre (caminar/jogging), físicas de salto y doble salto,
# actualización de la máquina de estados de animación y la detección e interacción
# con elementos o personajes del mundo (NPCs, objetos, diálogos por defecto).
extends CharacterBody2D

# Configuración de constantes para velocidades de exploración y salto.
const WALK_SPEED: float = 100.0
const JOG_SPEED: float = 170.0
const JUMP_VELOCITY: float = -400.0

# Estados de movimiento e interacción para animaciones del mundo.
enum States {
	IDLE,
	WALK,
	JOG,
	JUMP,
	FALL
}

# Habilidad para realizar un segundo salto en el aire.
var can_doublejump: bool = false

# Estado de animación actual del personaje.
var current_state: States = States.IDLE

# Referencia al área interactuable (ej: NPCDUMMY) más cercana detectada.
var nearby_interactable: Area2D = null


func _physics_process(delta: float) -> void:
	# 1. FÍSICAS: Gravedad, salto y doble salto (deshabilitados si hay diálogo activo)
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		can_doublejump = false

	# Salto desde el suelo
	if Input.is_action_just_pressed("jump") and is_on_floor() and not DialogueUI.dialogue_active:
		velocity.y = JUMP_VELOCITY
		can_doublejump = true

	# Doble salto en el aire
	elif Input.is_action_just_pressed("jump") and not is_on_floor() and can_doublejump and not DialogueUI.dialogue_active:
		velocity.y = JUMP_VELOCITY
		can_doublejump = false

	# 2. MOVIMIENTO HORIZONTAL: Cancelar movimiento si hay diálogo en curso
	var direction: float = Input.get_axis("move_left", "move_right")

	if DialogueUI.dialogue_active:
		velocity.x = 0.0
	else:
		if direction != 0.0:
			if Input.is_action_pressed("modifier"):
				velocity.x = direction * JOG_SPEED
			else:
				velocity.x = direction * WALK_SPEED
		else:
			velocity.x = move_toward(velocity.x, 0.0, WALK_SPEED)

	# 3. MÁQUINA DE ESTADOS: Determinación del estado según movimiento y físicas
	if is_on_floor():
		if abs(velocity.x) < 1.0:
			current_state = States.IDLE
		elif abs(velocity.x) <= WALK_SPEED:
			current_state = States.WALK
		else:
			current_state = States.JOG
	elif velocity.y < 0:
		current_state = States.JUMP
	else:
		current_state = States.FALL

	# 4. SISTEMA DE INTERACCIÓN: Ejecutar acción de objeto cercano o diálogo por defecto
	if Input.is_action_just_pressed("interact") and not DialogueUI.dialogue_active:
		if nearby_interactable != null and nearby_interactable.has_method("interact"):
			nearby_interactable.interact()
		else:
			# Diálogo por defecto si se presiona interactuar sin ningún objeto cerca
			DialogueUI.show_dialogue("INTER-DESIV-0000", self)

	# 5. Resolver movimiento físico
	move_and_slide()


# Callback para recibir eventos/triggers específicos enviados por DialogueUI durante diálogos.
#
# Parámetros:
#   - trigger: Identificador de la acción o evento desencadenado por el diálogo.
func handle_trigger(trigger: String) -> void:
	pass


# Evento ejecutado al entrar un Area2D dentro de la zona de interacción del personaje.
func _on_interaction_area_area_entered(area: Area2D) -> void:
	nearby_interactable = area


# Evento ejecutado al salir un Area2D de la zona de interacción del personaje.
func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area == nearby_interactable:
		nearby_interactable = null
