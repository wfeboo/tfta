# Autoload: dialogue_database.gd
# Base de datos global de diálogos.
# Lee archivos CSV/TXT de texto plano con formato delimitado por comas, los
# procesa y los organiza en memoria dentro de un diccionario para permitir
# búsquedas rápidas por el identificador de conversación (conversation_id).
extends Node

# Rutas a los archivos de diálogos que se cargarán al iniciar el juego.
const DIALOGUE_PATHS: Array[String] = [
	"res://data/dialogue/intro/librarian_dialogue.txt",
	"res://data/dialogue/intro/destiny_dialogue.txt",
	"res://data/dialogue/desivinte/chapter_0/desivinte_interaction_ch0.txt"
]

# Estructura en memoria:
# {
#   "INTRO-00": [linea_data_1, linea_data_2, ...],
#   "CHATS-02": [...]
# }
var conversations: Dictionary = {}


func _ready() -> void:
	_load_all_dialogues()


# Devuelve el arreglo completo de líneas pertenecientes a una conversación.
#
# Parámetros:
#   - conversation_id: String con el ID de la conversación (ej: "INTRO-00").
#
# Retorna:
#   - Un Array de diccionarios con los datos de cada línea. Si la conversación
#     no existe, devuelve un arreglo vacío [].
func get_conversation(conversation_id: String) -> Array:
	return conversations.get(conversation_id, [])


# Carga todos los archivos definidos en DIALOGUE_PATHS al iniciar.
func _load_all_dialogues() -> void:
	for path: String in DIALOGUE_PATHS:
		load_dialogue_file(path)


# Parsea un archivo CSV individual y almacena sus filas en el diccionario 'conversations'.
#
# Parámetros:
#   - path: Ruta del archivo dentro del proyecto ("res://...").
func load_dialogue_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("DialogueDatabase: No se pudo abrir el archivo de diálogos en: " + path)
		return

	# Descartamos la primera fila por ser la cabecera del CSV (ID, Scene, etc.)
	var _header := file.get_csv_line()

	while not file.eof_reached():
		var row := file.get_csv_line()

		# Ignorar filas incompletas o saltos de línea al final del archivo
		if row.size() < 8:
			continue

		# Mapeo de columnas a claves descriptivas
		var line_data := {
			"id": row[0],
			"scene": row[1],
			"exact_scene": row[2],
			"character": row[3],
			"conversation_id": row[4],
			"text": row[5].strip_edges(),
			"emotion": row[6].strip_edges(),
			"trigger": row[7].strip_edges()
		}

		var conv_id: String = line_data["conversation_id"]

		# Inicializar la lista si es la primera vez que vemos este conversation_id
		if not conversations.has(conv_id):
			conversations[conv_id] = []

		conversations[conv_id].append(line_data)

	file.close()
