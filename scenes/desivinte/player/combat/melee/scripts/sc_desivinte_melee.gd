extends CharacterBody2D

# Configuración de velocidades de movimiento y fuerza de salto
const BRAKE_SPEED = 150.0
const BASE_SPEED = 280.0
const FORWARD_SPEED = 380.0
const SHIFT_SPEED = 520.0
const JUMP_VELOCITY = -400.0

# Enum que define los estados posibles en el modo terrestre/Melee
enum MeleeStates {
	BRAKING,
	BASE,
	FORWARD,
	SPRINT,
	JUMP,
	FALL
}

# Control para permitir el doble salto
var can_doublejump: bool = false

# Estado y velocidad actual del personaje
var current_state: MeleeStates = MeleeStates.BASE
var current_speed: float = BASE_SPEED

# Lista de los 4 slots de ataque equipados ("" indica slot vacío)
# El slot 0 contiene el ataque Jab base por defecto
var equipped_kit: Array[String] = [
	"DESIV_ATK_MELEE_JAB",
	"",
	"",
	""
]

# Referencia al área encargada de registrar los golpes
var attack_hitbox: Area2D


func _ready() -> void:
	# Precarga e instanciación de la hitbox de ataque como nodo hijo
	var attack_hitbox_scene = preload(
		"res://scenes/desivinte/player/combat/melee/scenes/scn_attack_hitbox.tscn"
	)

	attack_hitbox = attack_hitbox_scene.instantiate()
	add_child(attack_hitbox)

	# Ubica la hitbox ligeramente hacia adelante del personaje
	attack_hitbox.position = Vector2(30, 0)


func _physics_process(delta: float) -> void:

	# Aplica la gravedad si está en el aire o reinicia la habilidad de doble salto si está en el suelo
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		can_doublejump = false


	# Maneja el primer salto desde el suelo o el segundo salto en el aire
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		can_doublejump = true

	elif Input.is_action_just_pressed("jump") \
	and not is_on_floor() \
	and can_doublejump:
		velocity.y = JUMP_VELOCITY
		can_doublejump = false


	# Calcula la velocidad horizontal progresiva según la tecla de dirección o modificador presionada
	if Input.is_action_pressed("move_left"):
		current_speed = move_toward(
			current_speed,
			BRAKE_SPEED,
			500.0 * delta
		)

	elif Input.is_action_pressed("modifier"):
		current_speed = move_toward(
			current_speed,
			SHIFT_SPEED,
			500.0 * delta
		)

	elif Input.is_action_pressed("move_right"):
		current_speed = move_toward(
			current_speed,
			FORWARD_SPEED,
			500.0 * delta
		)

	elif Input.is_action_pressed("move_up"):
		current_speed = 0

	else:
		current_speed = move_toward(
			current_speed,
			BASE_SPEED,
			500.0 * delta
		)

	velocity.x = current_speed


	# Detecta los botones de ataque e intenta ejecutar la habilidad asignada al slot correspondiente
	if Input.is_action_just_pressed("kit_1_action"):
		_try_attack(0)

	if Input.is_action_just_pressed("kit_2_action"):
		_try_attack(1)

	if Input.is_action_just_pressed("kit_3_action"):
		_try_attack(2)

	if Input.is_action_just_pressed("kit_4_action"):
		pass


	# Actualiza el estado del personaje según la velocidad horizontal o el estado vertical (salto/caída)
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


	# Ejecuta la física de movimiento del motor Godot
	move_and_slide()


# Valida si existe un ataque configurado en el slot seleccionado y activa la hitbox con sus datos
func _try_attack(slot: int) -> void:
	var attack_id: String = equipped_kit[slot]

	if attack_id.is_empty():
		return

	var attack_data: AttackData = AttackDatabase.get_attack(attack_id)

	if attack_data == null:
		push_warning("No se encontró el ataque: " + attack_id)
		return

	attack_hitbox.activate(attack_data)
