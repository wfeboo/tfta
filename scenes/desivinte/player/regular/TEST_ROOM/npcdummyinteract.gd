extends Area2D
class_name NPCDUMMY # Define la clase global NPCDUMMY para poder referenciarla en otros scripts

# Identificador de la conversación (editable desde el Inspector de Godot)
@export var conversation_id: String = "INTRO-DSTNY-0007"

# Referencia al nodo hijo Label que muestra el mensaje de interacción (ej. "Presiona E")
@onready var prompt_label: Label = $PromptLabel

func _ready() -> void:
	# Oculta el mensaje flotante al iniciar el juego
	prompt_label.visible = false
	
	# Conecta las señales de detección de colisión física a sus respectivas funciones
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# Función principal para interactuar con el NPC (llamada desde el jugador)
func interact() -> void:
	# Oculta el mensaje visual durante el diálogo
	prompt_label.visible = false
	# Inicia el diálogo llamando al Singleton/Autoload DialogueUI
	DialogueUI.show_dialogue(conversation_id, self)

# Callback para procesar eventos específicos activados por el sistema de diálogos
func handle_trigger(trigger: String):
	pass

# Se ejecuta cuando un cuerpo (ej. el personaje) entra en la zona del Area2D
func _on_body_entered(body: Node2D) -> void:
	prompt_label.visible = true

# Se ejecuta cuando el cuerpo sale de la zona del Area2D
func _on_body_exited(body: Node2D) -> void:
	prompt_label.visible = false
