# Controlador de física y combate para el personaje en modo terrestre (Melee).
#
# Administra la física de plataformas (gravedad, salto y doble salto), el control
# progresivo de velocidad horizontal según la dirección/sprint, la gestión de
# estados animados y la ejecución de ataques basados en un kit de habilidades.
extends CharacterBody2D

# Configuración de constantes para físicas de movimiento y salto.
const BRAKE_SPEED: float = 150.0
const BASE_SPEED: float = 280.0
const FORWARD_SPEED: float = 380.0
const SHIFT_SPEED: float = 520.0
const JUMP_VELOCITY: float = -400.0

# Estados de animación/físicas posibles para el modo terrestre.
enum MeleeStates {
	BRAKING,
	BASE,
	FORWARD,
	SPRINT,
	JUMP,
	FALL
}

# Control para habilitar la mecánica de doble salto en el aire.
var can_doublejump: bool = false

# Estado y velocidad horizontal actual del personaje.
var current_state: MeleeStates = MeleeStates.BASE
var current_speed: float = BASE_SPEED

# Registro de los 4 slots de ataque equipados (guarda los ID de los ataques).
# Por defecto incluye el ataque Jab base en el primer slot.
var equipped_kit: Array[String] = [
	"DESIV_ATK_MELEE_JAB",
	"",
	"",
	""
]

# Referencia a la hitbox de ataque instanciada dinámicamente.
var attack_hitbox: Area2D


func _ready() -> void:
	# Instanciar y configurar el área de colisión (hitbox) para los ataques
	var attack_hitbox_scene: PackedScene = preload(
		"res://scenes/desivinte/player/combat/melee/scenes/scn_attack_hitbox.tscn"
	)

	attack_hitbox = attack_hitbox_scene.instantiate() as Area2D
	add_child(attack_hitbox)

	# Posicionar la hitbox desplazada horizontalmente con respecto al personaje
	attack_hitbox.position = Vector2(30.0, 0.0)


func _physics_process(delta: float) -> void:
	# 1. Aplicación de gravedad y reinicio de salto
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		can_doublejump = false

	# 2. Gestión de salto principal y doble salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		can_doublejump = true

	elif Input.is_action_just_pressed("jump") and not is_on_floor() and can_doublejump:
		velocity.y = JUMP_VELOCITY
		can_doublejump = false

	# 3. Control de aceleración y velocidad horizontal
	if Input.is_action_pressed("move_left"):
		current_speed = move_toward(current_speed, BRAKE_SPEED, 500.0 * delta)

	elif Input.is_action_pressed("modifier"):
		current_speed = move_toward(current_speed, SHIFT_SPEED, 500.0 * delta)

	elif Input.is_action_pressed("move_right"):
		current_speed = move_toward(current_speed, FORWARD_SPEED, 500.0 * delta)

	elif Input.is_action_pressed("move_up"):
		current_speed = 0.0

	else:
		current_speed = move_toward(current_speed, BASE_SPEED, 500.0 * delta)

	velocity.x = current_speed

	# 4. Escuchar entradas de ataque (Kit de habilidades)
	if Input.is_action_just_pressed("kit_1_action"):
		_try_attack(0)

	if Input.is_action_just_pressed("kit_2_action"):
		_try_attack(1)

	if Input.is_action_just_pressed("kit_3_action"):
		_try_attack(2)

	if Input.is_action_just_pressed("kit_4_action"):
		pass

	# 5. Actualización de la máquina de estados según velocidad y física vertical
	if is_on_floor():
		if abs(velocity.x) <= BRAKE_SPEED:
			current_state = MeleeStates.BRAKING

		elif abs(velocity.x) <= BASE_SPEED:
			current_state = MeleeStates.BASE

		elif abs(velocity.x) <= FORWARD_SPEED:
			current_state = MeleeStates.FORWARD

		else:
			current_state = MeleeStates.SPRINT

	elif velocity.y < 0:
		current_state = MeleeStates.JUMP

	else:
		current_state = MeleeStates.FALL

	# 6. Ejecutar movimiento físico en el motor Godot
	move_and_slide()


# Valida si existe un ataque asignado en el slot del kit y activa la hitbox con su recurso.
#
# Parámetros:
#   - slot: Índice del arreglo 'equipped_kit' a consultar (0 a 3).
func _try_attack(slot: int) -> void:
	if slot < 0 or slot >= equipped_kit.size():
		return

	var attack_id: String = equipped_kit[slot]

	if attack_id.is_empty():
		return

	var attack_data: AttackData = AttackDatabase.get_attack(attack_id)

	if attack_data == null:
		push_warning("MeleePlayer: No se encontró el recurso de ataque para el ID: " + attack_id)
		return

	if attack_hitbox and attack_hitbox.has_method("activate"):
		attack_hitbox.activate(attack_data)
