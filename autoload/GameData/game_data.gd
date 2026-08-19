# Autoload: game_data.gd
# Gestor de datos globales y persisencia de partida.
#
# Administra tanto las variables de sesión en memoria RAM como los datos
# de progreso guardados en disco duro utilizando el sistema ConfigFile de Godot.
extends Node

# Ruta estándar de usuario donde se almacena el archivo de guardado en el sistema.
const SAVE_PATH: String = "user://savegame.cfg"

# --- Datos de Progreso (Persistentes) ---
# Indica si el jugador ya ha visto la cinemática o secuencia de introducción.
var intro_seen: bool = false


func _ready() -> void:
	load_game()


# Guarda el estado actual de las variables de progreso en un archivo en disco.
func save_game() -> void:
	var config := ConfigFile.new()
	
	# Guardar valores dentro de la sección "progress"
	config.set_value("progress", "intro_seen", intro_seen)
	
	# Escribir los datos en la ruta asignada
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_error("GameData: No se pudo guardar el archivo en: " + SAVE_PATH)


# Carga los datos de progreso desde el disco duro si el archivo existe.
func load_game() -> void:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)
	
	# Si no existe el archivo de guardado o hay un error, se conservan los valores por defecto
	if error != OK:
		return

	# Obtener los valores (con un valor de respaldo por si la clave no existe)
	intro_seen = config.get_value("progress", "intro_seen", false)


# Marca la introducción como completada y guarda los cambios inmediatamente en disco.
func mark_intro_seen() -> void:
	intro_seen = true
	save_game()
