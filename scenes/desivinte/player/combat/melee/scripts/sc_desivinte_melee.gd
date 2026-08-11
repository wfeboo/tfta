extends CharacterBody2D

const BRAKE_SPEED = 150.0
const BASE_SPEED = 280.0
const FORWARD_SPEED = 380.0
const SHIFT_SPEED = 520.0
const JUMP_VELOCITY = -400.0

enum MeleeStates {
	BRAKING,
	BASE,
	FORWARD,
	SPRINT,
	JUMP,
	FALL
}

var can_doublejump: bool = false
var current_state: MeleeStates = MeleeStates.BASE
var current_speed: float = BASE_SPEED

# Los 4 slots de ataque equipados.
# "" significa slot vacío.
# Slot 0 = Jab, ataque base.
var equipped_kit: Array[String] = [
	"DESIV_ATK_MELEE_JAB",
	"",
	"",
	""
]

var attack_hitbox: Area2D


func _ready() -> void:
	var attack_hitbox_scene = preload(
		"res://scenes/desivinte/player/combat/melee/scenes/scn_attack_hitbox.tscn"
	)

	attack_hitbox = attack_hitbox_scene.instantiate()
	add_child(attack_hitbox)

	# La hitbox queda delante del personaje.
	attack_hitbox.position = Vector2(30, 0)


func _physics_process(delta: float) -> void:

	# =========================================================
	# FÍSICA
	# =========================================================

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		can_doublejump = false


	# =========================================================
	# SALTO / DOBLE SALTO
	# =========================================================

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		can_doublejump = true

	elif Input.is_action_just_pressed("jump") \
	and not is_on_floor() \
	and can_doublejump:
		velocity.y = JUMP_VELOCITY
		can_doublejump = false


	# =========================================================
	# VELOCIDAD HORIZONTAL
	# =========================================================

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


	# =========================================================
	# KIT DE ATAQUES
	# =========================================================

	if Input.is_action_just_pressed("kit_1_action"):
		_try_attack(0)

	if Input.is_action_just_pressed("kit_2_action"):
		_try_attack(1)

	if Input.is_action_just_pressed("kit_3_action"):
		_try_attack(2)

	if Input.is_action_just_pressed("kit_4_action"):
		pass


	# =========================================================
	# ESTADO
	# =========================================================

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


	move_and_slide()


func _try_attack(slot: int) -> void:
	var attack_id: String = equipped_kit[slot]

	if attack_id.is_empty():
		return

	var attack_data: AttackData = AttackDatabase.get_attack(attack_id)

	if attack_data == null:
		push_warning("No se encontró el ataque: " + attack_id)
		return

	attack_hitbox.activate(attack_data)
