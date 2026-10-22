extends Node2D

const Model = preload("res://scripts/valley_model.gd")
const MapView = preload("res://scripts/valley_view.gd")
const INTER_WAVE_SECONDS: float = 30.0
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
var upgrade_button: Button
var specialisation_panel: ColorRect
var specialisation_title: Label
var specialisation_cost: Label
var specialisation_names: Array[Label] = []
var specialisation_descriptions: Array[Label] = []
var specialisation_stats: Array[Label] = []
var specialisation_buttons: Array[Button] = []
var specialisation_cancel: Button
var pending_slot: int = -1
var pending_instance: int = -1
var sell_button: Button
var buy_buttons: Array[Button] = []
var hovered_purchase: int = -1
var focused_purchase: int = -1
var bonus_panel: ColorRect
var bonus_title: Label
var bonus_subtitle: Label
var bonus_names: Array[Label] = []
var bonus_descriptions: Array[Label] = []
var bonus_buttons: Array[Button] = []
var bonus_close: Button
var bonus_summary_button: Button
var overview_open: bool = false
var autoplay_started: bool = false
var countdown_wave: int = -1
var countdown_remaining: float = -1.0

func _ready() -> void:
	map_view.model = model
	add_child(map_view)
	_build_interface()
	_update_interface()
	var capture_path: String = ""
	var capture_state: String = "combat"
	var capture_faction: int = 0
	var capture_type: int = 0
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			capture_path = argument.trim_prefix("--capture=")
		elif argument == "--capture-faction=horde":
			capture_faction = 1
		elif argument.begins_with("--capture-type="):
			capture_type = clampi(int(argument.trim_prefix("--capture-type=")), 0, 5)
		elif argument.begins_with("--capture-state="):
			capture_state = argument.trim_prefix("--capture-state=")
	if not capture_path.is_empty():
		if capture_state != "selection":
			_choose_faction((0 if capture_type < 3 else 1) if capture_state in ["upgrade", "specialisation", "specialised"] else capture_faction)
			if capture_state in ["bonus", "campaign", "victory", "overview"]:
				_prepare_campaign_capture(capture_state)
			if capture_state in ["upgrade", "specialisation", "specialised"]:
				if capture_state != "upgrade": model.gold = 1000 # Fixture de capture uniquement.
				model.buy(0, capture_type)
				model.upgrade(0)
				selected = 0
				map_view.selected = 0
				if capture_state != "upgrade":
					model.upgrade(0)
					if capture_state == "specialised": model.upgrade(0, 1)
					else: _upgrade()
			if capture_state not in ["shop", "catalogue", "upgrade", "specialisation", "specialised", "bonus", "campaign", "victory", "overview", "purchase"]:
				model.buy(0, model.available_types()[0])
				model.buy(1, model.available_types()[2 if capture_state == "curse" else 1])
			selected = 1 if capture_state == "curse" else 0
			if capture_state == "purchase":
				selected = 3
				hovered_purchase = capture_type % 3
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
			elif capture_state not in ["preparation", "shop", "upgrade", "specialisation", "specialised", "bonus", "campaign", "victory", "overview", "purchase"]:
				model.start()
				model.advance(1.0 if capture_state == "curse" else 7.5 if capture_state == "combat" else 100.0)
		set_process(false)
		if capture_state == "finished": autoplay_started = true
		_update_interface()
		if capture_state in ["specialisation", "specialised"]:
			faction_label.text = "CONTRÔLE PROGRESSION · BUDGET IMPOSÉ"
		if capture_state == "catalogue":
			faction_label.text = "CATALOGUE ENNEMI · CONTRÔLE"
			status_label.text = "Profils de référence\nVue de contrôle"
		map_view.queue_redraw()
		await RenderingServer.frame_post_draw
		var error: Error = get_viewport().get_texture().get_image().save_png(capture_path)
		print("CAPTURE_RESULT=", error)
		get_tree().quit(error)

func _process(delta: float) -> void:
	var was_active: bool = model.active
	model.advance(delta * speed)
	_sync_countdown()
	# Une fin de combat arme le délai complet, même après une image très longue.
	if not was_active and model.phase == "finished" and countdown_remaining >= 0.0 and not _countdown_paused():
		countdown_remaining = maxf(0.0, countdown_remaining - delta)
		if countdown_remaining <= 0.0:
			_start()
	_update_interface()
	map_view.queue_redraw()

func _countdown_paused() -> bool:
	return pending_slot >= 0 or overview_open

func _sync_countdown() -> void:
	if model.phase == "bonus":
		overview_open = false # Le choix obligatoire remplace la simple lecture.
	if model.phase in ["victory", "defeat"]:
		autoplay_started = false
	if not autoplay_started or model.phase != "finished":
		countdown_wave = -1
		countdown_remaining = -1.0
	elif countdown_wave != model.wave:
		countdown_wave = model.wave
		countdown_remaining = INTER_WAVE_SECONDS

func _prepare_campaign_capture(state: String) -> void:
	# Référence financée au budget normal ; même politique que test_campaign.gd.
	model.rng.seed = 42
	model.buy(0,model.faction*3)
	model.buy(1,model.faction*3+1)
	selected = 0
	map_view.selected = 0
	for wave in range(1,11):
		if wave >= 4 and model.defenders[2].is_empty(): model.buy(2,model.faction*3+2)
		if wave >= 5:
			for slot in [0,1,2]:
				if not model.defenders[slot].is_empty(): model.upgrade(slot,0 if model.defenders[slot].level == 3 else -1)
		model.start()
		if wave == 9 and state == "campaign":
			model.advance(12)
			return
		model.advance(300)
		if state == "bonus" and wave == 3: return
		if model.phase == "defeat": return
		if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
		if state == "overview" and wave == 9:
			overview_open = true
			return
		if wave < 10: model.prepare_next_wave()

func _unhandled_input(event: InputEvent) -> void:
	if choosing_faction or pending_slot >= 0 or model.phase == "bonus" or overview_open:
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
	var tooltip_theme := Theme.new()
	var tooltip_style := StyleBoxFlat.new()
	tooltip_style.bg_color = Color("10271f")
	tooltip_style.border_color = Color("647d69")
	tooltip_style.set_border_width_all(1)
	tooltip_style.set_content_margin_all(12)
	tooltip_theme.set_stylebox("panel", "TooltipPanel", tooltip_style)
	tooltip_theme.set_font_size("font_size", "TooltipLabel", 14)
	tooltip_theme.set_color("font_color", "TooltipLabel", Color("e0e7db"))
	screen.theme = tooltip_theme
	ui.add_child(screen)
	_label(screen, "FOR THE FORTRESS!", Vector2(32, 24), Vector2(720, 44), 29, Color("e0dbbf"))
	_label(screen, "LA VALLÉE DU GUÉ", Vector2(34, 71), Vector2(600, 24), 14, Color("9fb5a5"))
	faction_label = _label(screen, "CHOIX DE FACTION", Vector2(898, 33), Vector2(350, 25), 13, Color("cdb47e"))
	var side := _panel(screen, Rect2(24, 122, 278, 632))
	_label(side, "DÉFENDRE LE GUÉ", Vector2(22, 20), Vector2(240, 28), 18, Color("e0dbbf"))
	_label(side, "Lancez la première vague.\nLes suivantes partent seules :\n30 s pour préparer la défense.", Vector2(22, 62), Vector2(238, 76), 14, Color("aabbb0"))
	hp_label = _label(side, "", Vector2(22, 144), Vector2(238, 28), 21, Color("e2d5ad"))
	gold_label = _label(side, "", Vector2(22, 184), Vector2(238, 24), 16, Color("cdb47e"))
	status_label = _label(side, "", Vector2(22, 232), Vector2(238, 52), 16, Color("d0dfd1"))
	tally_label = _label(side, "", Vector2(22, 300), Vector2(238, 72), 14, Color("aabbb0"))
	time_label = _label(side, "", Vector2(22, 382), Vector2(238, 24), 14, Color("aabbb0"))
	start_button = _button(side, "Lancer la vague 1", Rect2(22, 428, 234, 44), _start)
	speed_button = _button(side, "Vitesse ×1", Rect2(22, 482, 234, 40), _toggle_speed)
	reset_button = _button(side, "Nouvel essai", Rect2(22, 532, 234, 40), _reset)
	bonus_summary_button = _button(side, "Bonus acquis · 0/3", Rect2(22, 582, 234, 32), _show_bonuses)
	bonus_summary_button.add_theme_font_size_override("font_size", 13)
	var info := _panel(screen, Rect2(330, 608, 926, 152))
	title_label = _label(info, "CONSTRUIRE · ALLIANCE", Vector2(24, 12), Vector2(860, 24), 13, Color("cdb47e"))
	details_label = _label(info, "", Vector2(24, 41), Vector2(876, 44), 14, Color("bbcbbf"))
	for type in range(3):
		var button: Button = _button(info, "", Rect2(24 + type * 294, 96, 278, 40), _buy.bind(type))
		button.add_theme_font_size_override("font_size", 14)
		button.mouse_entered.connect(_purchase_hover.bind(type, true))
		button.mouse_exited.connect(_purchase_hover.bind(type, false))
		button.focus_entered.connect(_purchase_focus.bind(type, true))
		button.focus_exited.connect(_purchase_focus.bind(type, false))
		buy_buttons.append(button)
	sell_button = _button(info, "", Rect2(24, 96, 278, 40), _sell)
	upgrade_button = _button(info, "", Rect2(318, 96, 278, 40), _upgrade)
	hint_label = _label(screen, "", Vector2(347, 574), Vector2(890, 24), 13, Color("91a799"))
	hint_label.mouse_filter = Control.MOUSE_FILTER_STOP # Autoriser les infobulles des synergies.
	_label(screen, "Nom de travail · Visuels temporaires", Vector2(34, 776), Vector2(900, 20), 11, Color("718b7d"))

	_build_faction_selector(screen)
	_build_specialisation_selector(screen)
	_build_bonus_selector(screen)

func _build_faction_selector(screen: Control) -> void:
	faction_panel = ColorRect.new()
	faction_panel.color = Color(0.02, 0.04, 0.035, 0.94)
	faction_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(faction_panel)
	var panel: Panel = _panel(faction_panel, Rect2(240, 220, 800, 350))
	_label(panel, "Choisissez votre faction", Vector2(30, 28), Vector2(740, 42), 28, Color("e0dbbf"))
	_label(panel, "Chaque camp possède trois défenseurs pour les dix vagues.", Vector2(30, 88), Vector2(740, 30), 16, Color("aabbb0"))
	faction_buttons.append(_button(panel, "Alliance des Royaumes", Rect2(30, 152, 350, 52), _choose_faction.bind(0)))
	faction_buttons.append(_button(panel, "Horde des Cendres", Rect2(420, 152, 350, 52), _choose_faction.bind(1)))
	_label(panel, "Archer, arbalétrier et mage.\nPrécision et attaque de groupe.", Vector2(30, 224), Vector2(350, 62), 15, Color("bbcbbf"))
	_label(panel, "Troll, sapeur et chaman.\nRebonds, explosifs et malédictions.", Vector2(420, 224), Vector2(350, 62), 15, Color("bbcbbf"))
	_label(panel, "La Vallée du Gué · 150 or · 20 PV", Vector2(30, 308), Vector2(740, 24), 13, Color("cdb47e"))

func _choose_faction(choice: int) -> void:
	if choosing_faction and model.select_faction(choice):
		choosing_faction = false
		_update_interface()

func _build_specialisation_selector(screen: Control) -> void:
	specialisation_panel = ColorRect.new()
	specialisation_panel.color = Color(0.02, 0.04, 0.035, 0.94)
	specialisation_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(specialisation_panel)
	var panel: Panel = _panel(specialisation_panel, Rect2(220, 144, 840, 512))
	specialisation_title = _label(panel, "", Vector2(30, 22), Vector2(780, 36), 24, Color("e0dbbf"))
	specialisation_cost = _label(panel, "", Vector2(30, 72), Vector2(780, 52), 15, Color("cdb47e"))
	for branch in range(2):
		var x: int = 30 + branch * 410
		specialisation_names.append(_label(panel, "", Vector2(x, 132), Vector2(370, 30), 17, Color("e0dbbf")))
		specialisation_descriptions.append(_label(panel, "", Vector2(x, 174), Vector2(370, 50), 14, Color("aabbb0")))
		specialisation_descriptions[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		specialisation_stats.append(_label(panel, "", Vector2(x, 238), Vector2(370, 130), 14, Color("bbcbbf")))
		specialisation_buttons.append(_button(panel, "Choisir cette spécialisation", Rect2(x, 384, 370, 44), _choose_branch.bind(branch)))
	specialisation_cancel = _button(panel, "Annuler", Rect2(330, 452, 180, 40), _cancel_specialisation)

func _upgrade() -> void:
	if choosing_faction or overview_open or pending_slot >= 0 or selected < 0 or model.defenders[selected].is_empty():
		return
	var defender: Dictionary = model.defenders[selected]
	if defender.level == 3:
		if not model.upgrade_error(selected, 0).is_empty():
			return
		pending_slot = selected
		pending_instance = defender.instance_id
		_update_specialisation_choices()
	else:
		model.upgrade(selected)
	_update_interface()
	map_view.queue_redraw()

func _update_specialisation_choices() -> void:
	if pending_slot < 0:
		return
	var defender: Dictionary = model.defenders[pending_slot]
	var type: int = defender.type
	specialisation_title.text = "Spécialisation · " + Model.ROSTER[type].name
	specialisation_cost.text = "Spécialisation (niveau 4) : %d or.\nTotal investi après amélioration : %d or." % [model.upgrade_cost(pending_slot), defender.paid + model.upgrade_cost(pending_slot)]
	for branch in range(2):
		var stats: Dictionary = model.get_stats(pending_slot, branch)
		specialisation_names[branch].text = ("A · " if branch == 0 else "B · ") + stats.branch_name
		specialisation_descriptions[branch].text = stats.description
		specialisation_stats[branch].text = "Dégâts principaux : %s\nIntervalle : %s s\nPortée : %s unités" % [_number(stats.damage), _number(stats.interval), _number(stats.range)]
		if type in [2, 3, 4]:
			specialisation_stats[branch].text += "\nSecondaires : %s dégâts\n%s %s, distance < %s" % [_number(stats.secondary_damage), stats.secondary_cap, ("rebond" if stats.secondary_cap == 1 else "rebonds") if type == 3 else "victimes", _number(stats.radius)]
		elif type == 5:
			specialisation_stats[branch].text += "\nMalédiction : %s dégâts\nÀ +1 s puis +2 s, même hors portée." % _number(stats.curse_damage)
		specialisation_buttons[branch].disabled = not model.upgrade_error(pending_slot, branch).is_empty()

func _choose_branch(branch: int) -> void:
	if pending_slot < 0:
		return
	var defender: Dictionary = model.defenders[pending_slot]
	if defender.is_empty() or defender.instance_id != pending_instance:
		_cancel_specialisation()
		return
	if model.upgrade(pending_slot, branch):
		_cancel_specialisation()
	else:
		_update_specialisation_choices()
		_update_interface()

func _cancel_specialisation() -> void:
	pending_slot = -1
	pending_instance = -1
	_update_interface()
	map_view.queue_redraw()

func _effect_text(stats: Dictionary, type: int) -> String:
	if type == 3:
		return "%s rebond%s : %s dégâts chacun, distance < %s." % [stats.secondary_cap, "" if stats.secondary_cap == 1 else "s successifs", _number(stats.secondary_damage), _number(stats.radius)]
	if type in [2, 4]:
		return "Explosion : %s dégâts × %s cibles secondaires, rayon < %s." % [_number(stats.secondary_damage), stats.secondary_cap, _number(stats.radius)]
	if type == 5:
		return "Malédiction : %s dégâts à +1 s puis +2 s, même hors portée." % _number(stats.curse_damage)
	return ""

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
	if choosing_faction or pending_slot >= 0 or model.phase == "bonus" or overview_open:
		return
	if model.phase == "finished": model.prepare_next_wave()
	if model.start(): autoplay_started = true
	_update_interface()

func _toggle_speed() -> void:
	speed = 2.0 if speed == 1.0 else 1.0
	_update_interface()

func _reset() -> void:
	if model.active or pending_slot >= 0:
		return
	overview_open = false
	autoplay_started = false
	countdown_wave = -1
	countdown_remaining = -1.0
	model.reset()
	choosing_faction = true
	speed = 1.0
	selected = -1
	map_view.selected = -1
	_update_interface()
	map_view.queue_redraw()

func _buy(type: int) -> void:
	if choosing_faction or pending_slot >= 0 or model.phase == "bonus" or overview_open:
		return
	model.buy(selected, model.available_types()[type])
	_update_interface()
	map_view.queue_redraw()

func _purchase_hover(type: int, entered: bool) -> void:
	if entered: hovered_purchase = type
	elif hovered_purchase == type: hovered_purchase = -1
	_update_interface()
	map_view.queue_redraw()

func _purchase_focus(type: int, entered: bool) -> void:
	if entered: focused_purchase = type
	elif focused_purchase == type: focused_purchase = -1
	_update_interface()
	map_view.queue_redraw()

func _refresh_purchase_preview() -> void:
	map_view.purchase_preview = {}
	if choosing_faction or pending_slot >= 0 or overview_open or not model.can_build() or selected < 0 or not model.defenders[selected].is_empty():
		hovered_purchase = -1
		focused_purchase = -1
		return
	var offer: int = hovered_purchase if hovered_purchase >= 0 else focused_purchase
	if offer < 0 or offer >= buy_buttons.size(): return
	var type: int = model.available_types()[offer]
	map_view.purchase_preview = model.purchase_preview_stats(selected, type)
	var stats: Dictionary = map_view.purchase_preview
	if stats.is_empty(): return
	title_label.text = "E%d · APERÇU AVANT ACHAT · %s · NIVEAU 1" % [selected+1, stats.name.to_upper()]
	details_label.text = "Portée prévue : %s · Prix : %d or\nRoute bleue : portion du chemin à portée de cette unité." % [_number(stats.range), model.purchase_cost(type)]
	var error: String = model.purchase_error(selected, type)
	hint_label.text = "Aperçu sans achat · Cliquez sur le bouton pour recruter." if error.is_empty() else "Aperçu sans achat · " + error

func _sell() -> void:
	if pending_slot >= 0 or overview_open:
		return
	model.sell(selected)
	_update_interface()
	map_view.queue_redraw()

func _update_interface() -> void:
	_sync_countdown()
	hp_label.text = "FORTERESSE   %d / %d PV" % [model.fortress_hp,model.max_hp]
	gold_label.text = "OR DISPONIBLE     %d" % model.gold
	faction_panel.visible = choosing_faction
	faction_label.text = "CHOIX DE FACTION" if choosing_faction else ("ALLIANCE" if model.faction == 0 else "HORDE") + "  /  VAGUE %d SUR 10" % model.wave
	specialisation_panel.visible = pending_slot >= 0
	start_button.disabled = choosing_faction or pending_slot >= 0 or overview_open or model.phase not in ["preparation","finished"]
	start_button.text = "Lancer la vague %d" % (model.wave+1 if model.phase == "finished" else model.wave) if model.phase in ["preparation","finished"] else "Vague %d en cours" % model.wave if model.active else "Partie gagnée" if model.phase == "victory" else "Choisissez un bonus" if model.phase == "bonus" else "Partie terminée"
	if countdown_remaining >= 0.0:
		start_button.text = "En pause · %d s" % ceili(countdown_remaining) if _countdown_paused() else "Vague %d dans %d s" % [model.wave+1,ceili(countdown_remaining)]
	var preview_wave: int = mini(10, model.wave+1 if model.phase == "finished" else model.wave)
	var preview: Array[String] = []
	for group in Model.Campaign.WAVES[preview_wave-1]:
		preview.append("%d %s · intervalle %s s" % [group[1],Model.ENEMY_TYPES[group[0]].name,_number(group[2])])
	start_button.tooltip_text = "Vague %d\n%s\n4 s entre la dernière apparition d’un groupe et la première du suivant." % [preview_wave,"\n".join(preview)]
	if countdown_remaining >= 0.0:
		start_button.tooltip_text += "\nDépart automatique après le décompte. Cliquez pour lancer maintenant."
	speed_button.text = "Vitesse ×%d" % int(speed)
	reset_button.disabled = model.active or pending_slot >= 0
	reset_button.tooltip_text = "Terminez la vague avant de recommencer." if model.active else "Repartir avec 150 or et 20 PV."
	match model.phase:
		"preparation": status_label.text = "Préparation · Vague %d/10\n%d ennemis" % [model.wave,model.spawn_schedule.size()]
		"combat": status_label.text = "Combat · Vague %d/10\nAchats et ventes bloqués" % model.wave
		"finished": status_label.text = "Vague %d terminée\nPréparez la vague %d" % [model.wave,model.wave+1]
		"bonus": status_label.text = "Vague %d terminée\nChoix roguelite obligatoire" % model.wave
		"victory": status_label.text = "VICTOIRE · Dix vagues\nLa forteresse a survécu"
		"defeat": status_label.text = "Forteresse détruite\nRelancez un nouvel essai"
	if countdown_remaining >= 0.0:
		status_label.text = "Vague %d terminée\n%s" % [model.wave,"Décompte suspendu" if _countdown_paused() else "Préparation : %d s" % ceili(countdown_remaining)]
	bonus_summary_button.text = "Bonus acquis · %d/3" % model.bonuses.size()
	bonus_summary_button.disabled = choosing_faction or pending_slot >= 0 or model.phase == "bonus"
	_update_bonus_panel()
	tally_label.text = "Apparus : %d / %d\nÉliminés : %d · Arrivés : %d\nEn chemin : %d" % [model.spawned, model.spawn_schedule.size(), model.killed, model.escaped, model.enemies.size()]
	time_label.text = ("Combat cumulé : %.1f s" % (model.completed_time+model.elapsed)).replace(".", ",")
	hint_label.text = "Sélectionnez E1 à E6 pour construire ou inspecter un défenseur."
	var occupied: bool = selected >= 0 and not model.defenders[selected].is_empty()
	sell_button.visible = occupied
	sell_button.disabled = pending_slot >= 0 or not model.can_build()
	upgrade_button.visible = occupied
	for type in range(buy_buttons.size()):
		var button: Button = buy_buttons[type]
		var actual_type: int = model.available_types()[type]
		var offer: Dictionary = Model.ROSTER[actual_type]
		button.visible = not occupied
		button.text = "%s · %d or  (%d/2)" % [offer.get("short_name", offer.name), model.purchase_cost(actual_type), model.count_type(actual_type)]
		button.tooltip_text = model.purchase_error(selected, actual_type)
		button.disabled = choosing_faction or not button.tooltip_text.is_empty()
	if selected < 0:
		title_label.text = "CONSTRUIRE · " + ("ALLIANCE" if model.faction == 0 else "HORDE")
		details_label.text = "Choisissez un emplacement sur la carte.\nLes défenseurs du premier essai commencent au niveau 1."
	elif occupied:
		var defender: Dictionary = model.defenders[selected]
		var stats: Dictionary = model.get_stats(selected)
		title_label.text = "E%d · %s · NIVEAU %d" % [selected + 1, stats.name.to_upper(), defender.level]
		if defender.level == 4:
			title_label.text += " · " + stats.branch_name
		details_label.text = "Dégâts : %s · Intervalle : %s s · Portée : %s unités · Investi : %d or" % [_number(stats.damage), _number(stats.interval), _number(stats.range), defender.paid]
		var effect: String = _effect_text(stats, defender.type)
		if not effect.is_empty():
			details_label.text += "\n" + effect
		upgrade_button.text = "Niveau maximum" if defender.level == 4 else "Spécialisation · %d or" % model.upgrade_cost(selected) if defender.level == 3 else "Niveau %d · %d or" % [defender.level + 1, model.upgrade_cost(selected)]
		upgrade_button.tooltip_text = model.upgrade_error(selected, 0 if defender.level == 3 else -1)
		upgrade_button.disabled = pending_slot >= 0 or not upgrade_button.tooltip_text.is_empty()
		sell_button.text = "Vendre · %d or" % model.refund(selected)
	else:
		var slot: Vector2 = Model.SLOTS[selected]
		title_label.text = "E%d · EMPLACEMENT LIBRE" % (selected + 1)
		details_label.text = "Position logique (%s ; %s) · Un seul défenseur par emplacement.\nDeux exemplaires maximum par type dans votre faction." % [_number(slot.x), _number(slot.y)]
		if model.can_build(): hint_label.text = "Survolez un défenseur pour voir sa portée avant l’achat."
	if model.active:
		hint_label.text = "Les tirs sont automatiques. Vous pouvez inspecter les unités et changer la vitesse."
	elif model.phase == "finished":
		hint_label.text = "Achats, améliorations et ventes autorisés avant la vague suivante."
	if occupied:
		var effects: Dictionary = model.get_stats(selected)
		hint_label.text = "Synergies actives : %d · Partenaires reliés sur la carte · Survolez pour les détails" % effects.synergies.size() if not effects.synergies.is_empty() else "Aucune synergie active · Survolez pour voir les associations possibles"
		hint_label.tooltip_text = _synergy_tooltip(selected)
	else:
		hint_label.tooltip_text = ""
	if model.phase in ["victory","defeat"]:
		hint_label.text = "%d éliminés · %d arrivées · %d or gagnés · Survolez pour les synergies" % [model.total_killed,model.total_escaped,model.total_income] if occupied else "%d éliminés · %d arrivées · %d or gagnés au combat." % [model.total_killed,model.total_escaped,model.total_income]
	_refresh_purchase_preview()

func _synergy_tooltip(slot: int) -> String:
	var type: int = model.defenders[slot].type
	var descriptions: Array[String] = ["SYNERGIES · " + Model.ROSTER[type].name, "Traits dorés : proximité · Traits bleus : spécialisations"]
	for rule in Model.Campaign.PROXIMITY + Model.Campaign.SPECIALISATIONS:
		var side: int = rule.types.find(type)
		if side < 0: continue
		var specialised: bool = rule.has("branches")
		var partner_type: int = rule.types[1-side]
		var partner_name: String = Model.stats_for(partner_type, 4, rule.branches[1-side]).branch_name if specialised else Model.ROSTER[partner_type].name
		var partners: Array[int] = model.synergy_partners(slot, rule)
		var places: Array[String] = []
		for other_slot in partners: places.append("E%d" % (other_slot+1))
		var status: String = "Active avec " + partner_name + " (" + ", ".join(places) + ")" if not partners.is_empty() else "Inactive · Partenaire requis : " + partner_name
		descriptions.append("\n" + ("Spécialisation · " if specialised else "Proximité · ") + status)
		var gains: Array[String] = []
		for i in range(4):
			var gain: float = rule.effects[side][i]
			if gain > 0:
				gains.append("+%s %s" % [_number(gain if i == 3 else gain*100), ["% aux dégâts directs", "% aux dégâts des rebonds" if type == 3 else "% aux dégâts des explosions", "% aux dégâts de malédiction", "de portée"][i]])
		descriptions.append("Pour cette unité : " + ", ".join(gains))
		if specialised:
			descriptions.append("Votre spécialisation requise : " + Model.stats_for(type, 4, rule.branches[side]).branch_name + ".\nAucune limite de distance.")
		else:
			var compatible: Array[String] = []
			for other_slot in range(Model.SLOTS.size()):
				if other_slot != slot and Model.SLOTS[slot].distance_squared_to(Model.SLOTS[other_slot]) <= 25.0: compatible.append("E%d" % (other_slot+1))
			descriptions.append("Emplacements du partenaire à proximité : " + ", ".join(compatible) + ".")
	descriptions.append("\nUn même bonus ne se cumule pas avec plusieurs partenaires.\nLes statistiques affichées incluent déjà les synergies actives.")
	return "\n".join(descriptions)

func _number(value: float) -> String:
	return str(value).trim_suffix(".0").replace(".", ",")

func _build_bonus_selector(screen: Control) -> void:
	bonus_panel = ColorRect.new()
	bonus_panel.color = Color(0.02,0.04,0.035,0.96)
	bonus_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(bonus_panel)
	var panel: Panel = _panel(bonus_panel,Rect2(100,166,1080,468))
	bonus_title = _label(panel,"",Vector2(28,24),Vector2(1024,40),26,Color("e0dbbf"))
	bonus_subtitle = _label(panel,"",Vector2(28,78),Vector2(1024,46),15,Color("aabbb0"))
	bonus_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for index in range(3):
		var x: int = 28+index*348
		bonus_names.append(_label(panel,"",Vector2(x,148),Vector2(328,54),18,Color("e0dbbf")))
		bonus_names[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bonus_descriptions.append(_label(panel,"",Vector2(x,216),Vector2(320,108),16,Color("bbcbbf")))
		bonus_descriptions[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bonus_buttons.append(_button(panel,"Choisir ce bonus",Rect2(x,354,328,48),_choose_bonus.bind(index)))
	bonus_close = _button(panel,"Fermer",Rect2(442,408,196,36),_close_bonuses)

func _show_bonuses() -> void:
	if choosing_faction or pending_slot >= 0 or model.phase == "bonus": return
	overview_open = true
	_update_interface()

func _close_bonuses() -> void:
	overview_open = false
	_update_interface()

func _choose_bonus(index: int) -> void:
	if model.phase != "bonus" or index < 0 or index >= model.bonus_offer.size(): return
	model.choose_bonus(model.bonus_offer[index])
	_update_interface()
	map_view.queue_redraw()

func _update_bonus_panel() -> void:
	var choosing: bool = model.phase == "bonus"
	bonus_panel.visible = choosing or overview_open
	if not bonus_panel.visible: return
	bonus_title.text = "Choisissez une amélioration · Vague %d terminée" % model.wave if choosing else "Bonus acquis pour cette partie"
	bonus_subtitle.text = "Choisissez sans limite de temps. Le décompte de 30 s commence après votre choix. Les deux autres offres pourront revenir." if choosing else "Les effets concernent aussi les futures recrues selon leurs conditions. Aucun bonus acquis." if model.bonuses.is_empty() else "Les effets concernent aussi les futures recrues selon leurs conditions."
	var entries: Array[int] = model.bonus_offer if choosing else model.bonuses
	for index in range(3):
		bonus_names[index].visible = index < entries.size()
		bonus_descriptions[index].visible = index < entries.size()
		bonus_buttons[index].visible = choosing and index < entries.size()
		if index < entries.size():
			var data: Dictionary = Model.Campaign.BONUSES[entries[index]]
			bonus_names[index].text = data.code+" · "+data.name
			bonus_descriptions[index].text = data.faction_descriptions[model.faction] if data.has("faction_descriptions") else data.description
	bonus_close.visible = not choosing
