extends Area2D
class_name NPCBase

@export var conversation_id: String = ""

func interact() -> void:
	DialogueUI.show_dialogue(conversation_id, self)
	
func handle_trigger(trigger: String):
	pass
