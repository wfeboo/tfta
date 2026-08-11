extends Node
# Autoload: dialogue_database.gd
# Lee el CSV completo del bibliotecario y lo organiza en memoria para consultas rápidas

const DIALOGUE_PATHS: Array[String] = [
	"res://data/dialogue/intro/librarian_dialogue.txt",
	"res://data/dialogue/intro/destiny_dialogue.txt",
	"res://data/dialogue/desivinte/chapter_0/desivinte_interaction_ch0.txt"
]

# Agrupa líneas por su Conversation ID: {"INTRO-00": [linea1, linea2, ...], "CHATS-02": [...]}
var conversations: Dictionary = {}
func _ready() -> void:
	for path: String in DIALOGUE_PATHS:
		load_dialogue(path)

func load_dialogue(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir el archivo de diálogos: " + path)
		return

	# La primera fila es el encabezado (ID, Scene, Exact Scene, etc.) - la saltamos
	var header := file.get_csv_line()

	# Leemos línea por línea hasta que el archivo termine
	while not file.eof_reached():
		var row := file.get_csv_line()

		# Filas vacías al final del archivo (comunes en CSVs) - las ignoramos
		if row.size() < 8:
			continue

		# Armamos un diccionario legible por nombre, en vez de recordar índices como row[5]
		var line_data := {
			"id": row[0],
			"scene": row[1],
			"exact_scene": row[2],
			"character": row[3],
			"conversation_id": row[4],
			"text": row[5].strip_edges(),  # Acá limpiamos el \r sobrante
			"emotion": row[6].strip_edges(),
			"trigger": row[7].strip_edges()
		}

		var conv_id: String = line_data["conversation_id"]

		# Si es la primera línea de esta conversación, creamos su lista vacía primero
		if not conversations.has(conv_id):
			conversations[conv_id] = []

		conversations[conv_id].append(line_data)

	file.close()


func get_conversation(conversation_id: String) -> Array:
	# Función pública: el resto del juego pide una conversación por su ID,
	# sin necesidad de saber cómo está guardada por dentro
	return conversations.get(conversation_id, [])
