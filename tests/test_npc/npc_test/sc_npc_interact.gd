# Nodo de interacción para NPCs o entidades pasivas (dummies).
#
# Utiliza un Area2D para detectar la cercanía del jugador, mostrar una pista visual
# (PromptLabel) e iniciar secuencias de diálogo a través de 'DialogueUI'.
extends Area2D
class_name NPCDUMMY

# Identificador único de la conversación que se reproducirá al interactuar.
# Se puede ajustar directamente desde el Inspector de Godot.
@export var conversation_id: String = "INTRO-DSTNY-0007"

# Referencia a la etiqueta visual que indica al jugador que puede interactuar (ej: "Presiona E").
@onready var prompt_label: Label = $PromptLabel


func _ready() -> void:
	# Ocultar la pista visual al instanciar el nodo
	prompt_label.visible = false
	
	# Conectar señales nativas de Area2D para detectar cuándo el jugador entra o sale de rango
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# Inicia la secuencia de diálogo enviando la ID de conversación a la interfaz global.
# Debe ser llamada por el jugador cuando presione el botón de interacción estando dentro del área.
func interact() -> void:
	prompt_label.visible = false
	DialogueUI.show_dialogue(conversation_id, self)


# Callback invocado por 'DialogueUI' cuando una línea de diálogo contiene una etiqueta 'trigger'.
#
# Parámetros:
#   - trigger: String con la instrucción o evento a ejecutar (ej: "give_item", "start_fight").
func handle_trigger(trigger: String) -> void:
	pass


# Evento ejecutado automáticamente cuando un cuerpo físico entra en el área de colisión.
func _on_body_entered(body: Node2D) -> void:
	prompt_label.visible = true


# Evento ejecutado automáticamente cuando el cuerpo físico sale del área de colisión.
func _on_body_exited(body: Node2D) -> void:
	prompt_label.visible = false
