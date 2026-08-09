extends Node
# Autoload: game_data.gd
# Maneja tanto datos de sesión (para RAM) como datos de progreso persistente (disco)

# --- Datos de Progreso (EN DISCO) ---
var intro_seen: bool = false
# Ruta especial de Godot para guardados del usuario (no es parte del proyecto,
# es una carpeta del sistema operativo pensada para esto)

const SAVE_PATH: String = "user://savegame.cfg"

func _ready() -> void:
	# Apenas arranca el autoload
	# Intentamos buscar el progreso guardado
	load_game()
	
func save_game() -> void:
	# ConfigFile es como una libreta organizada en secciones y claves
	var config := ConfigFile.new()
	# Sección "progress", clave "intro_seen", con el valor actual de dicha variable
	config.set_value("progress","intro_seen",intro_seen)
	# Escribimos la libreta al archivo real en disco
	config.save(SAVE_PATH)
	
func load_game() -> void:
	var config := ConfigFile.new()
	# Se intenta abrir el archivo. Si este no existe (porque es la primera vez que se abre)
	# load dará error y nos dejaremos los valores por defecto
	var error := config.load(SAVE_PATH)
	if error != OK:
		# No hay archivo de guardado así que no hay nada que cargar
		return
		# get_value(seccion, clave, valor_por_defecto)
		# El valor por defecto se usa si esa clave no existe aún
	intro_seen = config.get_value("progress","intro_seen",false)

func mark_intro_seen() -> void:
	# Función para cuando termine la cinemática
	intro_seen = true
	save_game()
