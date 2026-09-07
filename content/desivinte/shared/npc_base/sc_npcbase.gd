# Clase base para todos los NPCs e interactuables simples del juego.
#
# Proporciona la interfaz esencial para iniciar diálogos mediante 'DialogueUI'
# y recibir eventos/desencadenantes ('triggers') durante la conversación.
extends Area2D
class_name NPCBase

# Identificador de la conversación que se solicitará a DialogueDatabase.
# Se puede configurar individualmente para cada NPC desde el Inspector de Godot.
@export var conversation_id: String = ""


# Inicia la conversación asociada enviando su ID y la referencia de este nodo a la UI.
# Debe ser invocada por el personaje jugador al presionar el botón de interacción.
func interact() -> void:
	if conversation_id.is_empty():
		push_warning("NPCBase: Se intentó interactuar con un NPC sin 'conversation_id' asignado en: " + name)
		return

	DialogueUI.show_dialogue(conversation_id, self)


# Callback ejecutado por 'DialogueUI' cuando una línea de diálogo activa un evento.
# Puede ser sobrescrito (override) por clases hijas para ejecutar lógica específica.
#
# Parámetros:
#   - trigger: Identificador String de la acción o evento a procesar.
func handle_trigger(trigger: String) -> void:
	pass
