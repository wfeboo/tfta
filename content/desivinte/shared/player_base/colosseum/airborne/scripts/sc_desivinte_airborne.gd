# Controlador de movimiento libre (2D) para personaje en vuelo / combate.
extends CharacterBody2D

const BRAKE_SPEED: float = 150.0
const BASE_SPEED_X: float = 280.0
const BASE_SPEED_Y: float = 220.0
const FORWARD_SPEED: float = 380.0
const SHIFT_SPEED: float = 180.0

var is_focused: bool = false
var facing_direction: float = 1.0

enum HorizontalState { BRAKING, BASE, FORWARD, FOCUSED }
enum VerticalState { NEUTRAL, UP, DOWN }

var horizontal_state: HorizontalState = HorizontalState.BASE
var vertical_state: VerticalState = VerticalState.NEUTRAL

var equipped_kit: Array[String] = ["DESIV_ATK_MELEE_JAB", "", "", ""]
var attack_hitbox: Area2D

@onready var health: Health = $Health

func _ready() -> void:
	add_to_group("player")
	add_to_group("damageables")

	var attack_hitbox_scene: PackedScene = preload("res://content/desivinte/shared/attack_hitbox/scn_attack_hitbox.tscn")
	attack_hitbox = attack_hitbox_scene.instantiate() as Area2D
	add_child(attack_hitbox)
	attack_hitbox.position = Vector2(30.0, 0.0)

func _physics_process(delta: float) -> void:
	var direction_x: float = Input.get_axis("move_left", "move_right")
	var direction_y: float = Input.get_axis("move_up", "move_down")
	
	is_focused = Input.is_action_pressed("modifier")
	var target_speed_x: float = BASE_SPEED_X
	
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

	velocity.x = move_toward(velocity.x, target_speed_x, 1000.0 * delta)
	
	var current_speed_y: float = SHIFT_SPEED if is_focused else BASE_SPEED_Y
	velocity.y = direction_y * current_speed_y

	if direction_y < 0:
		vertical_state = VerticalState.UP
	elif direction_y > 0:
		vertical_state = VerticalState.DOWN
	else:
		vertical_state = VerticalState.NEUTRAL

	if direction_x != 0.0:
		facing_direction = signf(direction_x)
		_update_hitbox_position()

	if Input.is_action_just_pressed("kit_1_action"):
		_try_attack(0)
	if Input.is_action_just_pressed("kit_2_action"):
		_try_attack(1)
	if Input.is_action_just_pressed("kit_3_action"):
		_try_attack(2)

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
		push_warning("AirbornePlayer: No se encontró el recurso para: " + attack_id)
		return
	_update_hitbox_position()
	if attack_hitbox and attack_hitbox.has_method("activate"):
		attack_hitbox.activate(attack_data, self)

func take_damage(amount: float) -> void:
	health.take_damage(amount)
