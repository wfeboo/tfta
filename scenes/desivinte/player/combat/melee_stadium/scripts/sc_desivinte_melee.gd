# Controlador de física y combate para el personaje en modo terrestre (Melee).
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
var facing_direction: float = 1.0

# Control de Knockback / Stun
var _knockback_timer: float = 0.0
const KNOCKBACK_DECAY: float = 800.0

# Registro de los 4 slots de ataque equipados.
var equipped_kit: Array[String] = [
	"DESIV_ATK_MELEE_JAB",
	"",
	"",
	""
]

# Referencia a la hitbox de ataque instanciada dinámicamente.
var attack_hitbox: Area2D

@onready var health: Health = $Health


func _ready() -> void:
	var attack_hitbox_scene: PackedScene = preload("res://scenes/desivinte/player/combat/shared/scn_attack_hitbox.tscn")
	attack_hitbox = attack_hitbox_scene.instantiate() as Area2D
	add_child(attack_hitbox)
	attack_hitbox.position = Vector2(30.0, 0.0)
	
	add_to_group("player")
	add_to_group("damageables")


func _physics_process(delta: float) -> void:
	# 1. Aplicación de gravedad y reinicio de salto
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		can_doublejump = false

	# 2. Gestión de Knockback: anula los controles y desacelera progresivamente
	if _knockback_timer > 0.0:
		_knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, KNOCKBACK_DECAY * delta)
		current_speed = abs(velocity.x)
		move_and_slide()
		return

	# 3. Gestión de salto principal y doble salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		can_doublejump = true

	elif Input.is_action_just_pressed("jump") and not is_on_floor() and can_doublejump:
		velocity.y = JUMP_VELOCITY
		can_doublejump = false

	# 4. Control de aceleración y velocidad horizontal
	if Input.is_action_pressed("move_left"):
		current_speed = move_toward(current_speed, BRAKE_SPEED, 500.0 * delta)
		facing_direction = -1.0
		_update_hitbox_position()

	elif Input.is_action_pressed("modifier"):
		current_speed = move_toward(current_speed, SHIFT_SPEED, 500.0 * delta)
		facing_direction = 1.0
		_update_hitbox_position()

	elif Input.is_action_pressed("move_right"):
		current_speed = move_toward(current_speed, FORWARD_SPEED, 500.0 * delta)
		facing_direction = 1.0
		_update_hitbox_position()

	elif Input.is_action_pressed("move_up"):
		current_speed = 0.0

	else:
		current_speed = move_toward(current_speed, BASE_SPEED, 500.0 * delta)

	velocity.x = current_speed

	# 5. Escuchar entradas de ataque (Kit de habilidades)
	if Input.is_action_just_pressed("kit_1_action"):
		_try_attack(0)

	if Input.is_action_just_pressed("kit_2_action"):
		_try_attack(1)

	if Input.is_action_just_pressed("kit_3_action"):
		_try_attack(2)

	if Input.is_action_just_pressed("kit_4_action"):
		pass

	# 6. Actualización de la máquina de estados según velocidad y física vertical
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

	# 7. Ejecutar movimiento físico
	move_and_slide()


func _update_hitbox_position() -> void:
	if attack_hitbox:
		attack_hitbox.position.x = 30.0 * facing_direction


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

	_update_hitbox_position()

	if attack_hitbox and attack_hitbox.has_method("activate"):
		attack_hitbox.activate(attack_data, self)


# Aplica la fuerza de empuje e inhabilita las entradas temporalmente
func apply_knockback(force: Vector2) -> void:
	velocity = force
	_knockback_timer = 0.25 # Duración del empuje/stun en segundos


func take_damage(amount: float) -> void:
	health.take_damage(amount)
