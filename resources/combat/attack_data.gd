extends Resource
class_name AttackData

enum Mode {MELEE, AIRBORNE}

@export var attack_id: String = ""
@export var mode: Mode = Mode.MELEE
@export var damage: float = 10.0
@export var hitbox_size: Vector2 = Vector2(50,50)
@export var active_duration: float = 0.15
@export var cooldown: float = 0.3
@export var chargeable: bool = false
