# Hitbox de ataque genérica y reutilizable (Area2D).
#
# Se instancia como nodo hijo en cualquier personaje o entidad en combate.
# Ajusta dinámicamente sus dimensiones, daño y tiempo de activación
# a partir de un recurso 'AttackData' recibido.
extends Area2D

# Daño que infligirá la hitbox durante su ventana de activación actual.
var current_damage: float = 0.0


# Configura y activa la hitbox según las propiedades descritas en el objeto AttackData.
# Desactiva la monitorización automáticamente al finalizar el tiempo de ataque.
#
# Parámetros:
#   - attack_data: Recurso AttackData con el daño, dimensiones y duración del ataque.
func activate(attack_data: AttackData) -> void:
	if attack_data == null:
		push_error("Hitbox: Se intentó activar la hitbox con un AttackData nulo.")
		return

	current_damage = attack_data.damage

	# Obtener y redimensionar la colisión de la hitbox
	var collision_shape: CollisionShape2D = $CollisionShape2D
	if collision_shape and collision_shape.shape is CapsuleShape2D:
		var hitbox_shape: CapsuleShape2D = collision_shape.shape
		hitbox_shape.radius = attack_data.hitbox_size.x
		hitbox_shape.height = attack_data.hitbox_size.y

	# Habilitar la detección de colisiones
	monitoring = true

	# Esperar el tiempo de duración activa del ataque
	await get_tree().create_timer(attack_data.active_duration).timeout

	# Deshabilitar la detección al terminar el ataque
	monitoring = false


# Callback ejecutado cuando un cuerpo físico entra en el área de la hitbox.
#
# Parámetros:
#   - body: Nodo2D que colisionó con la hitbox.
func _on_body_entered(body: Node2D) -> void:
	# Verificación de seguridad para aplicar daño solo a objetivos válidos
	if body.is_in_group("damageables"):
		if body.has_method("take_damage"):
			body.take_damage(current_damage)
		else:
			push_warning("Hitbox: El nodo '" + body.name + "' está en el grupo 'damageables' pero no implementa 'take_damage()'.")
