extends StaticBody2D

var health: float = 100.0


func take_damage(amount: float) -> void:
	health -= amount

	print("DAMAGE:", amount)
	print("HP:", health)
