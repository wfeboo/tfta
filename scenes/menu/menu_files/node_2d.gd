# Controlador del menú principal y submenús de la interfaz gráfica.
#
# Administra la interacción de los botones del menú (ajustes, volumen, libros/niveles,
# coleccionables), el despliegue de paneles flotantes y las animaciones suaves
# de escalado (hover) al pasar el puntero sobre los elementos interactivos.
extends Node2D

# Configuración de escala para el efecto de animación visual (hover) en botones.
var hover_scale: Vector2 = Vector2(1.1, 1.1)
var normal_scale: Vector2 = Vector2(1.0, 1.0)
var animation_duration: float = 0.35

# Registro de animaciones Tween activas asociadas a cada botón.
var tweens: Dictionary = {}

# --- REFERENCIAS A PANELES ---
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

# --- REFERENCIAS DENTRO DEL SUBMENÚ SETTINGS ---
@onready var btn_volume: BaseButton = $CanvasLayer/SettingsGroup/Volume
@onready var btn_controls: BaseButton = $CanvasLayer/SettingsGroup/Button

# --- REFERENCIAS A LIBROS / SELECCIÓN DE NIVEL ---
@onready var btn_book1: BaseButton = $CanvasLayer/Book1
@onready var btn_book2: BaseButton = $CanvasLayer/Book2
@onready var btn_book3: BaseButton = $CanvasLayer/Book3

# --- BOTONES DE CERRAR PANELES ---
@onready var btn_close_volume: BaseButton = $CanvasLayer/VolumeGroup/Button2
@onready var btn_close_warning: BaseButton = $CanvasLayer/WarningPanel/Button
@onready var btn_close_collect_warning: BaseButton = $"CanvasLayer/Collect-Warning/Button"
@onready var btn_close_controls: BaseButton = $"CanvasLayer/Controls-panel/Button"


func _ready() -> void:
	# Esperar un frame de procesamiento para asegurar la inicialización completa de la jerarquía UI
	await get_tree().process_frame

	# Evitar que los contenedores de los paneles bloqueen clics en botones de capas inferiores
	_set_mouse_ignore(settings_group)
	_set_mouse_ignore(volume_group)
	_set_mouse_ignore(warning_panel)
	_set_mouse_ignore(collect_warning)
	_set_mouse_ignore(controls_panel)

	# Asegurar que los botones de cierre puedan capturar clics a pesar de la restricción del panel padre
	if btn_close_controls:
		btn_close_controls.mouse_filter = Control.MOUSE_FILTER_STOP

	# Estado inicial: Ocultar todos los submenús y paneles flotantes
	if settings_group: settings_group.visible = false
	if volume_group: volume_group.visible = false
	if warning_panel: warning_panel.visible = false
	if collect_warning: collect_warning.visible = false
	if controls_panel: controls_panel.visible = false

	# 1. Configuración de botones del menú de ajustes y navegación principal
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

	if btn_settings: btn_settings.pressed.connect(_on_settings_pressed)
	if btn_volume: btn_volume.pressed.connect(_on_volume_pressed)
	if btn_controls: btn_controls.pressed.connect(_on_controls_pressed)
	if btn_close_volume: btn_close_volume.pressed.connect(_on_close_volume_pressed)
	if btn_quit: btn_quit.pressed.connect(_on_quit_pressed)
	if btn_collectionables: btn_collectionables.pressed.connect(_on_collect_warning_toggle)
	if btn_arcade: btn_arcade.pressed.connect(_on_collect_warning_toggle)

	# 2. Configuración de botones de libros (selección de nivel)
	var book_buttons: Array[BaseButton] = [btn_book1, btn_book2, btn_book3]
	for book in book_buttons:
		if book != null:
			_setup_button_hover(book)
			book.pressed.connect(_on_book_pressed.bind(book))

	# 3. Configuración de botones para cerrar paneles
	if btn_close_warning != null:
		_setup_button_hover(btn_close_warning)
		btn_close_warning.pressed.connect(_on_close_warning_pressed)

	if btn_close_collect_warning != null:
		_setup_button_hover(btn_close_collect_warning)
		btn_close_collect_warning.pressed.connect(_on_close_collect_warning_pressed)

	if btn_close_controls != null:
		_setup_button_hover(btn_close_controls)
		btn_close_controls.pressed.connect(_on_close_controls_pressed)


# --- FUNCIONES AUXILIARES DE CONFIGURACIÓN ---

# Establece el filtro de ratón del nodo a MOUSE_FILTER_IGNORE si es un Control.
func _set_mouse_ignore(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE


# Configura el pivote central de un botón y conecta sus señales de hover.
func _setup_button_hover(btn: BaseButton) -> void:
	if "size" in btn and btn.size != Vector2.ZERO:
		btn.pivot_offset = btn.size / 2.0
	btn.mouse_entered.connect(_on_button_hover_enter.bind(btn))
	btn.mouse_exited.connect(_on_button_hover_exit.bind(btn))


# --- GESTIÓN DE SUBMENÚS Y BOTONES DE NAVEGACIÓN ---

# Alterna la visibilidad del menú de ajustes principales.
func _on_settings_pressed() -> void:
	if settings_group:
		settings_group.visible = !settings_group.visible
		# Ocultar subpaneles si se cierra el panel principal de ajustes
		if not settings_group.visible:
			if volume_group: volume_group.visible = false
			if controls_panel: controls_panel.visible = false


# Alterna la visibilidad del panel de control de volumen.
func _on_volume_pressed() -> void:
	if volume_group:
		volume_group.visible = !volume_group.visible
	if controls_panel:
		controls_panel.visible = false


# Oculta el panel de volumen.
func _on_close_volume_pressed() -> void:
	if volume_group:
		volume_group.visible = false


# Alterna la visibilidad del panel de controles.
func _on_controls_pressed() -> void:
	if controls_panel:
		controls_panel.visible = !controls_panel.visible
	if volume_group:
		volume_group.visible = false


# Oculta el panel de controles.
func _on_close_controls_pressed() -> void:
	if controls_panel:
		controls_panel.visible = false


# Cierra la aplicación de forma segura.
func _on_quit_pressed() -> void:
	get_tree().quit()


# --- GESTIÓN DE ADVERTENCIAS Y NIVELES ---

# Alterna el panel de aviso para el modo coleccionables / arcade.
func _on_collect_warning_toggle() -> void:
	if collect_warning:
		collect_warning.visible = !collect_warning.visible


# Oculta el panel de aviso de coleccionables.
func _on_close_collect_warning_pressed() -> void:
	if collect_warning:
		collect_warning.visible = false


# Gestiona la selección de libros (niveles del juego).
func _on_book_pressed(book: BaseButton) -> void:
	if book == btn_book1:
		print("Iniciando Nivel 1 desde Book1...")
		# get_tree().change_scene_to_file("res://escenas/nivel1.tscn")
		
	elif book == btn_book2 or book == btn_book3:
		if warning_panel:
			warning_panel.visible = true


# Oculta el panel de advertencia de libro/nivel bloqueado.
func _on_close_warning_pressed() -> void:
	if warning_panel:
		warning_panel.visible = false


# --- SISTEMA DE ANIMACIONES HOVER (TWEENS) ---

# Evento ejecutado al entrar el cursor sobre un botón.
func _on_button_hover_enter(btn: BaseButton) -> void:
	if "size" in btn and btn.size != Vector2.ZERO:
		btn.pivot_offset = btn.size / 2.0
	_animate_scale(btn, hover_scale)


# Evento ejecutado al salir el cursor de un botón.
func _on_button_hover_exit(btn: BaseButton) -> void:
	_animate_scale(btn, normal_scale)


# Anima suavemente la propiedad 'scale' del botón objetivo usando una curva elástica (TRANS_BACK).
func _animate_scale(btn: BaseButton, target_scale: Vector2) -> void:
	if tweens.has(btn) and tweens[btn] != null and tweens[btn].is_running():
		tweens[btn].kill()
		
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tweens[btn] = tween
	tween.tween_property(btn, "scale", target_scale, animation_duration)
