extends CharacterBody2D

const WALK_SPEED = 100.0
const JOG_SPEED = 170.0
const JUMP_VELOCITY = -400.0
enum States {IDLE, WALK, JOG, JUMP, FALL}

var can_doublejump = false
var current_state: States = States.IDLE

func _physics_process(delta: float) -> void:
# --- FÍSICA: gravedad, salto, doble salto ---
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif is_on_floor():
		can_doublejump = false
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		can_doublejump = true
	if Input.is_action_just_pressed("jump") and not is_on_floor() and can_doublejump:
		velocity.y = JUMP_VELOCITY
		can_doublejump = false
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		if Input.is_action_pressed("modifier"):
			velocity.x = direction * JOG_SPEED
		else:
			velocity.x = direction * WALK_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
# --- ESTADO: se decide DESPUÉS de que la física ya se resolvió ---
	if is_on_floor():
		if abs(velocity.x) < 1:
			current_state = States.IDLE
		elif abs(velocity.x) <= WALK_SPEED:
			current_state = States.WALK
		else:
			current_state = States.JOG
	elif velocity.y < 0:
		current_state = States.JUMP
	else:
		current_state = States.FALL

	move_and_slide()
