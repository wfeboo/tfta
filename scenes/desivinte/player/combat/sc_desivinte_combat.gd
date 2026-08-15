extends Node2D
# Contenedor/manager de combate. Decide qué modo de Desivinte está
# activo (Melee o Airborne) y maneja el cambio entre ambos.

# Enumeración para definir los dos modos de combate posibles
enum CombatMode { MELEE, AIRBORNE }

# Precarga de las escenas para cada modo de combate
const MELEE_SCENE = preload("res://scenes/desivinte/player/combat/melee/scenes/scn_desivinte_melee.tscn")
const AIRBORNE_SCENE = preload("res://scenes/desivinte/player/combat/airborne/scenes/scn_desivinte_airborne.tscn")

# Estado actual del modo de combate (inicia en MELEE por defecto)
var current_mode: CombatMode = CombatMode.MELEE

# Referencia al nodo/personaje activo actualmente en pantalla
var current_instance: CharacterBody2D = null

func _ready() -> void:
	# Al iniciar el nodo, instancia el modo MELEE en la posición inicial (0,0)
	_spawn_mode(CombatMode.MELEE, Vector2.ZERO)

func _process(_delta: float) -> void:
	# Detecta si se presionó el botón asignado a "kit_4_action" para alternar el modo
	if Input.is_action_just_pressed("kit_4_action"):
		_switch_mode()

# Maneja la lógica para cambiar de un modo a otro manteniendo la posición actual
func _switch_mode() -> void:
	# Guarda la posición global del personaje actual antes de eliminarlo
	var last_position: Vector2 = current_instance.global_position
	
	# Determina el nuevo modo (si era MELEE pasa a AIRBORNE y viceversa)
	var new_mode = CombatMode.AIRBORNE if current_mode == CombatMode.MELEE else CombatMode.MELEE
	
	# Instancia el nuevo modo en la última posición guardada
	_spawn_mode(new_mode, last_position)

# Destruye la instancia actual e instancia la escena correspondiente al modo indicado
func _spawn_mode(mode: CombatMode, spawn_position: Vector2) -> void:
	# Si ya existe un personaje en escena, se marca para eliminación
	if current_instance != null:
		current_instance.queue_free()

	# Selecciona la escena a utilizar según el modo
	var scene_to_use = MELEE_SCENE if mode == CombatMode.MELEE else AIRBORNE_SCENE
	
	# Instancia y añade la nueva escena como hijo de este nodo
	current_instance = scene_to_use.instantiate()
	add_child(current_instance)
	
	# Asigna la posición guardada al nuevo personaje e actualiza el modo activo
	current_instance.global_position = spawn_position
	current_mode = mode
