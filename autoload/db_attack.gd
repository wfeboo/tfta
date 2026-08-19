# Autoload: attack_database.gd
# Base de datos global que carga todos los recursos AttackData (.tres) 
# una sola vez al arrancar el juego y los organiza en un diccionario 
# para consultarlos rápidamente por su attack_id.
extends Node

# Lista de rutas a los archivos .tres de cada ataque registrado en el juego.
# Para añadir un nuevo ataque, basta con incluir su ruta en este arreglo.
const ATTACK_PATHS: Array[String] = [
	"res://resources/combat/attacks/jab.tres",
]

# Diccionario de almacenamiento: {"DESIV_ATK_MELEE_JAB": AttackData, ...}
var attacks: Dictionary = {}


func _ready() -> void:
	_load_attack_database()


# Devuelve el recurso AttackData correspondiente al attack_id solicitado.
#
# Parámetros:
#   - attack_id: String con el identificador único del ataque.
#
# Retorna:
#   - El recurso AttackData si se encuentra, o null si no existe.
func get_attack(attack_id: String) -> AttackData:
	return attacks.get(attack_id, null)


# Carga e indexa internamente los recursos definidos en ATTACK_PATHS.
func _load_attack_database() -> void:
	for path: String in ATTACK_PATHS:
		var attack_data: AttackData = load(path)
		
		if attack_data:
			attacks[attack_data.attack_id] = attack_data
		else:
			push_error("AttackDatabase: No se pudo cargar el recurso en la ruta: " + path)
