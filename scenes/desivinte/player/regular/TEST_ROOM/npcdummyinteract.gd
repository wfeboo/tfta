extends Area2D
class_name NPCBase

@export var conversation_id: String = "DESI_INT_CH0_0030"

@onready var prompt_label: Label = $PromptLabel

func _ready() -> void:
	prompt_label.visible = false
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	prompt_label.visible = true

func _on_area_exited(area: Area2D) -> void:
	prompt_label.visible = false

func interact() -> void:
	prompt_label.visible = false
	DialogueUI.show_dialogue(conversation_id, self)

func handle_trigger(trigger: String):
	pass
