extends Area2D
class_name ArmaLanzable

@export var velocidad: float = 400.0
@export var tiempo_espera: float = 0.5 # Segundos antes de regresar

var dueno: Node2D = null
var direccion: Vector2 = Vector2.ZERO
var esta_volviendo: bool = false
var esta_lanzada: bool = false

func _ready() -> void:
	# Conecta automáticamente el impacto con cuerpos
	body_entered.connect(_on_body_entered)

func lanzar(origen: Vector2, dir: Vector2, creador: Node2D) -> void:
	global_position = origen
	direccion = dir.normalized()
	dueno = creador
	esta_lanzada = true
	esta_volviendo = false
	visible = true
	monitoring = true
	
	# Temporizador para iniciar el retorno
	get_tree().create_timer(tiempo_espera).timeout.connect(iniciar_retorno)

func iniciar_retorno() -> void:
	esta_volviendo = true

func _process(delta: float) -> void:
	if not esta_lanzada:
		return
		
	# Rotación visual mientras vuela
	rotation += 12.0 * delta

	if not esta_volviendo:
		# Movimiento hacia adelante
		global_position += direccion * velocidad * delta
	else:
		# Movimiento de regreso hacia el dueño
		if is_instance_valid(dueno):
			var dir_al_dueno = (dueno.global_position - global_position).normalized()
			global_position += dir_al_dueno * (velocidad * 1.2) * delta
			
			# Si llega cerca del enemigo, se recupera
			if global_position.distance_to(dueno.global_position) < 20.0:
				recoger_arma()
		else:
			queue_free() # Si el enemigo murió, destruye el arma

func recoger_arma() -> void:
	esta_lanzada = false
	esta_volviendo = false
	visible = false
	monitoring = false
	
	if is_instance_valid(dueno) and dueno.has_method("al_recuperar_arma"):
		dueno.al_recuperar_arma()

func _on_body_entered(body: Node2D) -> void:
	# Hace daño al jugador y regresa
	if body.is_in_group("Jugador"):
		if body.has_method("recibir_dano"):
			body.recibir_dano(10)
		iniciar_retorno()
