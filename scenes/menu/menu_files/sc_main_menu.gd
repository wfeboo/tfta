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

# Arreglo para iterar y gestionar paneles fácilmente
@onready var all_panels: Array[Node] = [
	settings_group, 
	volume_group, 
	warning_panel, 
	collect_warning, 
	controls_panel
]

func _ready() -> void:
	# Esperar un frame para asegurar la inicialización completa de la jerarquía de UI
	await get_tree().process_frame

	# 1. Ocultar paneles e ignorar eventos de ratón en sus contenedores transparentes
	for panel in all_panels:
		if panel:
			if panel is Control:
				panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			panel.visible = false

	# 2. Configurar sliders de volumen al 70% por defecto
	_setup_volume_sliders()

	# 3. Mapear botones con sus acciones mediante un Diccionario
	var button_actions: Dictionary = {
		btn_settings: _on_settings_pressed,
		btn_volume: _on_volume_pressed,
		btn_controls: _on_controls_pressed,
		btn_close_volume: _on_close_volume_pressed,
		btn_quit: _on_quit_pressed,
		btn_collectionables: _on_collect_warning_toggle,
		btn_arcade: _on_collect_warning_toggle,
		btn_close_warning: func(): _set_panel_visible(warning_panel, false),
		btn_close_collect_warning: func(): _set_panel_visible(collect_warning, false),
		btn_close_controls: _on_close_controls_pressed
	}

	# Conectar botones del menú principal y de cierre
	for btn in button_actions:
		if btn != null:
			_setup_button(btn)
			btn.pressed.connect(button_actions[btn])

	# Conectar botones de selección de libros (niveles)
	var book_buttons: Array[BaseButton] = [btn_book1, btn_book2, btn_book3]
	for book in book_buttons:
		if book != null:
			_setup_button(book)
			book.pressed.connect(_on_book_pressed.bind(book))


# --- CONFIGURACIÓN E ITERACIÓN AUXILIAR ---

# Configura eventos hover y asegura la captura de eventos de clic en el botón.
func _setup_button(btn: BaseButton) -> void:
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	if "size" in btn and btn.size != Vector2.ZERO:
		btn.pivot_offset = btn.size / 2.0
	btn.mouse_entered.connect(_on_button_hover_enter.bind(btn))
	btn.mouse_exited.connect(_on_button_hover_exit.bind(btn))


# Busca todos los deslizadores en la escena y fija su valor inicial al 70%.
func _setup_volume_sliders() -> void:
	var sliders: Array[Node] = find_children("*", "Slider", true, false)
	for slider in sliders:
		if slider is Slider:
			slider.value = 70.0


# Cambia la visibilidad de un nodo de panel específico de forma segura.
func _set_panel_visible(panel: Node, is_visible: bool) -> void:
	if panel:
		panel.visible = is_visible


# --- GESTIÓN DE SUBMENÚS Y NAVEGACIÓN ---

# Alterna la visibilidad del menú de ajustes. Si se oculta, cierra sus subpaneles.
func _on_settings_pressed() -> void:
	if settings_group:
		settings_group.visible = !settings_group.visible
		if not settings_group.visible:
			_set_panel_visible(volume_group, false)
			_set_panel_visible(controls_panel, false)


# Alterna el panel de volumen y oculta el panel de controles.
func _on_volume_pressed() -> void:
	if volume_group:
		volume_group.visible = !volume_group.visible
	_set_panel_visible(controls_panel, false)


# Oculta el panel de volumen.
func _on_close_volume_pressed() -> void:
	_set_panel_visible(volume_group, false)


# Alterna el panel de controles y oculta el panel de volumen.
func _on_controls_pressed() -> void:
	if controls_panel:
		controls_panel.visible = !controls_panel.visible
	_set_panel_visible(volume_group, false)


# Oculta el panel de controles.
func _on_close_controls_pressed() -> void:
	_set_panel_visible(controls_panel, false)


# Cierra la aplicación/juego.
func _on_quit_pressed() -> void:
	get_tree().quit()


# Alterna la visibilidad de la advertencia de coleccionables.
func _on_collect_warning_toggle() -> void:
	if collect_warning:
		collect_warning.visible = !collect_warning.visible


# Procesa la pulsación de un libro para iniciar nivel o desplegar advertencia de bloqueo.
func _on_book_pressed(book: BaseButton) -> void:
	if book == btn_book1:
		print("Iniciando Nivel 1 desde Book1...")
		# get_tree().change_scene_to_file("res://escenas/nivel1.tscn")
	elif book == btn_book2 or book == btn_book3:
		_set_panel_visible(warning_panel, true)


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
