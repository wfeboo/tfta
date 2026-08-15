extends Node2D

var hover_scale: Vector2 = Vector2(1.1, 1.1)
var normal_scale: Vector2 = Vector2(1.0, 1.0)
var animation_duration: float = 0.35

var tweens: Dictionary = {}

# --- REFERENCIAS A PANELES ---
@onready var settings_group: Node = $CanvasLayer/SettingsGroup
@onready var volume_group: Node = $CanvasLayer/VolumeGroup
@onready var warning_panel: Node = $CanvasLayer/WarningPanel

# --- REFERENCIAS A BOTONES DE AJUSTES ---
@onready var btn_settings: BaseButton = $CanvasLayer/Settings
@onready var btn_volume: BaseButton = $CanvasLayer/SettingsGroup/Volume
@onready var btn_close_volume: BaseButton = $CanvasLayer/VolumeGroup/Button2
@onready var btn_quit: BaseButton = $CanvasLayer/QuitGame

# --- REFERENCIAS A LIBROS ---
@onready var btn_book1: BaseButton = $CanvasLayer/Book1
@onready var btn_book2: BaseButton = $CanvasLayer/Book2
@onready var btn_book3: BaseButton = $CanvasLayer/Book3

# --- BOTÓN DE CERRAR DEL WARNING PANEL ---
@onready var btn_close_warning: BaseButton = $CanvasLayer/WarningPanel/Button 

func _ready() -> void:
	await get_tree().process_frame

	# Evitar que los paneles invisibles bloqueen clics
	_set_mouse_ignore(settings_group)
	_set_mouse_ignore(volume_group)
	_set_mouse_ignore(warning_panel)

	# Estado inicial: Paneles ocultos
	if settings_group: settings_group.visible = false
	if volume_group: volume_group.visible = false
	if warning_panel: warning_panel.visible = false

	# 1. Configurar botones del MENÚ DE AJUSTES
	var menu_buttons: Array[BaseButton] = [btn_settings, btn_volume, btn_close_volume, btn_quit]
	for btn in menu_buttons:
		if btn != null:
			_setup_button_hover(btn)

	if btn_settings: btn_settings.pressed.connect(_on_settings_pressed)
	if btn_volume: btn_volume.pressed.connect(_on_volume_pressed)
	if btn_close_volume: btn_close_volume.pressed.connect(_on_close_volume_pressed)
	if btn_quit: btn_quit.pressed.connect(_on_quit_pressed)

	# 2. Configurar LIBROS (Pasamos 'book' como parámetro al conectar)
	var book_buttons: Array[BaseButton] = [btn_book1, btn_book2, btn_book3]
	for book in book_buttons:
		if book != null:
			_setup_button_hover(book)
			book.pressed.connect(_on_book_pressed.bind(book))

	# 3. Configurar BOTÓN CERRAR del WarningPanel
	if btn_close_warning != null:
		_setup_button_hover(btn_close_warning)
		btn_close_warning.pressed.connect(_on_close_warning_pressed)

# --- AUXILIARES ---

func _set_mouse_ignore(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _setup_button_hover(btn: BaseButton) -> void:
	if "size" in btn and btn.size != Vector2.ZERO:
		btn.pivot_offset = btn.size / 2.0
	btn.mouse_entered.connect(_on_button_hover_enter.bind(btn))
	btn.mouse_exited.connect(_on_button_hover_exit.bind(btn))

# --- ACCIONES DE CLIC ---

func _on_settings_pressed() -> void:
	if settings_group:
		settings_group.visible = !settings_group.visible
		if not settings_group.visible and volume_group:
			volume_group.visible = false

func _on_volume_pressed() -> void:
	if volume_group:
		volume_group.visible = !volume_group.visible

func _on_close_volume_pressed() -> void:
	if volume_group:
		volume_group.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()

# --- LÓGICA DE LIBROS ---

func _on_book_pressed(book: BaseButton) -> void:
	# Verificamos qué libro se presionó según su nombre en el árbol de nodos
	if book == btn_book1:
		# ¡Aquí va la acción de Book1! (Ejemplo: Cargar la escena del Nivel 1)
		print("Iniciando Nivel 1 desde Book1...")
		# get_tree().change_scene_to_file("res://escenas/nivel1.tscn")
		
	elif book == btn_book2 or book == btn_book3:
		# Solo mostramos la advertencia para Book2 y Book3
		if warning_panel:
			warning_panel.visible = true

func _on_close_warning_pressed() -> void:
	if warning_panel:
		warning_panel.visible = false

# --- ANIMACIONES HOVER ---

func _on_button_hover_enter(btn: BaseButton) -> void:
	if "size" in btn and btn.size != Vector2.ZERO:
		btn.pivot_offset = btn.size / 2.0
	_animate_scale(btn, hover_scale)

func _on_button_hover_exit(btn: BaseButton) -> void:
	_animate_scale(btn, normal_scale)

func _animate_scale(btn: BaseButton, target_scale: Vector2) -> void:
	if tweens.has(btn) and tweens[btn] != null and tweens[btn].is_running():
		tweens[btn].kill()
		
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tweens[btn] = tween
	tween.tween_property(btn, "scale", target_scale, animation_duration)
