# Controlador de combate del jugador (Desivinte).
extends CharacterBody2D

# Configuración de movimiento
const MOVE_SPEED: float = 250.0
const JUMP_VELOCITY: float = -400.0

var can_doublejump: bool = false
var facing_direction: float = 1.0 # 1.0 = derecha, -1.0 = izquierda

# Control de Knockback / Stun
var _knockback_timer: float = 0.0
const KNOCKBACK_DECAY: float = 800.0 # Qué tan rápido se desacelera el empuje horizontal

# Habilidades equipadas
var equipped_kit: Array[String] = [
	"DESIV_ATK_MELEE_JAB",
	"", "", ""
]
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
	# 1. Aplicar gravedad y reinicio de salto doble
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		can_doublejump = false

	# 2. Si el personaje está sufriendo knockback, procesar la desaceleración e ignorar inputs
	if _knockback_timer > 0.0:
		_knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, KNOCKBACK_DECAY * delta)
		move_and_slide()
		return

	# 3. Lógica de salto (Solo si no está en knockback)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		can_doublejump = true
	elif Input.is_action_just_pressed("jump") and not is_on_floor() and can_doublejump:
		velocity.y = JUMP_VELOCITY
		can_doublejump = false

	# 4. Movimiento horizontal y actualización de orientación
	var direction: float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * MOVE_SPEED

	if direction != 0.0:
		facing_direction = signf(direction)
		_update_hitbox_position()

	# 5. Entradas de ataque
	if Input.is_action_just_pressed("kit_1_action"):
		_try_attack(0)
	if Input.is_action_just_pressed("kit_2_action"):
		_try_attack(1)
	if Input.is_action_just_pressed("kit_3_action"):
		_try_attack(2)

	move_and_slide()

# Ajusta la posición de la hitbox según la dirección del jugador
func _update_hitbox_position() -> void:
	if attack_hitbox:
		var offset_x: float = 30.0
		attack_hitbox.position.x = offset_x * facing_direction

# Intenta ejecutar el ataque del slot seleccionado
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
		
	_update_hitbox_position()
	
	if attack_hitbox and attack_hitbox.has_method("activate"):
		attack_hitbox.activate(attack_data, self)

# Aplica la fuerza de empuje e inhabilita las entradas temporalmente
func apply_knockback(force: Vector2) -> void:
	velocity = force
	_knockback_timer = 0.25 # Duración del empuje/stun en segundos

# Recibir daño mediante el nodo Health
func take_damage(amount: float) -> void:
	health.take_damage(amount)
