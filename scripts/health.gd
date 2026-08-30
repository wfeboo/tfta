class_name Health
extends Node

# Emitida cada vez que la vida cambia (para UI de barra de vida, etc.)
signal hp_changed(current: float, max: float)
# Emitida cuando la vida cruza hacia abajo uno de los umbrales configurados.
signal threshold_crossed(percent: float)

@export var max_hp: float = 100.0
# Si es >= 0, este Health persiste su vida en GameData para ese protagonista.
# Dejar en -1 para enemigos/NPCs sin persistencia (ej. Lin).
@export var persistent_protagonist: GameData.Protagonist = -1
# Umbrales de porcentaje de vida (0.0 a 1.0) ordenados de mayor a menor.
@export var damage_thresholds: Array[float] = []
# Multiplicador de daño recibido — bajarlo simula que el objetivo "se vuelve más resistente".
var damage_taken_multiplier: float = 1.0

var current_hp: float
var _next_threshold_index: int = 0

func _ready() -> void:
	if persistent_protagonist >= 0:
		current_hp = GameData.get_current_hp(persistent_protagonist)
		max_hp = GameData.get_max_hp(persistent_protagonist)
	else:
		current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)

func take_damage(amount: float) -> void:
	var actual_damage: float = amount * damage_taken_multiplier
	current_hp = max(current_hp - actual_damage, 0.0)

	if persistent_protagonist >= 0:
		GameData.set_current_hp(persistent_protagonist, current_hp)

	hp_changed.emit(current_hp, max_hp)
	_check_thresholds()

func _check_thresholds() -> void:
	var percent: float = current_hp / max_hp
	while _next_threshold_index < damage_thresholds.size() \
			and percent <= damage_thresholds[_next_threshold_index]:
		threshold_crossed.emit(damage_thresholds[_next_threshold_index])
		_next_threshold_index += 1
