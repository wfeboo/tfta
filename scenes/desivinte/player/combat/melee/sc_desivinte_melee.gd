extends CharacterBody2D

const BRAKE_SPEED = 150.0      # "retroceder" (en realidad frenar)
const BASE_SPEED = 280.0        # estático, avance automático
const FORWARD_SPEED = 380.0     # avanzar (input activo)
const SHIFT_SPEED = 520.0       # shift, máxima velocidad
const JUMP_VELOCITY = -400.0
enum MeleeStates {BRAKING, BASE, FORWARD,SPRINT, JUMP, FALL}

var can_doublejump = false
var current_state: MeleeStates = MeleeStates.BASE
var current_speed: float = BASE_SPEED


func _physics_process(delta: float) -> void:
	$Shift.text = "Is shifting: NO"
	$Pressing.text = "Currently moving: BASE"
	$Jumped.text = "Jumped: NO"
	$CanDJ.text = "Can double jump: NO"
# --- FÍSICA: gravedad, salto, doble salto ---
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif is_on_floor():
		can_doublejump = false
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$Jumped.text = "Jumped: YES"
		can_doublejump = true
		$CanDJ.text = "Can double jump: YES"
	if Input.is_action_just_pressed("jump") and not is_on_floor() and can_doublejump:
		$Jumped.text = "Jumped: YES"
		velocity.y = JUMP_VELOCITY
		can_doublejump = false
	if Input.is_action_pressed("move_left"):
		current_speed = move_toward(current_speed, BRAKE_SPEED, 500.0 * delta)
		$Pressing.text = "Currently moving: BRAKING"
	elif Input.is_action_pressed("modifier"):
		current_speed = move_toward(current_speed, SHIFT_SPEED, 500.0 * delta)
		$Shift.text = "Is shifting: YES"
	elif Input.is_action_pressed("move_right"):
		$Pressing.text = "Currently moving: FORWARD"
		current_speed = move_toward(current_speed, FORWARD_SPEED, 500.0 * delta)
	else:
		current_speed = move_toward(current_speed, BASE_SPEED, 500.0 * delta)
	if Input.is_action_just_pressed("kit_1_action"):
		pass
	if Input.is_action_just_pressed("kit_2_action"):
		pass
	if Input.is_action_just_pressed("kit_3_action"):
		pass
	if Input.is_action_just_pressed("kit_4_action"):
		pass
	velocity.x = current_speed
# --- ESTADO: se decide DESPUÉS de que la física ya se resolvió ---
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
