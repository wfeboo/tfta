# Hitbox de ataque genérica y reutilizable (Area2D).
extends Area2D

var current_damage: float = 0.0
var current_knockback_force: float = 0.0

var _hit_bodies: Array[Node2D] = []
var _owner_body: Node2D = null

var _default_radius: float = 10.0
var _default_height: float = 20.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	monitoring = false
	if collision_shape:
		collision_shape.disabled = true
		if collision_shape.shape is CapsuleShape2D:
			if not collision_shape.shape.is_local_to_scene():
				collision_shape.shape = collision_shape.shape.duplicate()
			
			var hitbox_shape: CapsuleShape2D = collision_shape.shape
			_default_radius = hitbox_shape.radius
			_default_height = hitbox_shape.height

func activate(attack_data: AttackData, owner_body: Node2D = null) -> void:
	if attack_data == null:
		push_error("Hitbox: Se intentó activar la hitbox con un AttackData nulo.")
		return

	_owner_body = owner_body
	current_damage = attack_data.damage
	
	# Verificar si el AttackData tiene definida la fuerza de empuje
	if "knockback_force" in attack_data:
		current_knockback_force = attack_data.knockback_force
	else:
		current_knockback_force = 150.0 # Fuerza por defecto si no está en el recurso

	_hit_bodies.clear()

	if collision_shape and collision_shape.shape is CapsuleShape2D:
		var hitbox_shape: CapsuleShape2D = collision_shape.shape
		hitbox_shape.radius = attack_data.hitbox_size.x
		hitbox_shape.height = attack_data.hitbox_size.y

	collision_shape.set_deferred("disabled", false)
	monitoring = true

	await get_tree().create_timer(attack_data.active_duration).timeout

	monitoring = false
	collision_shape.set_deferred("disabled", true)
	
	if collision_shape and collision_shape.shape is CapsuleShape2D:
		var hitbox_shape: CapsuleShape2D = collision_shape.shape
		hitbox_shape.radius = _default_radius
		hitbox_shape.height = _default_height

func _on_body_entered(body: Node2D) -> void:
	if body == _owner_body or body in _hit_bodies:
		return

	if body.is_in_group("damageables"):
		if body.has_method("take_damage"):
			_hit_bodies.append(body)
			
			# Calcular la dirección del impacto (en X)
			var knockback_direction: float = 1.0
			if _owner_body:
				var diff_x: float = body.global_position.x - _owner_body.global_position.x
				knockback_direction = signf(diff_x)
				if knockback_direction == 0.0:
					knockback_direction = 1.0
			
			# Aplicar el knockback si la víctima implementa el método
			if body.has_method("apply_knockback"):
				var knockback_vector: Vector2 = Vector2(knockback_direction * current_knockback_force, -80.0)
				body.apply_knockback(knockback_vector)

			body.take_damage(current_damage)
			print("¡Hitbox golpeó a ", body.name, " con knockback!")
		else:
			push_warning("Hitbox: El nodo '" + body.name + "' no implementa 'take_damage()'.")
