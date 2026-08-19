# Controlador principal de la interfaz del menú de inicio (Main Menu).
#
# Coordina la navegación de submenús (ajustes, controles, volumen), la apertura 
# de paneles de advertencia/coleccionables, la selección de niveles ("libros") 
# y la gestión de animaciones dinámicas con escala (Tween/Hover) en todos los botones.
extends Node2D

# Configuración de escalas para el efecto de animación 'hover' al pasar el cursor
var hover_scale: Vector2 = Vector2(1.1, 1.1)
var normal_scale: Vector2 = Vector2(1.0, 1.0)
var animation_duration: float = 0.35

# Registro interno para almacenar y gestionar los Tweens activos de cada botón
var tweens: Dictionary = {}

# --- REFERENCIAS A PANELES DE LA UI ---
@onready var settings_group: Node = $CanvasLayer/SettingsGroup
@onready var volume_group: Node = $CanvasLayer/VolumeGroup
@onready var warning_panel: Node = $CanvasLayer/WarningPanel
@onready var collect_warning: Node = $"CanvasLayer/Collect-Warning"
@onready var controls_panel: Node = $"CanvasLayer/Controls-panel"

# --- REFERENCIAS A BOTONES PRINCIPALES ---
@onready var btn_settings: BaseButton = $CanvasLayer/Settings
@onready var btn_quit: BaseButton = $CanvasLayer/QuitGame
@onready var btn_collectionables: BaseButton = $CanvasLayer/Collectionables
@onready var btn_arcade: BaseButton = $CanvasLayer/Arcade

# --- REFERENCIAS DEL SUBMENÚ DE AJUSTES ---
@onready var btn_volume: BaseButton = $CanvasLayer/SettingsGroup/Volume
@onready var btn_controls: BaseButton = $CanvasLayer/SettingsGroup/Button

# --- REFERENCIAS A BOTONES DE SELECCIÓN DE NIVEL (LIBROS) ---
@onready var btn_book1: BaseButton = $CanvasLayer/Book1
@onready var btn_book2: BaseButton = $CanvasLayer/Book2
@onready var btn_book3: BaseButton = $CanvasLayer/Book3

# --- BOTONES DE CIERRE DE PANELES ---
@onready var btn_close_volume: BaseButton = $CanvasLayer/VolumeGroup/Button2
@onready var btn_close_warning: BaseButton = $CanvasLayer/WarningPanel/Button
@onready var btn_close_collect_warning: BaseButton = $"CanvasLayer/Collect-Warning/Button"
@onready var btn_close_controls: BaseButton = $"CanvasLayer/Controls-panel/Button"


func _ready() -> void:
	# Esperar un frame para asegurar la inicialización completa de la jerarquía de UI
	await get_tree().process_frame

	# Evitar que contenedores invisibles o transparentes bloqueen clics en botones inferiores
	_set_mouse_ignore(settings_group)
	_set_mouse_ignore(volume_group)
	_set_mouse_ignore(warning_panel)
	_set_mouse_ignore(collect_warning)
	_set_mouse_ignore(controls_panel)

	# Asegurar que el botón de cerrar controles reciba eventos de ratón explícitamente
	if btn_close_controls:
		btn_close_controls.mouse_filter = Control.MOUSE_FILTER_STOP

	# Estado inicial: Ocultar todos los submenús y ventanas emergentes
	if settings_group: settings_group.visible = false
	if volume_group: volume_group.visible = false
	if warning_panel: warning_panel.visible = false
	if collect_warning: collect_warning.visible = false
	if controls_panel: controls_panel.visible = false

	# 1. Configuración de botones del menú principal y submenús
	var menu_buttons: Array[BaseButton] = [
		btn_settings,
		btn_volume,
		btn_controls,
		btn_close_volume,
		btn_quit,
		btn_collectionables,
		btn_arcade
	]
	
	for btn in menu_buttons:
		if btn != null:
			_setup_button_hover(btn)

	# Conexión de señales de pulsación (pressed)
	if btn_settings: btn_settings.pressed.connect(_on_settings_pressed)
	if btn_volume: btn_volume.pressed.connect(_on_volume_pressed)
	if btn_controls: btn_controls.pressed.connect(_on_controls_pressed)
	if btn_close_volume: btn_close_volume.pressed.connect(_on_close_volume_pressed)
	if btn_quit: btn_quit.pressed.connect(_on_quit_pressed)
	if btn_collectionables: btn_collectionables.pressed.connect(_on_collect_warning_toggle)
	if btn_arcade: btn_arcade.pressed.connect(_on_collect_warning_toggle)

	# 2. Configuración de botones de libros (niveles)
	var book_buttons: Array[BaseButton] = [btn_book1, btn_book2, btn_book3]
	for book in book_buttons:
		if book != null:
			_setup_button_hover(book)
			book.pressed.connect(_on_book_pressed.bind(book))

	# 3. Configuración de botones de cierre de ventanas
	if btn_close_warning != null:
		_setup_button_hover(btn_close_warning)
		btn_close_warning.pressed.connect(_on_close_warning_pressed)

	if btn_close_collect_warning != null:
		_setup_button_hover(btn_close_collect_warning)
		btn_close_collect_warning.pressed.connect(_on_close_collect_warning_pressed)

	if btn_close_controls != null:
		_setup_button_hover(btn_close_controls)
		btn_close_controls.pressed.connect(_on_close_controls_pressed)


# --- FUNCIONES AUXILIARES ---

# Configura un nodo Control para ignorar los eventos de ratón y no bloquear capas inferiores.
func _set_mouse_ignore(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE


# Ajusta el pivote al centro del botón y conecta las señales mouse_entered y mouse_exited.
func _setup_button_hover(btn: BaseButton) -> void:
	if "size" in btn and btn.size != Vector2.ZERO:
		btn.pivot_offset = btn.size / 2.0
	btn.mouse_entered.connect(_on_button_hover_enter.bind(btn))
	btn.mouse_exited.connect(_on_button_hover_exit.bind(btn))


# --- GESTIÓN DE SUBMENÚS Y NAVEGACIÓN ---

# Alterna la visibilidad del menú de ajustes. Si se oculta, cierra también sus subpaneles.
func _on_settings_pressed() -> void:
	if settings_group:
		settings_group.visible = !settings_group.visible
		if not settings_group.visible:
			if volume_group: volume_group.visible = false
			if controls_panel: controls_panel.visible = false


# Alterna el panel de volumen y oculta el panel de controles.
func _on_volume_pressed() -> void:
	if volume_group:
		volume_group.visible = !volume_group.visible
	if controls_panel:
		controls_panel.visible = false


# Oculta el panel de volumen.
func _on_close_volume_pressed() -> void:
	if volume_group:
		volume_group.visible = false


# Alterna el panel de controles y oculta el panel de volumen.
func _on_controls_pressed() -> void:
	if controls_panel:
		controls_panel.visible = !controls_panel.visible
	if volume_group:
		volume_group.visible = false


# Oculta el panel de controles.
func _on_close_controls_pressed() -> void:
	if controls_panel:
		controls_panel.visible = false


# Cierra la aplicación/juego.
func _on_quit_pressed() -> void:
	get_tree().quit()


# --- GESTIÓN DE ADVERTENCIAS Y NIVELES ---

# Alterna la visibilidad de la advertencia para el modo coleccionables / arcade.
func _on_collect_warning_toggle() -> void:
	if collect_warning:
		collect_warning.visible = !collect_warning.visible


# Oculta la advertencia de coleccionables.
func _on_close_collect_warning_pressed() -> void:
	if collect_warning:
		collect_warning.visible = false


# Procesa la pulsación de un libro para iniciar nivel o desplegar advertencia de bloqueo.
func _on_book_pressed(book: BaseButton) -> void:
	if book == btn_book1:
		print("Iniciando Nivel 1 desde Book1...")
		# get_tree().change_scene_to_file("res://escenas/nivel1.tscn")
		
	elif book == btn_book2 or book == btn_book3:
		if warning_panel:
			warning_panel.visible = true


# Oculta la advertencia de nivel bloqueado.
func _on_close_warning_pressed() -> void:
	if warning_panel:
		warning_panel.visible = false


# --- ANIMACIONES HOVER DE BOTONES ---

# Evento al entrar el cursor: centra el pivote y escala el botón hacia arriba.
func _on_button_hover_enter(btn: BaseButton) -> void:
	if "size" in btn and btn.size != Vector2.ZERO:
		btn.pivot_offset = btn.size / 2.0
	_animate_scale(btn, hover_scale)


# Evento al salir el cursor: restablece el botón a su escala original.
func _on_button_hover_exit(btn: BaseButton) -> void:
	_animate_scale(btn, normal_scale)


# Interpola la propiedad 'scale' del botón objetivo mediante un Tween elástico (TRANS_BACK).
func _animate_scale(btn: BaseButton, target_scale: Vector2) -> void:
	if tweens.has(btn) and tweens[btn] != null and tweens[btn].is_running():
		tweens[btn].kill()
		
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tweens[btn] = tween
	tween.tween_property(btn, "scale", target_scale, animation_duration)
