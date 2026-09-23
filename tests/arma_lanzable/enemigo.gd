extends CharacterBody2D

@export var escena_arma: PackedScene
@export var objetivo: Node2D

var tiene_arma: bool = true
var arma_instancia: ArmaLanzable = null

func _ready() -> void:
	if escena_arma:
		arma_instancia = escena_arma.instantiate() as ArmaLanzable
		get_parent().call_deferred("add_child", arma_instancia)
		arma_instancia.visible = false

func atacar_lanzando_arma() -> void:
	if not tiene_arma or not is_instance_valid(objetivo) or not arma_instancia:
		return
		
	tiene_arma = false
	var direccion_ataque = objetivo.global_position - global_position
	arma_instancia.lanzar(global_position, direccion_ataque, self)

func al_recuperar_arma() -> void:
	tiene_arma = true
	print("¡El enemigo recuperó su arma!")

func _input(event: InputEvent) -> void:
	# Al presionar Espacio, el enemigo lanzará el arma
	if event.is_action_pressed("ui_accept"):
		atacar_lanzando_arma()
