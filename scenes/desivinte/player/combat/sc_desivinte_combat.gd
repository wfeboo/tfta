# Administrador de estados y modos de combate del personaje (Combat Manager).
#
# Alterna dinámicamente entre las jugabilidades Melee (cuerpo a cuerpo) y 
# Airborne (aéreo), destruyendo e instanciando la escena correspondiente 
# mientras preserva la posición global exacta en el escenario.
extends Node2D

# Modos de combate disponibles en el sistema.
enum CombatMode {
	MELEE,
	AIRBORNE
}

# Precarga de recursos de escena para evitar tirones de rendimiento (stuttering) al instanciar.
const MELEE_SCENE: PackedScene = preload("res://scenes/desivinte/player/combat/melee/scenes/scn_desivinte_melee.tscn")
const AIRBORNE_SCENE: PackedScene = preload("res://scenes/desivinte/player/combat/airborne/scenes/scn_desivinte_airborne.tscn")

# Modo de combate activo actualmente (por defecto inicia en Melee).
var current_mode: CombatMode = CombatMode.MELEE

# Referencia a la instancia activa del personaje en la escena.
var current_instance: CharacterBody2D = null


func _ready() -> void:
	# Inicializar la entidad en el modo por defecto en el origen
	_spawn_mode(CombatMode.MELEE, Vector2.ZERO)


func _process(_delta: float) -> void:
	# Escuchar la entrada del jugador para alternar el kit/modo de combate
	if Input.is_action_just_pressed("kit_4_action"):
		_switch_mode()


# Cambia el modo de combate activo conservando la posición global del personaje.
func _switch_mode() -> void:
	if current_instance == null:
		return

	# Registrar la posición global antes de reemplazar el nodo
	var last_position: Vector2 = current_instance.global_position
	
	# Determinar el modo opuesto al actual
	var new_mode: CombatMode = CombatMode.AIRBORNE if current_mode == CombatMode.MELEE else CombatMode.MELEE
	
	# Instanciar el nuevo modo en la posición registrada
	_spawn_mode(new_mode, last_position)


# Reemplaza la instancia actual por la escena correspondiente al nuevo modo.
#
# Parámetros:
#   - mode: Enumeración CombatMode indicando la escena a instanciar.
#   - spawn_position: Posición Vector2 donde se ubicará el nuevo personaje.
func _spawn_mode(mode: CombatMode, spawn_position: Vector2) -> void:
	# Liberar de la memoria el nodo anterior si existe
	if current_instance != null:
		current_instance.queue_free()

	# Seleccionar y crear la instancia correspondiente
	var scene_to_use: PackedScene = MELEE_SCENE if mode == CombatMode.MELEE else AIRBORNE_SCENE
	current_instance = scene_to_use.instantiate() as CharacterBody2D
	
	# Agregar al árbol de nodos y posicionar
	add_child(current_instance)
	current_instance.global_position = spawn_position
	current_mode = mode
