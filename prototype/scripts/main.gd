extends Node2D

const Model = preload("res://scripts/valley_model.gd")
const MapView = preload("res://scripts/valley_view.gd")
var model = Model.new()
var map_view = MapView.new()
var speed: float = 1.0
var selected: int = -1
var status_label: Label
var time_label: Label
var hp_label: Label
var gold_label: Label
var tally_label: Label
var details_label: Label
var title_label: Label
var hint_label: Label
var start_button: Button
var speed_button: Button
var reset_button: Button
var sell_button: Button
var buy_buttons: Array[Button] = []

func _ready() -> void:
	map_view.model = model
	add_child(map_view)
	_build_interface()
	_update_interface()
	var capture_path: String = ""
	var capture_state: String = "combat"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			capture_path = argument.trim_prefix("--capture=")
		elif argument.begins_with("--capture-state="):
			capture_state = argument.trim_prefix("--capture-state=")
	if not capture_path.is_empty():
		# Mise en situation de contrôle, uniquement via l'argument de capture.
		if capture_state != "shop":
			model.buy(0, 0)
			model.buy(1, 1)
		selected = 0
		map_view.selected = 0
		if capture_state not in ["preparation", "shop"]:
			model.start()
			model.advance(7.5 if capture_state == "combat" else 100.0)
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
	_label(screen, "ALLIANCE  /  PREMIÈRE VAGUE", Vector2(898, 33), Vector2(350, 25), 13, Color("cdb47e"))
	var side := _panel(screen, Rect2(24, 122, 278, 632))
	_label(side, "DÉFENDRE LE GUÉ", Vector2(22, 20), Vector2(240, 28), 18, Color("e0dbbf"))
	_label(side, "Placez vos défenseurs, puis lancez
la vague. Ils attaquent seuls les
ennemis à portée.", Vector2(22, 62), Vector2(238, 76), 14, Color("aabbb0"))
	hp_label = _label(side, "", Vector2(22, 144), Vector2(238, 28), 21, Color("e2d5ad"))
	gold_label = _label(side, "", Vector2(22, 184), Vector2(238, 24), 16, Color("cdb47e"))
	status_label = _label(side, "", Vector2(22, 232), Vector2(238, 52), 16, Color("d0dfd1"))
	tally_label = _label(side, "", Vector2(22, 300), Vector2(238, 72), 14, Color("aabbb0"))
	time_label = _label(side, "", Vector2(22, 382), Vector2(238, 24), 14, Color("aabbb0"))
	start_button = _button(side, "Lancer la vague 1", Rect2(22, 428, 234, 44), _start)
	speed_button = _button(side, "Vitesse ×1", Rect2(22, 482, 234, 40), _toggle_speed)
	reset_button = _button(side, "Nouvel essai", Rect2(22, 532, 234, 40), _reset)
	_label(side, "Essai N1 · Sans bonus ni synergies", Vector2(22, 594), Vector2(238, 20), 11, Color("8fa69a"))
	var info := _panel(screen, Rect2(330, 608, 926, 152))
	title_label = _label(info, "CONSTRUIRE · ALLIANCE", Vector2(24, 12), Vector2(860, 24), 13, Color("cdb47e"))
	details_label = _label(info, "", Vector2(24, 41), Vector2(876, 44), 14, Color("bbcbbf"))
	for type in range(Model.ROSTER.size()):
		var button: Button = _button(info, "", Rect2(24 + type * 294, 96, 278, 40), _buy.bind(type))
		buy_buttons.append(button)
	sell_button = _button(info, "", Rect2(24, 96, 278, 40), _sell)
	hint_label = _label(screen, "", Vector2(347, 574), Vector2(890, 24), 13, Color("91a799"))
	_label(screen, "Nom de travail · Visuels temporaires", Vector2(34, 776), Vector2(900, 20), 11, Color("718b7d"))

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
	if model.active:
		return
	model.reset()
	speed = 1.0
	selected = -1
	map_view.selected = -1
	_update_interface()
	map_view.queue_redraw()

func _buy(type: int) -> void:
	model.buy(selected, type)
	_update_interface()
	map_view.queue_redraw()

func _sell() -> void:
	model.sell(selected)
	_update_interface()
	map_view.queue_redraw()

func _update_interface() -> void:
	hp_label.text = "FORTERESSE   %d / 20 PV" % model.fortress_hp
	gold_label.text = "OR DISPONIBLE     %d" % model.gold
	start_button.disabled = model.phase != "preparation"
	start_button.text = "Lancer la vague 1" if model.phase == "preparation" else "Vague 1 en cours" if model.active else "Vague 1 terminée"
	speed_button.text = "Vitesse ×%d" % int(speed)
	reset_button.disabled = model.active
	reset_button.tooltip_text = "Terminez la vague avant de recommencer." if model.active else "Repartir avec 150 or et 20 PV."
	match model.phase:
		"preparation": status_label.text = "Préparation · Vague 1
10 Pillards · 40 PV chacun"
		"combat": status_label.text = "Combat · Vague 1
Achats et ventes bloqués"
		"finished": status_label.text = "Vague 1 terminée
La forteresse a survécu"
		"defeat": status_label.text = "Forteresse détruite
Relancez un nouvel essai"
	tally_label.text = "Apparus : %d / 10
Éliminés : %d · Arrivés : %d
En chemin : %d" % [model.spawned, model.killed, model.escaped, model.enemies.size()]
	time_label.text = ("Temps de jeu : %.1f s" % model.elapsed).replace(".", ",")
	hint_label.text = "Sélectionnez E1 à E6 pour construire ou inspecter un défenseur."
	var occupied: bool = selected >= 0 and not model.defenders[selected].is_empty()
	sell_button.visible = occupied
	sell_button.disabled = not model.can_build()
	for type in range(buy_buttons.size()):
		var button: Button = buy_buttons[type]
		button.visible = not occupied
		button.text = "%s · %d or  (%d/2)" % [Model.ROSTER[type].name, Model.ROSTER[type].price, model.count_type(type)]
		button.tooltip_text = model.purchase_error(selected, type)
		button.disabled = not button.tooltip_text.is_empty()
	if selected < 0:
		title_label.text = "CONSTRUIRE · ALLIANCE"
		details_label.text = "Choisissez un emplacement sur la carte.
Les défenseurs du premier essai commencent au niveau 1."
	elif occupied:
		var defender: Dictionary = model.defenders[selected]
		var stats: Dictionary = Model.ROSTER[defender.type]
		title_label.text = "E%d · %s · NIVEAU 1" % [selected + 1, stats.name.to_upper()]
		details_label.text = "Dégâts : %s · Intervalle : %s s · Portée : %s unités · Payé : %d or" % [_number(stats.damage), _number(stats.interval), _number(stats.range), defender.paid]
		if defender.type == 2:
			details_label.text += "
Explosion : 10,8 dégâts à deux cibles secondaires au maximum, à moins d’une unité."
		sell_button.text = "Vendre · %d or" % model.refund(selected)
	else:
		var slot: Vector2 = Model.SLOTS[selected]
		title_label.text = "E%d · EMPLACEMENT LIBRE" % (selected + 1)
		details_label.text = "Position logique (%s ; %s) · Un seul défenseur par emplacement.
Choisissez parmi les trois défenseurs de l’Alliance. Deux exemplaires maximum par type." % [_number(slot.x), _number(slot.y)]
	if model.active:
		hint_label.text = "Les tirs sont automatiques. Vous pouvez inspecter les unités et changer la vitesse."
	elif model.phase == "finished":
		hint_label.text = "Vous pouvez revoir votre défense ou relancer un nouvel essai."

func _number(value: float) -> String:
	return str(value).trim_suffix(".0").replace(".", ",")
