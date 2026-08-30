# Lin — oponente de las peleas de la introducción (Capítulo 0).
# Versión mínima para probar Health/umbrales: sin movimiento ni ataque propio aún.
extends CharacterBody2D

@onready var health: Health = $Health

func _ready() -> void:
	add_to_group("damageables")
	health.threshold_crossed.connect(_on_threshold_crossed)

func _on_threshold_crossed(percent: float) -> void:
	print("Lin cruzó el umbral: ", percent * 100, "%")
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func take_damage(amount: float) -> void:
	health.take_damage(amount)
	print("OW")
