extends Node2D

const Model = preload("res://scripts/valley_model.gd")
const MapView = preload("res://scripts/valley_view.gd")
var model = Model.new()
var map_view = MapView.new()
var speed: float = 1.0
var status_label: Label
var time_label: Label
var hp_label: Label
var details_label: Label
var start_button: Button
var speed_button: Button
var selected: int = -1
var capture_path: String = ""

func _ready() -> void:
	map_view.model = model
	add_child(map_view)
	_build_interface()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			capture_path = argument.trim_prefix("--capture=")
	if not capture_path.is_empty():
		model.start()
		model.advance(12.0)
		set_process(false)
		_update_interface()
		map_view.queue_redraw()
		await RenderingServer.frame_post_draw
		var error: Error = get_viewport().get_texture().get_image().save_png(capture_path)
		print("CAPTURE_RESULT=", error)
		get_tree().quit(error)

func _process(delta: float) -> void:
	model.advance(delta * speed)
	_update_interface()
	map_view.queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var closest: int = -1
		var best: float = 27.0
		for index in range(Model.SLOTS.size()):
			var distance: float = MapView.project(Model.SLOTS[index]).distance_to(event.position)
			if distance < best:
				closest = index
				best = distance
		if closest >= 0:
			selected = closest
			map_view.selected = selected
			_update_interface()
			map_view.queue_redraw()

func _build_interface() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var screen := Control.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(screen)
	_label(screen, "FOR THE FORTRESS!", Vector2(32, 24), Vector2(720, 44), 29, Color("e0dbbf"))
	_label(screen, "LA VALLÉE DU GUÉ", Vector2(34, 71), Vector2(600, 24), 14, Color("9fb5a5"))
	_label(screen, "PREMIER ESSAI  /  TRAVERSÉE", Vector2(898, 33), Vector2(340, 25), 13, Color("cdb47e"))
	var side := _panel(screen, Rect2(24, 122, 278, 632))
	_label(side, "DÉFENDRE LE GUÉ", Vector2(22, 20), Vector2(240, 28), 18, Color("e0dbbf"))
	_label(side, "Un Pillard rejoint la forteresse.\nObservez son trajet, puis relancez\nl’essai pour comparer les vitesses.", Vector2(22, 62), Vector2(238, 80), 14, Color("aabbb0"))
	hp_label = _label(side, "", Vector2(22, 156), Vector2(238, 28), 21, Color("e2d5ad"))
	_label(side, "OR DISPONIBLE     150", Vector2(22, 194), Vector2(238, 24), 14, Color("cdb47e"))
	status_label = _label(side, "", Vector2(22, 242), Vector2(238, 56), 16, Color("d0dfd1"))
	time_label = _label(side, "", Vector2(22, 312), Vector2(238, 55), 14, Color("aabbb0"))
	start_button = _button(side, "Lancer l’essai", Rect2(22, 400, 234, 44), _start)
	speed_button = _button(side, "Vitesse ×1", Rect2(22, 454, 234, 40), _toggle_speed)
	_button(side, "Recommencer", Rect2(22, 504, 234, 40), _reset)
	_label(side, "Les combats et les achats arrivent\nà l’étape suivante.", Vector2(22, 570), Vector2(238, 42), 12, Color("8fa69a"))
	var info := _panel(screen, Rect2(330, 626, 926, 128))
	_label(info, "EMPLACEMENTS FIXES", Vector2(24, 15), Vector2(400, 24), 13, Color("cdb47e"))
	details_label = _label(info, "", Vector2(24, 49), Vector2(876, 66), 15, Color("bbcbbf"))
	_label(screen, "Cliquez sur E1 à E6 pour inspecter un emplacement.", Vector2(347, 580), Vector2(850, 24), 14, Color("91a799"))
	_label(screen, "Nom de travail · Visuels temporaires", Vector2(34, 772), Vector2(900, 20), 11, Color("718b7d"))

func _panel(parent: Control, rectangle: Rect2) -> Panel:
	var panel := Panel.new()
	panel.position = rectangle.position
	panel.size = rectangle.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("102923")
	style.border_color = Color("29463b")
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel

func _label(parent: Control, text: String, point: Vector2, extent: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = point
	label.size = extent
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _button(parent: Control, text: String, rectangle: Rect2, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rectangle.position
	button.size = rectangle.size
	button.add_theme_font_size_override("font_size", 15)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("28493d") if state == "hover" else Color("1c3b31")
		if state == "disabled":
			style.bg_color = Color("193028")
		style.border_color = Color("738c67") if state == "hover" else Color("3c5a46")
		style.set_border_width_all(1)
		style.set_corner_radius_all(6)
		button.add_theme_stylebox_override(state, style)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _start() -> void:
	model.start()
	_update_interface()

func _toggle_speed() -> void:
	speed = 2.0 if speed == 1.0 else 1.0
	_update_interface()

func _reset() -> void:
	model.reset()
	speed = 1.0
	_update_interface()
	map_view.queue_redraw()

func _update_interface() -> void:
	hp_label.text = "FORTERESSE   %d / 20 PV" % model.fortress_hp
	start_button.disabled = model.active or model.arrived
	speed_button.text = "Vitesse ×%d" % int(speed)
	if model.arrived:
		status_label.text = "Pillard arrivé\n−1 PV · aucun or gagné"
	elif model.active:
		status_label.text = "Traversée en cours\n1 Pillard · vitesse 1 u/s"
	else:
		status_label.text = "Prêt pour l’essai\n6 emplacements disponibles"
	time_label.text = "Temps de jeu : %.1f / 28 s\nDistance : %.1f / 28 unités" % [model.elapsed, model.distance]
	if selected < 0:
		details_label.text = "Six positions de construction fixes bordent le chemin.\nChoisissez un repère sur la carte pour afficher ses coordonnées."
	else:
		var slot: Vector2 = Model.SLOTS[selected]
		details_label.text = "E%d · Position logique (%.1f ; %.1f) · Emplacement libre\nUn seul défenseur pourra occuper cette position." % [selected + 1, slot.x, slot.y]
