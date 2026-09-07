# Lin: Oponente del Chapter 0 con IA básica de combate en 2D.
extends CharacterBody2D

# Referencias principales
@onready var health: Health = $Health
var player: Node2D = null

var attack_hitbox: Area2D

# Configuración de movimiento y rangos
const MOVE_SPEED: float = 100.0
const JUMP_VELOCITY: float = -380.0
const CHASE_RANGE: float = 300.0
const IDEAL_DISTANCE: float = 110.0

# Control de Knockback / Stun
var _knockback_timer: float = 0.0
const KNOCKBACK_DECAY: float = 800.0

# Umbral en eje Y para considerar que el jugador saltó o está arriba
const JUMP_THRESHOLD_Y: float = 40.0

# Configuración de rangos y cooldowns de ataque
const NORMAL_ATTACK_RANGE: float = 80.0
const SWORD_ATTACK_RANGE: float = 150.0

const NORMAL_ATTACK_COOLDOWN: float = 2.0
const SWORD_ATTACK_COOLDOWN: float = 3.0

var _normal_cooldown: float = 0.0
var _sword_cooldown: float = 0.0

# Máquina de estados
enum State {
	IDLE,
	CHASE,
	ATTACK,
	COOLDOWN
}

var _state: State = State.IDLE
var _is_attacking: bool = false

func _ready() -> void:
	add_to_group("damageables")
	add_to_group("enemies")
	health.threshold_crossed.connect(_on_threshold_crossed)

	# Instanciar e inicializar la hitbox de ataque compartida
	var attack_hitbox_scene: PackedScene = preload(
		"res://content/desivinte/shared/attack_hitbox/scn_attack_hitbox.tscn"
	)
	attack_hitbox = attack_hitbox_scene.instantiate() as Area2D
	add_child(attack_hitbox)
	attack_hitbox.position = Vector2(-30.0, 0.0)

func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 1. Procesar Knockback si fue golpeada por Desivinte
	if _knockback_timer > 0.0:
		_knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, KNOCKBACK_DECAY * delta)
		move_and_slide()
		return

	# Actualizar temporizadores de recarga (cooldowns)
	_normal_cooldown = maxf(_normal_cooldown - delta, 0.0)
	_sword_cooldown = maxf(_sword_cooldown - delta, 0.0)

	# 2. Verificar y reobtener referencia al jugador dinámicamente
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not player:
			velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED * delta)
			move_and_slide()
			return

	var distance: float = global_position.distance_to(player.global_position)

	# Ejecutar lógica según el estado actual de la IA
	match _state:
		State.IDLE:
			_idle(distance)
		State.CHASE:
			_chase(distance, delta)
		State.ATTACK:
			# Frenado rápido durante la animación o ventana de ataque
			velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED * delta * 4.0)
		State.COOLDOWN:
			_cooldown(distance, delta)

	move_and_slide()

# Estado IDLE: Permanece detenido hasta que el jugador entra en rango de persecución
func _idle(distance: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED * 0.2)
	if distance <= CHASE_RANGE:
		_state = State.CHASE

# Estado CHASE: Evalúa rangos de ataque, movimiento horizontal y saltos
func _chase(distance: float, delta: float) -> void:
	var direction: float = signf(player.global_position.x - global_position.x)
	_face_player(direction)

	# Comprobar si debe saltar
	_check_jump()

	# Intento de ataque normal (Prioridad en distancia corta)
	if distance <= NORMAL_ATTACK_RANGE and _normal_cooldown <= 0.0:
		_attack_normal()
		return

	# Intento de ataque con espada (Prioridad en distancia media)
	if distance <= SWORD_ATTACK_RANGE and _sword_cooldown <= 0.0:
		_attack_sword()
		return

	# Acercarse al jugador si supera la distancia ideal
	if distance <= IDEAL_DISTANCE:
		velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED * delta * 3.0)
	else:
		velocity.x = direction * MOVE_SPEED

# Revisa la altura relativa del jugador para hacer saltar a Lin
func _check_jump() -> void:
	if not is_on_floor():
		return

	var player_height_difference: float = global_position.y - player.global_position.y
	
	if player_height_difference > JUMP_THRESHOLD_Y:
		velocity.y = JUMP_VELOCITY

# Estado COOLDOWN: Espera a que los temporizadores de ataque se liberen
func _cooldown(distance: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED * delta * 3.0)
	if _normal_cooldown <= 0.0 and _sword_cooldown <= 0.0:
		_state = State.CHASE

# Realiza el ataque básico
func _attack_normal() -> void:
	var attack_data: AttackData = AttackDatabase.get_attack("LIN_ATK_BASIC")
	if attack_data == null:
		push_warning("Lin: No se encontró 'LIN_ATK_BASIC'.")
		return

	_state = State.ATTACK
	_is_attacking = true
	_normal_cooldown = NORMAL_ATTACK_COOLDOWN
	_face_player(signf(player.global_position.x - global_position.x))

	print("Lin utiliza ataque normal.")
	if attack_hitbox and attack_hitbox.has_method("activate"):
		await attack_hitbox.activate(attack_data, self)

	_is_attacking = false
	_state = State.COOLDOWN

# Realiza el ataque con espada
func _attack_sword() -> void:
	var attack_data: AttackData = AttackDatabase.get_attack("LIN_ATK_SWORD")
	if attack_data == null:
		push_warning("Lin: No se encontró 'LIN_ATK_SWORD'.")
		return

	_state = State.ATTACK
	_is_attacking = true
	_sword_cooldown = SWORD_ATTACK_COOLDOWN
	_face_player(signf(player.global_position.x - global_position.x))

	print("Lin utiliza ESPADA.")
	if attack_hitbox and attack_hitbox.has_method("activate"):
		await attack_hitbox.activate(attack_data, self)

	_is_attacking = false
	_state = State.COOLDOWN

# Orientación y reposicionamiento de la hitbox según la dirección del jugador
func _face_player(direction: float) -> void:
	if direction == 0.0:
		return

	var hitbox_offset: float = 30.0
	attack_hitbox.position.x = -hitbox_offset if direction < 0 else hitbox_offset

# Recibir daño
func take_damage(amount: float) -> void:
	health.take_damage(amount)
	print("OW")

# Callback al cruzar umbrales de vida
func _on_threshold_crossed(percent: float) -> void:
	print("Lin cruzó el umbral: ", percent * 100.0, "%")

# Aplica la fuerza de empuje e inhabilita las entradas temporalmente
func apply_knockback(force: Vector2) -> void:
	velocity = force
	_knockback_timer = 0.25
