# Controlador de combate convencional (estático, sin avance forzado).
# Usado fuera del coliseo — ej. peleas iniciadas por interacción en el overworld.
extends CharacterBody2D

const MOVE_SPEED: float = 250.0  # ajustar a gusto, no tiene por qué igualar a Melee
const JUMP_VELOCITY: float = -400.0

var can_doublejump: bool = false
var equipped_kit: Array[String] = [
	"DESIV_ATK_MELEE_JAB",
	"", "", ""
]
var attack_hitbox: Area2D

func _ready() -> void:
	var attack_hitbox_scene: PackedScene = preload(
		"res://scenes/desivinte/player/combat/shared/scn_attack_hitbox.tscn"
	)
	attack_hitbox = attack_hitbox_scene.instantiate() as Area2D
	add_child(attack_hitbox)
	attack_hitbox.position = Vector2(30.0, 0.0)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		can_doublejump = false

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		can_doublejump = true
	elif Input.is_action_just_pressed("jump") and not is_on_floor() and can_doublejump:
		velocity.y = JUMP_VELOCITY
		can_doublejump = false

	# Movimiento libre izquierda/derecha, sin estados de avance tipo coliseo
	var direction: float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * MOVE_SPEED

	if Input.is_action_just_pressed("kit_1_action"):
		_try_attack(0)
	if Input.is_action_just_pressed("kit_2_action"):
		_try_attack(1)
	if Input.is_action_just_pressed("kit_3_action"):
		_try_attack(2)

	move_and_slide()

func _try_attack(slot: int) -> void:
	if slot < 0 or slot >= equipped_kit.size():
		return
	var attack_id: String = equipped_kit[slot]
	if attack_id.is_empty():
		return
	var attack_data: AttackData = AttackDatabase.get_attack(attack_id)
	if attack_data == null:
		push_warning("ConventionalCombat: No se encontró el recurso de ataque para el ID: " + attack_id)
		return
	if attack_hitbox and attack_hitbox.has_method("activate"):
		attack_hitbox.activate(attack_data)
