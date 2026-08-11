extends Area2D

# Hitbox de ataque genérica y reusable.
# Se instancia como hijo de cualquier personaje en combate
# y se configura mediante AttackData.

var current_damage: float = 0.0


func activate(attack_data: AttackData) -> void:
	current_damage = attack_data.damage

	var hitbox_shape: CapsuleShape2D = $CollisionShape2D.shape

	hitbox_shape.radius = attack_data.hitbox_size.x
	hitbox_shape.height = attack_data.hitbox_size.y

	monitoring = true

	await get_tree().create_timer(
		attack_data.active_duration
	).timeout

	monitoring = false


func _on_body_entered(body: Node2D) -> void:
	print("DETECTADO:", body.name)
	print("¿Es damageable?:", body.is_in_group("damageables"))
	print("Grupos:", body.get_groups())

	if body.is_in_group("damageables"):
		print("DAMAGEABLE:", body.name)
		body.take_damage(current_damage)
