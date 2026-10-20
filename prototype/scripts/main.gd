extends Node2D

const Model = preload("res://scripts/valley_model.gd")
const MapView = preload("res://scripts/valley_view.gd")
var model = Model.new()
var map_view = MapView.new()
var speed: float = 1.0
var selected: int = -1
var choosing_faction: bool = true
var faction_panel: ColorRect
var faction_label: Label
var faction_buttons: Array[Button] = []
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
	var capture_faction: int = 0
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			capture_path = argument.trim_prefix("--capture=")
		elif argument == "--capture-faction=horde":
			capture_faction = 1
		elif argument.begins_with("--capture-state="):
			capture_state = argument.trim_prefix("--capture-state=")
	if not capture_path.is_empty():
		if capture_state != "selection":
			_choose_faction(capture_faction)
			if capture_state not in ["shop", "catalogue"]:
				model.buy(0, model.available_types()[0])
				model.buy(1, model.available_types()[2 if capture_state == "curse" else 1])
			selected = 1 if capture_state == "curse" else 0
			map_view.selected = selected
			if capture_state == "catalogue":
				model.spawn_schedule.clear()
				for type in range(Model.ENEMY_TYPES.size()):
					model.spawn_schedule.append({"time": 0.0, "type": type})
					var enemy: Dictionary = Model.make_enemy(type, type, 0.0)
					var progress: float = 2.0 + type * 3.5
					enemy.spawn_time = -progress / enemy.speed
					enemy.distance = progress
					model.enemies.append(enemy)
				model.spawned = model.enemies.size()
				model.phase = "combat"
			elif capture_state not in ["preparation", "shop"]:
				model.start()
				model.advance(1.0 if capture_state == "curse" else 7.5 if capture_state == "combat" else 100.0)
		set_process(false)
		_update_interface()
		if capture_state == "catalogue":
			faction_label.text = "CATALOGUE ENNEMI · CONTRÔLE"
			status_label.text = "Profils de référence\nVue de contrôle"
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
	if choosing_faction:
		return
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
	faction_label = _label(screen, "CHOIX DE FACTION", Vector2(898, 33), Vector2(350, 25), 13, Color("cdb47e"))
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
	for type in range(3):
		var button: Button = _button(info, "", Rect2(24 + type * 294, 96, 278, 40), _buy.bind(type))
		button.add_theme_font_size_override("font_size", 14)
		buy_buttons.append(button)
	sell_button = _button(info, "", Rect2(24, 96, 278, 40), _sell)
	hint_label = _label(screen, "", Vector2(347, 574), Vector2(890, 24), 13, Color("91a799"))
	_label(screen, "Nom de travail · Visuels temporaires", Vector2(34, 776), Vector2(900, 20), 11, Color("718b7d"))

	_build_faction_selector(screen)

func _build_faction_selector(screen: Control) -> void:
	faction_panel = ColorRect.new()
	faction_panel.color = Color(0.02, 0.04, 0.035, 0.94)
	faction_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(faction_panel)
	var panel: Panel = _panel(faction_panel, Rect2(240, 220, 800, 350))
	_label(panel, "Choisissez votre faction", Vector2(30, 28), Vector2(740, 42), 28, Color("e0dbbf"))
	_label(panel, "Chaque camp possède trois défenseurs pour ce premier affrontement.", Vector2(30, 88), Vector2(740, 30), 16, Color("aabbb0"))
	faction_buttons.append(_button(panel, "Alliance des Royaumes", Rect2(30, 152, 350, 52), _choose_faction.bind(0)))
	faction_buttons.append(_button(panel, "Horde des Cendres", Rect2(420, 152, 350, 52), _choose_faction.bind(1)))
	_label(panel, "Archer, arbalétrier et mage.\nPrécision et attaque de groupe.", Vector2(30, 224), Vector2(350, 62), 15, Color("bbcbbf"))
	_label(panel, "Troll, sapeur et chaman.\nRebonds, explosifs et malédictions.", Vector2(420, 224), Vector2(350, 62), 15, Color("bbcbbf"))
	_label(panel, "La Vallée du Gué · 150 or · 20 PV", Vector2(30, 308), Vector2(740, 24), 13, Color("cdb47e"))

func _choose_faction(choice: int) -> void:
	if choosing_faction and model.select_faction(choice):
		choosing_faction = false
		_update_interface()

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
	if choosing_faction:
		return
	model.start()
	_update_interface()

func _toggle_speed() -> void:
	speed = 2.0 if speed == 1.0 else 1.0
	_update_interface()

func _reset() -> void:
	if model.active:
		return
	model.reset()
	choosing_faction = true
	speed = 1.0
	selected = -1
	map_view.selected = -1
	_update_interface()
	map_view.queue_redraw()

func _buy(type: int) -> void:
	if choosing_faction:
		return
	model.buy(selected, model.available_types()[type])
	_update_interface()
	map_view.queue_redraw()

func _sell() -> void:
	model.sell(selected)
	_update_interface()
	map_view.queue_redraw()

func _update_interface() -> void:
	hp_label.text = "FORTERESSE   %d / 20 PV" % model.fortress_hp
	gold_label.text = "OR DISPONIBLE     %d" % model.gold
	faction_panel.visible = choosing_faction
	faction_label.text = "CHOIX DE FACTION" if choosing_faction else ("ALLIANCE" if model.faction == 0 else "HORDE") + "  /  PREMIÈRE VAGUE"
	start_button.disabled = choosing_faction or model.phase != "preparation"
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
	tally_label.text = "Apparus : %d / %d
Éliminés : %d · Arrivés : %d
En chemin : %d" % [model.spawned, model.spawn_schedule.size(), model.killed, model.escaped, model.enemies.size()]
	time_label.text = ("Temps de jeu : %.1f s" % model.elapsed).replace(".", ",")
	hint_label.text = "Sélectionnez E1 à E6 pour construire ou inspecter un défenseur."
	var occupied: bool = selected >= 0 and not model.defenders[selected].is_empty()
	sell_button.visible = occupied
	sell_button.disabled = not model.can_build()
	for type in range(buy_buttons.size()):
		var button: Button = buy_buttons[type]
		var actual_type: int = model.available_types()[type]
		var offer: Dictionary = Model.ROSTER[actual_type]
		button.visible = not occupied
		button.text = "%s · %d or  (%d/2)" % [offer.get("short_name", offer.name), offer.price, model.count_type(actual_type)]
		button.tooltip_text = model.purchase_error(selected, actual_type)
		button.disabled = choosing_faction or not button.tooltip_text.is_empty()
	if selected < 0:
		title_label.text = "CONSTRUIRE · " + ("ALLIANCE" if model.faction == 0 else "HORDE")
		details_label.text = "Choisissez un emplacement sur la carte.
Les défenseurs du premier essai commencent au niveau 1."
	elif occupied:
		var defender: Dictionary = model.defenders[selected]
		var stats: Dictionary = Model.ROSTER[defender.type]
		title_label.text = "E%d · %s · NIVEAU 1" % [selected + 1, stats.name.to_upper()]
		details_label.text = "Dégâts : %s · Intervalle : %s s · Portée : %s unités · Payé : %d or" % [_number(stats.damage), _number(stats.interval), _number(stats.range), defender.paid]
		if defender.type == 2:
			details_label.text += "\nExplosion : 10,8 dégâts à deux cibles secondaires au maximum, à moins d’une unité."
		elif defender.type == 3:
			details_label.text += "\nUn rebond : 8 dégâts à une autre cible située à moins d’une unité de la première."
		elif defender.type == 4:
			details_label.text += "\nExplosion : 9,6 dégâts à trois cibles secondaires au maximum, à moins d’une unité."
		elif defender.type == 5:
			details_label.text += "\nMalédiction : 4,8 dégâts après 1 s puis 2 s, même hors portée, sans ralentissement."
		sell_button.text = "Vendre · %d or" % model.refund(selected)
	else:
		var slot: Vector2 = Model.SLOTS[selected]
		title_label.text = "E%d · EMPLACEMENT LIBRE" % (selected + 1)
		details_label.text = "Position logique (%s ; %s) · Un seul défenseur par emplacement.
Deux exemplaires maximum par type dans votre faction." % [_number(slot.x), _number(slot.y)]
	if model.active:
		hint_label.text = "Les tirs sont automatiques. Vous pouvez inspecter les unités et changer la vitesse."
	elif model.phase == "finished":
		hint_label.text = "Vous pouvez revoir votre défense ou relancer un nouvel essai."

func _number(value: float) -> String:
	return str(value).trim_suffix(".0").replace(".", ",")
