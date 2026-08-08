extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
enum States {IDLE, WALK, JOG, JUMP, FALL}

var can_doublejump = false
var current_state: States = States.IDLE

func _physics_process(delta: float) -> void:
	# --- FÍSICA: gravedad, salto, doble salto ---
	if not is_on_floor():
		velocity += get_gravity() * delta
		current_state = States.FALL
	elif is_on_floor():
		can_doublejump = false
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		can_doublejump = true
	if Input.is_action_just_pressed("jump") and not is_on_floor() and can_doublejump:
		velocity.y = JUMP_VELOCITY
		can_doublejump = false
	
	# --- ESTADO: se decide DESPUÉS de que la física ya se resolvió ---
	if is_on_floor():
		current_state = States.IDLE
	elif velocity.y < 0:
		current_state = States.JUMP
	else:
		current_state = States.FALL
		
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
