extends Node
# Autoload: attack_database.gd
# Carga todos los recursos AttackData (.tres) una sola vez al arrancar,
# y los organiza en un diccionario para consultarlos rápido por su attack_id

# Lista de rutas a los archivos .tres de cada ataque existente en el juego.
# Cada personaje/modo nuevo simplemente suma su ruta acá, sin tocar el resto.
const ATTACK_PATHS: Array[String] = [
	"res://resources/combat/attacks/jab.tres",
]

# Diccionario final: {"DESIV_ATK_MELEE_JAB": <AttackData>, ...}
var attacks: Dictionary = {}

func _ready() -> void:
	for path: String in ATTACK_PATHS:
		# Cargamos el .tres como un recurso real de tipo AttackData
		var attack_data: AttackData = load(path)
		# Lo guardamos usando su propio attack_id como clave
		attacks[attack_data.attack_id] = attack_data

func get_attack(attack_id: String) -> AttackData:
	# Función pública: el resto del juego pide un ataque por su ID,
	# sin necesidad de saber la ruta del archivo ni cómo se cargó
	return attacks.get(attack_id, null)
