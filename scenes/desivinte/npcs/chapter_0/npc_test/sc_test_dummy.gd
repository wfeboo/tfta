# Entidad estática de prueba (Dummy) para pruebas de combate y daño.
#
# Recibe impactos de las hitboxes de ataque, descuenta puntos de vida
# e imprime el estado de su salud en la consola para depuración.
extends StaticBody2D

# Salud máxima / actual del muñeco de pruebas.
var health: float = 100.0


# Aplica daño a la salud del dummy y muestra los valores en la consola.
# Esta función es invocada dinámicamente por la Hitbox de ataque.
#
# Parámetros:
#   - amount: Cantidad de daño flotante a reducir.
func take_damage(amount: float) -> void:
	health -= amount

	print("DAMAGE:", amount)
	print("HP:", health)

	# Lógica básica para detectar si el dummy ha sido destruido
	if health <= 0.0:
		_on_death()


# Método privado ejecutado cuando la salud llega a cero o menos.
func _on_death() -> void:
	print("Dummy destruido.")
	# Puedes descomentar la siguiente línea si quieres que desaparezca de la escena al morir:
	# queue_free()
