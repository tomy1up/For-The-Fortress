extends Node2D

class LiveTooltipLabel extends Label:
	var source: WeakRef
	func _process(_delta: float) -> void:
		var button: Object = source.get_ref()
		if button == null: return
		if button.tooltip_blocked or button.tooltip_quiet:
			hide()
			if get_parent() is PopupPanel: get_parent().hide()
			return
		if text != button.tooltip_text:
			text = button.tooltip_text
			reset_size()
			var popup: Node = get_parent()
			if popup is PopupPanel: popup.size = Vector2i.ZERO

class LiveTooltipButton extends Button:
	var tooltip_blocked: bool = false
	var tooltip_quiet: bool = false
	func _get_tooltip(_at_position: Vector2) -> String:
		return "" if tooltip_blocked or tooltip_quiet else tooltip_text
	func _make_custom_tooltip(for_text: String) -> Object:
		if for_text.is_empty(): return null
		var content := LiveTooltipLabel.new()
		content.source = weakref(self)
		content.text = for_text
		content.custom_minimum_size.x = 520
		content.size.x = 520
		content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_theme_font_size_override("font_size",14)
		content.add_theme_color_override("font_color",Color("d9e4d7"))
		return content

const Model = preload("res://scripts/valley_model.gd")
const RunReport = preload("res://scripts/run_report.gd")
const MapView = preload("res://scripts/valley_view.gd")
const MetaProfile = preload("res://scripts/meta_profile.gd")
const MetaScreen = preload("res://scripts/meta_screen.gd")
var meta_profile: RefCounted
var meta_menu = MetaScreen.new()
var meta_run_id: int = -1
var meta_run_earned: int = 0
var meta_retry_remaining: float = 0.0
var run_final_map: bool = true # Le prototype a une carte ; le futur pilote de campagne gérera cette frontière.
var run_map_index: int = 0
var run_map_rewards: Dictionary = {} # Gains provisoires, en mémoire uniquement, par carte du parcours.
var meta_income: Label
var meta_progress_label: Label
var loadout_label: Label
var loadout_key: String = ""
var summary_loadout_content: Control
var summary_loadout_names: Array[Label] = []
var summary_loadout_points: Array[Label] = []
var summary_loadout_nodes: Array[Label] = []
var summary_loadout_hp: Label
var summary_loadout_units: Array[Label] = []
var meta_buttons: Array[Button] = []
var home_resources: Array[Label] = []
var home_points: Array[Label] = []
var home_hp: Array[Label] = []
var home_hints: Array[Label] = []
var home_progress_key: String = ""
var summary_core_cards: Array[Panel] = []
var summary_core_titles: Array[Label] = []
var summary_meta_card: Panel
var summary_meta_value: Label
var summary_meta_status: Label
var summary_meta_note: Label
var summary_talents_button: Button
const INTER_WAVE_SECONDS: float = 30.0
const BREACH_NOTICE_SECONDS: float = 2.5
# Temporaire, demandé pour le débogage. Retirer 10.0 après les essais.
const COMBAT_SPEEDS: Array[float] = [1.0,2.0,10.0]
var model = Model.new()
var map_view = MapView.new()
var speed: float = 1.0
var selected: int = -1
var choosing_faction: bool = true
var faction_panel: ColorRect
var faction_label: Label
var faction_buttons: Array[Button] = []
var status_label: Label
var guidance_label: Label
var time_label: Label
var hp_label: Label
var gold_label: Label
var tally_label: Label
var details_label: Label
var inspection_numbers_button: Button
var inspection_numbers_visible: bool = false
var title_label: Label
var version_label: Label
var hint_label: Label
var start_button: Button
var countdown_bar: ProgressBar
var countdown_fill: StyleBoxFlat
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
var specialisation_numbers_button: Button
var specialisation_numbers_visible: bool = false
var pending_slot: int = -1
var pending_instance: int = -1
var sell_button: Button
var buy_buttons: Array[Button] = []
var hovered_purchase: int = -1
var focused_purchase: int = -1
var hovered_upgrade: bool = false
var purchase_quiet_rect: Rect2 = Rect2()
var focused_upgrade: bool = false
var hovered_branch: int = -1
var focused_branch: int = -1
var bonus_panel: ColorRect
var bonus_body: Panel
var bonus_impacts: Array[Label] = []
var bonus_impact_titles: Array[Label] = []
var bonus_impact_scrollers: Array[ScrollContainer] = []
var bonus_contexts: Array[String] = ["","",""]
var bonus_impact_keys: Array[String] = ["","",""]
var bonus_title: Label
var bonus_subtitle: Label
var bonus_names: Array[Label] = []
var bonus_descriptions: Array[Label] = []
var bonus_buttons: Array[Button] = []
var bonus_cards: Array[Panel] = []
var bonus_effects: Array[Label] = []
var bonus_scopes: Array[Label] = []
var bonus_notes: Array[Label] = []
var bonus_detail_buttons: Array[Button] = []
var bonus_details_back: Button
var bonus_detail_index: int = -1
var bonus_view_context: String = ""
var bonus_close: Button
var bonus_summary_button: Button
var overview_open: bool = false
var autoplay_started: bool = false
var countdown_wave: int = -1
var countdown_remaining: float = -1.0
var inspection_pointer := Vector2(-10000,-10000)
var enemy_inspector: Panel
var enemy_name: Label
var enemy_health: Label
var enemy_health_bar: ProgressBar
var enemy_threat: Label
var enemy_reward: Label
var enemy_status: Label
var enemy_prompt: Label
var summary_open: bool = false
var summary_button: Button
var summary_panel: ColorRect
var summary_title: Label
var summary_subtitle: Label
var summary_totals: Label
var summary_rows: Array[ColorRect] = []
var summary_cells: Array = []
var summary_army: Array[Label] = []
var summary_bonuses: Array[Label] = []
var summary_close: Button
var summary_tab: int = 2
var summary_tabs: Array[Button] = []
var summary_wave_content: Control
var summary_performance_content: Control
var summary_essential_content: Control
var summary_key_values: Array[Label] = []
var summary_loss_note: Label
var summary_boss_note: Label
var performance_list: VBoxContainer
var performance_rows: Array[Dictionary] = []
var report_button: Button
var report_status: Label
var report_folder: String = ""
var forecast_panel: Panel
var forecast_title: Label
var forecast_timing: Label
var forecast_rows: Array[Control] = []
var forecast_names: Array[Label] = []
var forecast_details: Array[Label] = []
var forecast_marks: Array[ColorRect] = []
var forecast_reward: Label
var forecast_note: Label
var forecast_wave: int = -1
var forecast_data: Dictionary = {}
var breach_remaining: float = 0.0
var boss_panel: Panel
var boss_name: Label
var boss_health: Label
var boss_bar: ProgressBar
var boss_threat: Label
var keyboard_focus_context: String = ""
var syncing_keyboard_focus: bool = false

func _ready() -> void:
	var isolated: bool = DisplayServer.get_name() == "headless" or "--script" in OS.get_cmdline_args() or "-s" in OS.get_cmdline_args()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): isolated = true
	if not isolated: meta_profile = MetaProfile.new()
	get_window().title = "%s · v%s" % [ProjectSettings.get_setting("application/config/name"),ProjectSettings.get_setting("application/config/version")]
	map_view.model = model
	add_child(map_view)
	_build_interface()
	_update_interface()
	var capture_path: String = ""
	var capture_state: String = "combat"
	var capture_faction: int = 0
	var capture_type: int = 0
	var capture_slot: int = 1
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			capture_path = argument.trim_prefix("--capture=")
		elif argument == "--capture-faction=horde":
			capture_faction = 1
		elif argument.begins_with("--capture-type="):
			capture_type = clampi(int(argument.trim_prefix("--capture-type=")), 0, 5)
		elif argument.begins_with("--capture-slot="):
			capture_slot = clampi(int(argument.trim_prefix("--capture-slot=")), 0, 5)
		elif argument.begins_with("--capture-state="):
			capture_state = argument.trim_prefix("--capture-state=")
	if not capture_path.is_empty():
		print("UI_VERSION=",ProjectSettings.get_setting("application/config/version"))
		if capture_state == "selection":
			meta_profile = MetaProfile.new("")
			if "--capture-home=prepared" in OS.get_cmdline_user_args():
				meta_profile.data.banks[0].resource = 4;meta_profile.data.banks[0].points = 8;meta_profile.data.banks[0].ranks[0] = 5
				meta_profile.data.banks[1].resource = 25;meta_profile.data.banks[1].points = 3;meta_profile.data.banks[1].ranks[0] = 3
			if "--capture-home=maximum" in OS.get_cmdline_user_args():
				for bank in meta_profile.data.banks:
					bank.resource = 100;bank.points = 36;bank.ranks = [5,3,3,1,0,5,3,3,1,0,5,3,3,1,0]
			if "--capture-home=blocked" in OS.get_cmdline_user_args():
				meta_profile.blocked = true;meta_profile.error = "Sauvegarde illisible simulée pour le contrôle."
		if "--capture-meta-rewards" in OS.get_cmdline_user_args():
			meta_profile = MetaProfile.new("")
			meta_profile.data.banks[capture_faction].resource = 6
			if "--capture-meta-pending" in OS.get_cmdline_user_args():
				meta_profile.blocked = true;meta_profile.error = "Échec d’enregistrement simulé pour cette capture."
		if "--capture-meta-loadout" in OS.get_cmdline_user_args():
			meta_profile = MetaProfile.new("")
			meta_profile.data.banks[capture_faction].points = 33
			meta_profile.data.banks[capture_faction].ranks = [5,3,2,1,0,5,3,2,1,0,5,3,2,1,0]
		if capture_state not in ["selection","talents"]:
			_choose_faction((0 if capture_type < 3 else 1) if capture_state in ["upgrade", "specialisation", "specialised"] else capture_faction)
			if "--capture-meta-intermediate" in OS.get_cmdline_user_args(): run_final_map = false
			if capture_state in ["bonus", "campaign", "victory", "overview", "boss_inspection", "summary", "forecast", "forecast_boss"]:
				_prepare_campaign_capture(capture_state)
			if capture_state == "defeat_summary":
				for wave in range(10):
					model.start(); model.advance(10000)
					if model.phase == "defeat": break
					if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
					model.prepare_next_wave()
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
				if capture_state == "upgrade": hovered_upgrade = true
				if capture_state == "specialisation": hovered_branch = 0
			if capture_state not in ["shop", "catalogue", "upgrade", "specialisation", "specialised", "bonus", "campaign", "victory", "overview", "purchase", "boss_inspection", "summary", "defeat_summary", "forecast", "forecast_boss"]:
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
					var enemy: Dictionary = Model.make_enemy(type,type,0.0,model.faction)
					var progress: float = 2.0 + type * 3.5
					enemy.spawn_time = -progress / enemy.speed
					enemy.distance = progress
					model.enemies.append(enemy)
				model.spawned = model.enemies.size()
				model.phase = "combat"
			elif capture_state not in ["preparation", "shop", "upgrade", "specialisation", "specialised", "bonus", "campaign", "victory", "overview", "purchase", "boss_inspection", "summary", "defeat_summary", "forecast", "forecast_boss"]:
				model.start()
				model.advance(1.0 if capture_state == "curse" else 7.5 if capture_state in ["combat","inspection"] else 100.0)
		if capture_state in ["effects","damage_tick"]:
			if capture_state == "damage_tick": capture_type = 5
			model.reset()
			model.select_faction(0 if capture_type < 3 else 1)
			model.gold = 1000 # Fixture visuelle, pas une campagne jouée.
			model.buy(capture_slot, capture_type)
			model.wave = 8
			model.spawn_schedule = Model.Campaign.schedule(8)
			model.start()
			var found: bool = false
			for step in range(6000):
				model.advance(0.01)
				if capture_state == "damage_tick":
					if not model.damage_events.is_empty() and not model.shots.is_empty():
						var event: Dictionary = model.damage_events[-1]
						found = event.hp_after > 0.0 and model.elapsed-event.time < 0.01 and model.elapsed-model.shots[-1].time > 0.5
				elif capture_type == 5 and not model.curses.is_empty(): found = true
				elif not model.shots.is_empty():
					var shot: Dictionary = model.shots[-1]
					found = (capture_type < 2 or not shot.secondary.is_empty()) and model.elapsed-shot.time < 0.01
				if found: break
			assert(found, "La capture doit montrer un effet réellement résolu.")
			if capture_state == "damage_tick":
				model.advance(0.04)
				print("DAMAGE_TICK_VISIBLE=true")
			if "--capture-attack-pose" in OS.get_cmdline_user_args(): model.advance(MapView.ATTACK_POSE_DURATION/2)
			if "--capture-projectile" in OS.get_cmdline_user_args(): model.advance(MapView.PROJECTILE_FLIGHT/2)
			selected = capture_slot
			map_view.selected = capture_slot
			print("ATTACK_FACING=",int(map_view.defender_pose(capture_slot).direction))
		if capture_state == "breach":
			model.reset()
			model.select_faction(capture_faction)
			selected = -1
			map_view.selected = -1
			_start()
			_process(28.0) # Première arrivée réelle sans défenseurs, budget normal.
		if capture_state == "bonus_preview":
			model.reset(); model.select_faction(capture_faction)
			model.gold = 10000 # Fixture pour vérifier six défenseurs, jamais en jeu normal.
			for slot in range(6):
				model.buy(slot,capture_faction*3+slot%3)
				if capture_type == 0:
					model.upgrade(slot); model.upgrade(slot); model.upgrade(slot,slot%2)
			model.fortress_hp = 13
			model.wave = 9
			model.phase = "bonus"
			model.bonus_offer.assign([0,8,11] if capture_type == 0 else [9,10,7])
			if capture_type == 2: model.bonus_offer.assign([1,3,4])
			if capture_type == 3: model.bonus_offer.assign([2,5,6])
		if capture_state == "defender_catalogue":
			model.reset(); model.select_faction(capture_faction); model.gold = 10000
			for slot in range(6):
				model.buy(slot,capture_faction*3+slot%3)
				for level in range([1,2,3,4,4,4][slot]-1): model.upgrade(slot,slot%2 if level == 2 else -1)
			selected = 3; map_view.selected = 3
		if capture_state == "debug_speed":
			model.reset(); model.select_faction(capture_faction)
			model.buy(0,capture_faction*3); model.buy(1,capture_faction*3+1)
			selected = 1; map_view.selected = 1; speed = 10.0
			_start(); _process(0.75)
		if "--capture-synergy-preview" in OS.get_cmdline_user_args():
			model.reset(); pending_slot = -1; pending_instance = -1
			model.select_faction(capture_faction)
			selected = 0; map_view.selected = 0
			if capture_state == "purchase":
				model.buy(1,capture_faction*3+1)
				hovered_purchase = 0
			else:
				model.gold = 10000 # Contrôle de deux branches, pas une campagne jouée.
				model.buy(0,capture_faction*3); model.buy(5,1 if capture_faction == 0 else 5)
				for slot in [0,5]: model.upgrade(slot); model.upgrade(slot)
				model.upgrade(5,1 if capture_faction == 0 else 0)
				_upgrade(); hovered_branch = 0
		set_process(false)
		inspection_numbers_visible = "--capture-inspection-numbers" in OS.get_cmdline_user_args()
		if capture_state in ["finished","forecast","forecast_boss"]: autoplay_started = true
		_update_interface()
		if capture_state in ["summary","defeat_summary"]: _show_run_summary()
		if summary_open and "--capture-performance" in OS.get_cmdline_user_args(): _set_summary_tab(1)
		if summary_open and "--capture-waves" in OS.get_cmdline_user_args(): _set_summary_tab(0)
		if summary_open and "--capture-export-report" in OS.get_cmdline_user_args():
			_export_run_report()
			assert(not report_folder.is_empty(),"L’export de contrôle doit réussir.")
			print("RUN_REPORT_FOLDER=" + report_folder)
		if capture_state in ["inspection","boss_inspection"]:
			var target: Dictionary = {}
			for enemy in model.enemies:
				if capture_state == "inspection" or enemy.type == 7: target = enemy; break
			assert(not target.is_empty(),"La capture d'inspection requiert un ennemi vivant.")
			inspection_pointer = MapView.enemy_bounds(target).get_center()
			_update_enemy_inspector()
		if "--capture-boss-only" in OS.get_cmdline_user_args():
			inspection_pointer = Vector2(30,60)
			_update_enemy_inspector()
			print("BOSS_STATUS_WITHOUT_HOVER=",boss_panel.visible and not enemy_inspector.visible)
		if capture_state in ["specialisation", "specialised"]:
			faction_label.text = "CONTRÔLE PROGRESSION · BUDGET IMPOSÉ"
		if capture_state == "catalogue":
			faction_label.text = "CATALOGUE ENNEMI · CONTRÔLE"
			status_label.text = "Profils de référence\nVue de contrôle"
		if capture_state in ["effects","damage_tick"]: faction_label.text = "CONTRÔLE EFFETS · BUDGET IMPOSÉ"
		if capture_state == "bonus_preview": bonus_title.text = "CONTRÔLE BONUS · BUDGET IMPOSÉ"
		if capture_state == "defender_catalogue": faction_label.text = "DÉFENSEURS · BUDGET IMPOSÉ"
		if "--capture-synergy-preview" in OS.get_cmdline_user_args() and capture_state == "specialisation": faction_label.text = "APERÇU SYNERGIES · BUDGET IMPOSÉ"
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--capture-details="): _open_bonus_details(int(argument.trim_prefix("--capture-details=")))
		if "--capture-specialisation-numbers" in OS.get_cmdline_user_args():
			_toggle_specialisation_numbers()
		if capture_state == "talents":
			meta_profile = MetaProfile.new("")
			meta_profile.data.banks[capture_faction].resource = 36
			meta_profile.data.banks[capture_faction].points = 14
			meta_profile.data.banks[capture_faction].ranks = [5,3,2,1,0,1,0,0,0,0,0,0,0,0,0]
			meta_profile.data.banks[capture_faction].resets = 2
			if "--capture-reset-cap" in OS.get_cmdline_user_args(): meta_profile.data.banks[capture_faction].resets = 20
			if "--capture-meta-no-points" in OS.get_cmdline_user_args():
				meta_profile.data.banks[capture_faction].points = Model.MetaTalents.spent(meta_profile.data.banks[capture_faction].ranks)
				meta_profile.data.banks[capture_faction].resource = 0
			_open_meta(capture_faction)
			if "--capture-meta-preview" in OS.get_cmdline_user_args():
				meta_menu._inspect(5)
				print("META_RANK_PREVIEW=",meta_menu.detail_text.text.contains("Prochain rang"))
			if "--capture-meta-reset" in OS.get_cmdline_user_args():
				meta_menu._request_reset()
				var quote: Dictionary = meta_menu.reset_quote
				print("RESPEC_SNAPSHOT=",JSON.stringify({"isolated":meta_profile.path.is_empty(),"visible":meta_menu.confirm.visible,"price":quote.price,"balance_after":quote.balance_after,"free_before":quote.free_before,"free_after":quote.free_after,"next_price":quote.next_price,"dialog":meta_menu.confirm.dialog_text}))
			print("META_CAPTURE_ISOLATED=",meta_profile.path.is_empty())
			if "--capture-profile-protection" in OS.get_cmdline_user_args():
				var test_path: String = "user://test_packaged_protection_%d.json" % Time.get_ticks_usec()
				var stored = MetaProfile.new(test_path)
				var id: int = stored.begin_run(capture_faction)
				var ok: bool = id > 0 and stored.credit(id,capture_faction,10,true) and stored.buy_point(capture_faction) and stored.allocate(capture_faction,0)
				var sealed: PackedByteArray = FileAccess.get_file_as_bytes(test_path)
				MetaProfile.Codec.cache.clear()
				var reopened = MetaProfile.new(test_path)
				ok = ok and not reopened.blocked and reopened.data.banks[capture_faction].resource == 50 and reopened.data.banks[capture_faction].ranks[0] == 1
				ok = ok and sealed.slice(0,MetaProfile.Codec.MAGIC.length()) == MetaProfile.Codec.MAGIC.to_utf8_buffer()
				meta_profile = MetaProfile.new("");meta_profile.data = reopened.data.duplicate(true);_open_meta(capture_faction)
				for suffix in ["",".bak",".tmp"]:
					if FileAccess.file_exists(test_path+suffix): DirAccess.remove_absolute(test_path+suffix)
				print("PROFILE_PROTECTION=",ok)
		if "--capture-meta-rewards" in OS.get_cmdline_user_args():
			_update_meta_summary()
			print("META_REWARD_SNAPSHOT=",JSON.stringify({"faction":model.faction,"info":_meta_reward_summary(),"banks":[meta_profile.data.banks[0].resource,meta_profile.data.banks[1].resource],"isolated":meta_profile.path.is_empty(),"home":reset_button.visible,"talents":summary_talents_button.visible}))
		if "--capture-meta-loadout" in OS.get_cmdline_user_args():
			_refresh_loadout_label()
			if summary_open: _set_summary_tab(3)
			print("LOADOUT_SNAPSHOT=",JSON.stringify({"faction":model.faction,"points":Model.MetaTalents.spent(model.meta_ranks),"caption":loadout_label.text,"summary":summary_open,"tab":summary_tab,"readonly":not meta_menu.visible,"isolated":meta_profile.path.is_empty()}))
		if "--capture-meta-rewards" in OS.get_cmdline_user_args() or "--capture-meta-loadout" in OS.get_cmdline_user_args():
			faction_label.text = "CONTRÔLE PROGRESSION · BUDGET IMPOSÉ"
		if capture_state == "selection":
			_refresh_home_progress()
			print("HOME_SNAPSHOT=",JSON.stringify({"isolated":meta_profile.path.is_empty(),"resources":[home_resources[0].text,home_resources[1].text],"points":[home_points[0].text,home_points[1].text],"hints":[home_hints[0].text,home_hints[1].text],"hp":[home_hp[0].text,home_hp[1].text],"notice":meta_income.text,"readonly":meta_profile.data.serial == 0 and not meta_menu.visible}))
		if capture_state == "talents":
			var states: Array[String] = []
			for button in meta_menu.nodes: states.append(button.state)
			print("TALENT_STATES_SNAPSHOT=",JSON.stringify({"states":states,"isolated":meta_profile.path.is_empty(),"progress":meta_menu.boards[0].progress}))
		map_view.queue_redraw()
		await RenderingServer.frame_post_draw
		var error: Error = get_viewport().get_texture().get_image().save_png(capture_path)
		print("CAPTURE_RESULT=", error)
		get_tree().quit(error)

func _process(delta: float) -> void:
	meta_retry_remaining = maxf(0.0,meta_retry_remaining-delta)
	breach_remaining = maxf(0.0,breach_remaining-delta)
	if breach_remaining <= 0.0: map_view.breach_feedback = {}
	var was_active: bool = model.active
	var hp_before: int = model.fortress_hp
	var escaped_before: int = model.total_escaped
	model.advance(delta * speed)
	_sync_meta_rewards()
	var passed: int = model.total_escaped-escaped_before
	var lost: int = hp_before-model.fortress_hp
	if passed > 0 and lost > 0:
		breach_remaining = BREACH_NOTICE_SECONDS
		map_view.breach_feedback = {"count":passed,"damage":lost}
	_sync_countdown()
	# Une fin de combat arme le délai complet, même après une image très longue.
	if not was_active and model.phase == "finished" and countdown_remaining >= 0.0 and not _countdown_paused():
		countdown_remaining = maxf(0.0, countdown_remaining - delta)
		if countdown_remaining <= 0.0:
			_start()
	_update_interface()
	map_view.queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		inspection_pointer = event.position
		_update_enemy_inspector()
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
		if wave == 10 and state == "boss_inspection":
			model.advance(5)
			return
		model.advance(300)
		if state == "bonus" and wave == 3: return
		if model.phase == "defeat": return
		if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
		if (state == "forecast" and wave == 8) or (state == "forecast_boss" and wave == 9): return
		if state == "overview" and wave == 9:
			overview_open = true
			return
		if wave < 10: model.prepare_next_wave()

func _selection_blocked() -> bool:
	return meta_menu.visible or choosing_faction or pending_slot >= 0 or model.phase == "bonus" or overview_open or summary_open

func _select_slot(slot: int) -> bool:
	if _selection_blocked() or slot < 0 or slot >= Model.SLOTS.size(): return false
	selected = slot
	map_view.selected = slot
	_update_interface()
	map_view.queue_redraw()
	return true

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if meta_menu.visible:
		if event.keycode == KEY_ESCAPE:
			meta_menu.close();get_viewport().set_input_as_handled()
		return
	if event.ctrl_pressed or event.alt_pressed or event.meta_pressed: return
	if event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE:
		if bonus_panel.visible and bonus_detail_index >= 0:
			_close_bonus_details()
			get_viewport().set_input_as_handled()
			return
		if choosing_faction or model.phase == "bonus": return
		if pending_slot >= 0: _cancel_specialisation()
		elif overview_open: _close_bonuses()
		elif summary_open: _close_run_summary()
		else: return
		get_viewport().set_input_as_handled()
		return
	var codes: Array[int] = [event.physical_keycode,event.keycode]
	for code in codes:
		var slot: int = code-KEY_1 if code >= KEY_1 and code <= KEY_6 else code-KEY_KP_1 if code >= KEY_KP_1 and code <= KEY_KP_6 else -1
		if slot >= 0:
			if _select_slot(slot): get_viewport().set_input_as_handled()
			return

func _unhandled_input(event: InputEvent) -> void:
	if _selection_blocked(): return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var closest: int = -1
		var best: float = 27.0
		for index in range(Model.SLOTS.size()):
			var distance: float = MapView.project(Model.SLOTS[index]).distance_to(event.position)
			if distance < best:
				closest = index
				best = distance
		if closest >= 0:
			_select_slot(closest)

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
	loadout_label = _label(screen,"",Vector2(948,64),Vector2(300,26),12,Color("b6c3b7"))
	loadout_label.mouse_filter = Control.MOUSE_FILTER_STOP
	var side := _panel(screen, Rect2(24, 122, 278, 632))
	_label(side, "DÉFENDRE LE GUÉ", Vector2(22, 20), Vector2(240, 28), 18, Color("e0dbbf"))
	guidance_label = _label(side, "", Vector2(22, 62), Vector2(238, 76), 14, Color("aabbb0"))
	hp_label = _label(side, "", Vector2(22, 144), Vector2(238, 28), 21, Color("e2d5ad"))
	gold_label = _label(side, "", Vector2(22, 184), Vector2(238, 24), 16, Color("cdb47e"))
	status_label = _label(side, "", Vector2(22, 232), Vector2(238, 52), 16, Color("d0dfd1"))
	tally_label = _label(side, "", Vector2(22, 300), Vector2(238, 72), 14, Color("aabbb0"))
	time_label = _label(side, "", Vector2(22, 382), Vector2(238, 24), 14, Color("aabbb0"))
	meta_progress_label = _label(side,"",Vector2(22,406),Vector2(238,18),12,Color("cdb47e"))
	time_label.mouse_filter = Control.MOUSE_FILTER_STOP
	time_label.tooltip_text = "Temps passé dans les combats, hors préparations et choix.\nEn ×2 ou ×10, ce compteur avance plus vite que le temps réel."
	start_button = _button(side, "Lancer la vague 1", Rect2(22, 428, 234, 44), _start)
	start_button.mouse_exited.connect(func(): start_button.tooltip_quiet = false)
	countdown_bar = ProgressBar.new()
	countdown_bar.position = Vector2(22,475)
	countdown_bar.max_value = INTER_WAVE_SECONDS
	countdown_bar.step = 0.0
	countdown_bar.show_percentage = false
	countdown_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	countdown_bar.focus_mode = Control.FOCUS_NONE
	var countdown_background := StyleBoxFlat.new()
	countdown_background.bg_color = Color("253a31")
	countdown_background.set_corner_radius_all(2)
	countdown_fill = StyleBoxFlat.new()
	countdown_fill.set_corner_radius_all(2)
	countdown_bar.add_theme_stylebox_override("background",countdown_background)
	countdown_bar.add_theme_stylebox_override("fill",countdown_fill)
	side.add_child(countdown_bar)
	countdown_bar.size = Vector2(234,4)
	speed_button = _button(side, "Vitesse ×1", Rect2(22, 482, 234, 40), _toggle_speed)
	reset_button = _button(side, "Nouvel essai", Rect2(22, 532, 234, 40), _reset)
	summary_button = _button(side,"Bilan",Rect2(144,532,112,40),_show_run_summary)
	summary_button.tooltip_text = "Voir le résultat de chaque vague et les améliorations de cette partie."
	bonus_summary_button = _button(side, "Bonus acquis · 0/3", Rect2(22, 582, 234, 32), _show_bonuses)
	bonus_summary_button.add_theme_font_size_override("font_size", 13)
	var info := _panel(screen, Rect2(330, 608, 926, 152))
	title_label = _label(info, "CONSTRUIRE · ALLIANCE", Vector2(24, 12), Vector2(690, 24), 13, Color("cdb47e"))
	title_label.clip_text = true
	inspection_numbers_button = _button(info,"Voir les chiffres",Rect2(732,10,170,26),_toggle_inspection_numbers)
	inspection_numbers_button.add_theme_font_size_override("font_size",13)
	inspection_numbers_button.tooltip_text = "Alterner les fiches et aides simplifiées ou chiffrées.\nPour comparer une recrue, survolez ensuite son bouton."
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
	upgrade_button.mouse_entered.connect(_upgrade_hover.bind(true))
	upgrade_button.mouse_exited.connect(_upgrade_hover.bind(false))
	upgrade_button.focus_entered.connect(_upgrade_focus.bind(true))
	upgrade_button.focus_exited.connect(_upgrade_focus.bind(false))
	hint_label = _label(screen, "", Vector2(347, 574), Vector2(890, 24), 13, Color("91a799"))
	hint_label.mouse_filter = Control.MOUSE_FILTER_STOP # Autoriser les infobulles des synergies.
	version_label = _label(screen, "Prototype v%s · Nom de travail · Visuels temporaires" % ProjectSettings.get_setting("application/config/version"), Vector2(34, 776), Vector2(620, 20), 11, Color("718b7d"))
	_label(screen,"Emplacements : 1–6 / pavé numérique",Vector2(946,776),Vector2(310,20),11,Color("91a799"))

	_build_wave_forecast(screen)
	_build_boss_status(screen)
	_build_enemy_inspector(screen)
	_build_faction_selector(screen)
	_build_specialisation_selector(screen)
	_build_bonus_selector(screen)
	_build_run_summary(screen)
	screen.add_child(meta_menu)

func _build_boss_status(screen: Control) -> void:
	boss_panel = _panel(screen,Rect2(340,82,580,72))
	boss_name = _label(boss_panel,"",Vector2(16,6),Vector2(350,24),18,Color("e3c58c"))
	boss_health = _label(boss_panel,"",Vector2(386,8),Vector2(178,22),14,Color("e0e7db"))
	boss_health.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	boss_bar = ProgressBar.new()
	boss_bar.position = Vector2(16,34)
	boss_bar.show_percentage = false
	boss_bar.step = 0.0
	boss_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for key in ["background","fill"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("c58272") if key == "fill" else Color("253a31")
		style.set_corner_radius_all(3)
		boss_bar.add_theme_stylebox_override(key,style)
	boss_panel.add_child(boss_bar)
	boss_bar.size = Vector2(548,8)
	boss_threat = _label(boss_panel,"",Vector2(16,48),Vector2(548,18),13,Color("e0dbbf"))
	boss_panel.visible = false

func _update_boss_status() -> void:
	boss_panel.visible = false
	if choosing_faction or pending_slot >= 0 or overview_open or summary_open or not model.active: return
	for enemy in model.enemies:
		if enemy.type != 7 or enemy.hp <= 0.0: continue
		boss_panel.visible = true
		boss_name.text = "BOSS · " + Model.Enemies.for_profile(enemy.type,model.faction).name
		boss_health.text = "PV : %d / %d" % [ceili(enemy.hp),enemy.max_hp]
		boss_bar.max_value = enemy.max_hp
		boss_bar.value = enemy.hp
		var fatal: bool = enemy.fortress_damage >= model.fortress_hp
		boss_threat.text = "S’il atteint la forteresse, elle perd %d PV%s" % [enemy.fortress_damage," · Défaite" if fatal else ""]
		boss_threat.add_theme_color_override("font_color",Color("ed9989") if fatal else Color("e0dbbf"))
		return

func _build_wave_forecast(screen: Control) -> void:
	forecast_panel = _panel(screen,Rect2(946,96,310,156))
	forecast_title = _label(forecast_panel,"",Vector2(14,10),Vector2(282,24),16,Color("e0dbbf"))
	forecast_timing = _label(forecast_panel,"",Vector2(14,34),Vector2(282,18),12,Color("aabbb0"))
	for index in range(4):
		var row := Control.new()
		row.position = Vector2(14,58+44*index)
		row.size = Vector2(282,40)
		row.mouse_filter = Control.MOUSE_FILTER_STOP
		forecast_panel.add_child(row)
		forecast_rows.append(row)
		var mark := ColorRect.new()
		mark.position = Vector2(0,4)
		mark.size = Vector2(8,30)
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(mark)
		forecast_marks.append(mark)
		forecast_names.append(_label(row,"",Vector2(18,0),Vector2(264,20),14,Color("e0dbbf")))
		forecast_details.append(_label(row,"",Vector2(18,22),Vector2(264,18),12,Color("bbcbbf")))
	forecast_reward = _label(forecast_panel,"",Vector2(14,106),Vector2(282,22),13,Color("cdb47e"))
	forecast_note = _label(forecast_panel,"Survolez les groupes pour les détails.",Vector2(14,128),Vector2(282,18),11,Color("aabbb0"))
	forecast_panel.visible = false

func _update_wave_forecast() -> void:
	forecast_panel.visible = false
	if choosing_faction or pending_slot >= 0 or overview_open or summary_open or model.phase not in ["preparation","finished"]: return
	var number: int = model.wave+1 if model.phase == "finished" else model.wave
	if number < 1 or number > Model.Campaign.WAVES.size(): return
	if forecast_wave != number:
		forecast_wave = number
		forecast_data = Model.wave_forecast(number,model.faction)
	if forecast_data.is_empty(): return
	forecast_panel.visible = true
	forecast_title.text = "Prochaine vague · %d/10" % number
	forecast_timing.text = "%d ennemis · %s" % [forecast_data.total,"Départ manuel" if countdown_remaining < 0 else "Décompte en pause" if _countdown_paused() else "Dans %d s" % ceili(countdown_remaining)]
	for index in range(forecast_rows.size()):
		forecast_rows[index].visible = index < forecast_data.groups.size()
		if index >= forecast_data.groups.size(): continue
		var group: Dictionary = forecast_data.groups[index]
		forecast_marks[index].color = MapView.enemy_color(group.type)
		forecast_names[index].text = "%d × %s%s" % [group.count,group.name," · BOSS" if group.type == 7 else ""]
		var fatal: bool = group.fortress_damage >= model.fortress_hp
		forecast_details[index].text = "%d PV · Forteresse : −%d PV%s" % [group.hp,group.fortress_damage," · Défaite" if fatal else ""]
		forecast_details[index].add_theme_color_override("font_color",Color("ed9989") if fatal else Color("bbcbbf"))
		forecast_rows[index].tooltip_text = "Groupe %d · %d × %s\n%d PV par ennemi\nPremière apparition : %s s après le départ\nDernière apparition : %s s après le départ\n%s\nSi un ennemi atteint la forteresse, elle perd %d PV.\nÉlimination : +%d or par ennemi" % [index+1,group.count,group.name,group.hp,_number(group.first_at),_number(group.last_at),"Ennemi unique." if group.count == 1 else "Un ennemi toutes les %s s." % _number(group.interval),group.fortress_damage,group.reward]
		forecast_rows[index].tooltip_text += "\nHoraires et intervalles à vitesse ×1 ; divisés par 2 en ×2 et par 10 en ×10 debug."
	var footer: int = 62+forecast_data.groups.size()*44
	forecast_reward.position.y = footer
	forecast_reward.text = "Si tous éliminés : +%d or" % forecast_data.income
	forecast_note.position.y = footer+22
	forecast_panel.size.y = footer+50

func _build_run_summary(screen: Control) -> void:
	summary_panel = ColorRect.new()
	summary_panel.color = Color(0.02,0.04,0.035,0.95)
	summary_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(summary_panel)
	var panel: Panel = _panel(summary_panel,Rect2(154,70,972,660))
	summary_title = _label(panel,"",Vector2(24,18),Vector2(376,36),26,Color("e0dbbf"))
	summary_subtitle = _label(panel,"",Vector2(24,64),Vector2(924,48),14,Color("bbcbbf"))
	for index in range(4): summary_tabs.append(_button(panel,["Vagues","Défenseurs","Essentiel","Talents"][index],Rect2(420+132*[1,2,0,3][index],22,120,30),_set_summary_tab.bind(index)))
	summary_wave_content = Control.new()
	summary_wave_content.size = Vector2(972,600)
	summary_wave_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(summary_wave_content)
	var positions: Array[int] = [8,88,206,320,444,564,724]
	var widths: Array[int] = [70,110,108,116,112,152,192]
	var headings: Array[String] = ["Vague","Éliminés","Passés","PV perdus","Or gagné","Combat","Résultat"]
	for column in range(headings.size()):
		_label(summary_wave_content,headings[column],Vector2(24+positions[column],124),Vector2(widths[column],24),13,Color("cdb47e"))
	for index in range(10):
		var row := ColorRect.new()
		row.position = Vector2(24,154+28*index)
		row.size = Vector2(924,28)
		row.mouse_filter = Control.MOUSE_FILTER_STOP
		summary_wave_content.add_child(row)
		summary_rows.append(row)
		var cells: Array[Label] = []
		for column in range(headings.size()):
			cells.append(_label(row,"",Vector2(positions[column],4),Vector2(widths[column],22),13,Color("bbcbbf")))
		summary_cells.append(cells)
	summary_totals = _label(summary_wave_content,"",Vector2(24,444),Vector2(924,26),14,Color("e0dbbf"))
	_label(summary_wave_content,"Défense finale",Vector2(24,478),Vector2(600,22),14,Color("cdb47e"))
	_label(summary_wave_content,"Bonus choisis",Vector2(650,478),Vector2(298,22),14,Color("cdb47e"))
	for index in range(6):
		summary_army.append(_label(summary_wave_content,"",Vector2(24,502+16*index),Vector2(610,18),12,Color("bbcbbf")))
	for index in range(3):
		summary_bonuses.append(_label(summary_wave_content,"",Vector2(650,502+30*index),Vector2(298,28),13,Color("bbcbbf")))
		summary_bonuses[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_performance_content = Control.new()
	summary_performance_content.size = Vector2(972,600)
	summary_performance_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(summary_performance_content)
	var performance_headings: Array[String] = ["Défenseur","Vagues","Attaques","PV retirés","Dont boss"]
	var performance_positions: Array[int] = [0,360,455,550,720]
	for column in range(5): _label(summary_performance_content,performance_headings[column],Vector2(24+performance_positions[column],124),Vector2(350 if column == 0 else 145,24),13,Color("cdb47e"))
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(24,154); scroll.size = Vector2(924,380)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	summary_performance_content.add_child(scroll)
	performance_list = VBoxContainer.new()
	performance_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(performance_list)
	_label(summary_performance_content,"PV réellement retirés aux ennemis, sans compter les dégâts excédentaires.\nLe total inclut le boss. Survolez un défenseur pour le détail de ses attaques.",Vector2(24,544),Vector2(924,46),13,Color("bbcbbf"))
	summary_essential_content = Control.new()
	summary_essential_content.size = Vector2(972,600)
	summary_essential_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(summary_essential_content)
	for index in range(3):
		var card: Panel = _panel(summary_essential_content,Rect2(24+314*index,130,296,108))
		summary_core_cards.append(card)
		summary_core_titles.append(_label(card,["Forteresse","Ennemis passés","Or gagné au combat"][index],Vector2(16,12),Vector2(264,24),16,Color("bbcbbf")))
		summary_key_values.append(_label(card,"",Vector2(16,46),Vector2(264,44),30,Color("e6c987")))
	summary_meta_card = _panel(summary_essential_content,Rect2(726,130,222,108))
	_label(summary_meta_card,"Ressources de faction",Vector2(16,12),Vector2(190,24),16,Color("bbcbbf"))
	summary_meta_value = _label(summary_meta_card,"",Vector2(16,40),Vector2(190,40),30,Color("e6c987"))
	summary_meta_status = _label(summary_meta_card,"",Vector2(16,84),Vector2(190,18),12,Color("bbcbbf"))
	summary_meta_note = _label(summary_essential_content,"",Vector2(24,246),Vector2(924,22),13,Color("cdb47e"))
	_label(summary_essential_content,"Les pertes de la forteresse",Vector2(24,270),Vector2(924,30),20,Color("e0dbbf"))
	summary_loss_note = _label(summary_essential_content,"",Vector2(24,314),Vector2(924,100),18,Color("bbcbbf"))
	_label(summary_essential_content,"Consultez Vagues pour retrouver la défense et les bonus de ces moments.",Vector2(24,426),Vector2(924,26),15,Color("91a799"))
	_label(summary_essential_content,"Boss final",Vector2(24,478),Vector2(924,30),20,Color("e0dbbf"))
	summary_boss_note = _label(summary_essential_content,"",Vector2(24,518),Vector2(924,30),18,Color("bbcbbf"))
	_label(summary_essential_content,"Vagues : déroulement complet · Défenseurs : contributions réelles, unités vendues incluses.",Vector2(24,562),Vector2(924,26),14,Color("91a799"))
	summary_loadout_content = Control.new();summary_loadout_content.size = Vector2(972,600)
	summary_loadout_content.mouse_filter = Control.MOUSE_FILTER_IGNORE;panel.add_child(summary_loadout_content)
	for tree in range(3):
		var card: Panel = _panel(summary_loadout_content,Rect2(24+314*tree,130,296,250))
		summary_loadout_names.append(_label(card,"",Vector2(16,12),Vector2(264,30),21,Color("e0dbbf")))
		summary_loadout_points.append(_label(card,"",Vector2(16,46),Vector2(264,24),14,Color("e6c987")))
		for node in range(4):
			var label: Label = _label(card,"",Vector2(16,82+37*node),Vector2(264,34),14,Color("bbcbbf"))
			label.mouse_filter = Control.MOUSE_FILTER_STOP;summary_loadout_nodes.append(label)
	_label(summary_loadout_content,"Bonus permanents de cette partie",Vector2(24,396),Vector2(924,30),20,Color("e0dbbf"))
	summary_loadout_hp = _label(summary_loadout_content,"",Vector2(24,432),Vector2(924,26),16,Color("e6c987"))
	for unit in range(3): summary_loadout_units.append(_label(summary_loadout_content,"",Vector2(24,470+30*unit),Vector2(924,28),14,Color("bbcbbf")))
	_label(summary_loadout_content,"Lecture seule · Les niveaux, synergies et bonus obtenus pendant la partie s’ajoutent séparément.",Vector2(24,568),Vector2(924,24),13,Color("91a799"))
	report_status = _label(panel,"",Vector2(24,600),Vector2(924,18),12,Color("bbcbbf"))
	report_status.mouse_filter = Control.MOUSE_FILTER_STOP
	report_button = _button(panel,"Exporter le rapport",Rect2(24,622,240,30),_export_run_report)
	report_button.tooltip_text = "Enregistrer localement les vagues, bonus proposés et décisions de cette partie."
	summary_talents_button = _button(panel,"Préparer mes talents",Rect2(284,622,240,30),_summary_to_talents)
	summary_talents_button.tooltip_text = "Revenir au choix de faction et préparer les talents de la prochaine partie."
	summary_close = _button(panel,"Fermer · Échap",Rect2(784,622,164,30),_close_run_summary)
	summary_panel.visible = false

func _set_summary_tab(index: int) -> void:
	if not summary_open or index not in [0,1,2,3] or (index == 3 and not _run_finished()): return
	summary_tab = index
	summary_subtitle.text = "Forteresse : %d/%d PV · %d or restants · %s\nCombat cumulé : %s s simulées, hors préparation et choix ; la vitesse réduit le temps réel." % [model.fortress_hp,model.max_hp,model.gold,"Survolez une ligne pour les unités et bonus de la vague." if index == 0 else "Survolez un défenseur pour ses contributions.",("%.1f" % (model.completed_time+model.elapsed)).replace(".",",")]
	summary_wave_content.visible = index == 0
	summary_performance_content.visible = index == 1
	summary_essential_content.visible = index == 2
	summary_loadout_content.visible = index == 3
	if index == 2:
		summary_subtitle.text = "%s · %d or restants\nCombat : %s s simulées, hors préparation et choix." % ["Dix vagues terminées" if model.phase == "victory" else "Défaite à la vague %d" % model.wave,model.gold,("%.1f" % (model.completed_time+model.elapsed)).replace(".",",")]
	if index == 3:
		summary_subtitle.text = "Talents fixés au départ · %d points actifs · Rangs et bonus permanents, sans les améliorations de cette tentative." % Model.MetaTalents.spent(model.meta_ranks)
	for tab in range(summary_tabs.size()): summary_tabs[tab].disabled = index == tab
	summary_tabs[3].visible = _run_finished()

func _populate_essential_summary() -> void:
	_update_meta_summary()
	summary_key_values[0].text = "%d / %d PV" % [model.fortress_hp,model.max_hp]
	summary_key_values[1].text = str(model.total_escaped)
	summary_key_values[2].text = "%d or" % model.total_income
	var lost: int = 0
	var first: int = -1
	var largest: int = 0
	var waves: Array[String] = []
	for record in model.wave_history:
		lost += record.hp_lost
		if record.hp_lost > 0 and first < 0: first = record.wave
		if record.hp_lost > largest:
			largest = record.hp_lost; waves.clear()
		if record.hp_lost == largest and largest > 0: waves.append(str(record.wave))
	if model.wave_history.is_empty(): summary_loss_note.text = "Aucun relevé de vague disponible."
	elif lost == 0: summary_loss_note.text = "Aucun PV perdu dans les vagues relevées."
	else:
		summary_loss_note.text = "%d PV perdus au combat.\nPremière perte : vague %d.\nPlus forte perte : %s (%d PV%s)." % [lost,first,("vagues " if waves.size() > 1 else "vague ")+", ".join(waves),largest," chacune" if waves.size() > 1 else ""]
	var boss: Dictionary = RunReport.boss_encounter(model)
	summary_boss_note.text = {"not_reached":"Vague 10 non atteinte.","not_spawned":"Pas encore apparu à la fin de la partie.","killed":"Boss éliminé.","escaped":"Le boss a atteint la forteresse.","present":"Encore en chemin à la fin de la partie."}.get(boss.status,"Issue non déterminée par le relevé.")

func _populate_performance() -> void:
	performance_rows = RunReport.performance(model)
	for child in performance_list.get_children():
		performance_list.remove_child(child); child.queue_free()
	if performance_rows.is_empty():
		_label(performance_list,"Aucun défenseur n’a participé à une vague.",Vector2.ZERO,Vector2(900,44),14,Color("bbcbbf"))
	for data in performance_rows:
		var row := ColorRect.new()
		row.custom_minimum_size = Vector2(900,56)
		row.color = Color(0.4,0.6,0.5,0.07)
		row.mouse_filter = Control.MOUSE_FILTER_STOP
		performance_list.add_child(row)
		var total: float = data.direct_hp+data.secondary_hp+data.curse_hp
		var values: Array[String] = ["E%d · %s\nNiveau %d · %s" % [data.slot+1,data.name,data.level,"Présent à la fin" if data.present_at_end else "Vendu"],str(data.waves.size()),str(data.attacks),_number(total),_number(data.boss_hp)]
		for column in range(5): _label(row,values[column],Vector2([0,360,455,550,720][column],8),Vector2(350 if column == 0 else 145,42),13,Color("bbcbbf"))
		var detail: Array[String] = [data.name,"Vagues jouées : " + str(data.waves),"Attaques principales : %d · %s PV retirés" % [data.attacks,_number(data.direct_hp)]]
		if data.type in [2,3,4]: detail.append("%s : %d impacts · %s PV retirés" % ["Rebonds" if data.type == 3 else "Explosions",data.secondary_hits,_number(data.secondary_hp)])
		if data.type == 5: detail.append("Malédiction : %d déclenchements · %s PV retirés" % [data.curse_ticks,_number(data.curse_hp)])
		if data.level == 4: detail.append(Model.stats_for(data.type,4,data.branch).branch_name)
		detail.append("Tirs simultanés : les PV retirés sont répartis proportionnellement aux dégâts.\nCes mesures ne suffisent pas à juger les synergies ou l’utilité d’une unité.")
		row.tooltip_text = "\n".join(detail)

func _export_run_report() -> void:
	if not summary_open or model.phase not in ["victory","defeat"]: return
	if not report_folder.is_empty():
		var error: int = OS.shell_open(report_folder)
		if error != OK: report_status.text = "Ouverture impossible. Survolez ce message pour lire le chemin du dossier."
		return
	var result: Dictionary = RunReport.export_local(model)
	if result.ok:
		report_folder = result.folder
		report_status.text = "Rapport enregistré sur ce PC : rapport.md et rapport.json."
		report_status.tooltip_text = report_folder
		report_button.text = "Ouvrir le dossier du rapport"
		report_button.tooltip_text = "Ouvrir le dossier local contenant rapport.md et rapport.json."
	else:
		report_status.text = "Export impossible. Survolez ce message pour lire le détail."
		report_status.tooltip_text = result.error

func _show_run_summary() -> void:
	if model.phase not in ["victory","defeat"] or overview_open or pending_slot >= 0: return
	_sync_meta_rewards(true)
	summary_open = true
	_populate_run_summary()
	_populate_performance()
	_populate_essential_summary()
	_populate_loadout_summary()
	if summary_tab == 3 and not _run_finished(): summary_tab = 2
	_set_summary_tab(summary_tab)
	_update_interface()
	summary_close.grab_focus()

func _refresh_loadout_label() -> void:
	loadout_label.visible = not choosing_faction
	var key: String = JSON.stringify([model.faction,model.meta_ranks])
	if key == loadout_key: return
	loadout_key = key
	var data: Dictionary = Model.MetaTalents.loadout_summary(model.faction,model.meta_ranks)
	if data.is_empty(): loadout_label.text = "Talents : configuration indisponible";loadout_label.tooltip_text = "";return
	loadout_label.text = "Aucun talent permanent actif" if data.points == 0 else "Talents actifs · %d points (survol)" % data.points
	var lines: Array[String] = ["Talents fixés au départ · Lecture seule"]
	for tree in data.trees: lines.append("%s : %d point%s" % [tree.name,tree.points,"s" if tree.points > 1 else ""])
	lines.append("PV supplémentaires au départ : +%d" % data.hp)
	for unit in data.units: lines.append("%s : %s" % [Model.ROSTER[unit.type].get("short_name",Model.ROSTER[unit.type].name),Model.MetaTalents.bonus_line(unit)])
	lines.append("Les bonus de cette tentative sont indiqués séparément dans Bonus acquis.")
	loadout_label.tooltip_text = "\n".join(lines)

func _populate_loadout_summary() -> void:
	var data: Dictionary = Model.MetaTalents.loadout_summary(model.faction,model.meta_ranks)
	if data.is_empty(): return
	for tree in range(3):
		var info: Dictionary = data.trees[tree]
		summary_loadout_names[tree].text = info.name
		summary_loadout_points[tree].text = "%d point%s actif%s" % [info.points,"s" if info.points > 1 else "","s" if info.points > 1 else ""]
		for index in range(4):
			var row: Label = summary_loadout_nodes[tree*4+index]
			row.visible = index < info.nodes.size() or (index == 0 and info.nodes.is_empty())
			row.tooltip_text = ""
			if index < info.nodes.size():
				var node: Dictionary = info.nodes[index]
				row.text = "%s · %d/%d" % [node.name,node.rank,node.maximum]
				row.tooltip_text = node.description
			elif index == 0: row.text = "Aucun point dans cet arbre."
			else: row.text = ""
	summary_loadout_hp.text = "Forteresse au départ : %d PV (+%d par les talents)" % [Model.INITIAL_HP+data.hp,data.hp]
	for index in range(3):
		var unit: Dictionary = data.units[index]
		summary_loadout_units[index].text = "%s · %s" % [Model.ROSTER[unit.type].name,Model.MetaTalents.bonus_line(unit)]

func _close_run_summary() -> void:
	summary_open = false
	_update_interface()
	if summary_button.visible: summary_button.grab_focus()

func _army_description(army: Array) -> Array[String]:
	var lines: Array[String] = []
	for unit in army:
		var text: String = "E%d · %s · Niveau %d" % [unit.slot+1,Model.ROSTER[unit.type].name,unit.level]
		if unit.level == 4: text += " · " + Model.stats_for(unit.type,4,unit.branch).branch_name
		lines.append(text)
	return lines

func _populate_run_summary() -> void:
	summary_title.text = ("Carte terminée" if model.phase == "victory" and not _run_finished() else "Victoire" if model.phase == "victory" else "Défaite") + " · " + ("Alliance" if model.faction == 0 else "Horde")
	summary_subtitle.text = "Forteresse : %d/%d PV · %d or restants · Survolez une ligne pour les unités et bonus de la vague.\nCombat cumulé : %s s simulées, hors préparation et choix ; la vitesse réduit le temps réel." % [model.fortress_hp,model.max_hp,model.gold,("%.1f" % (model.completed_time+model.elapsed)).replace(".",",")]
	var lost: int = 0
	for index in range(10):
		var record: Dictionary = {}
		for item in model.wave_history:
			if item.wave == index+1: record = item; break
		var values: Array[String] = [str(index+1),"—","—","—","—","—","Non relevée" if index+1 <= model.wave else "Non jouée"]
		summary_rows[index].tooltip_text = "Cette vague n’a pas de relevé." if index+1 <= model.wave else "La partie s’est terminée avant cette vague."
		summary_rows[index].color = Color(0.4,0.6,0.5,0.07 if index%2 == 0 else 0.02)
		if not record.is_empty():
			lost += record.hp_lost
			values = [str(record.wave),str(record.killed),str(record.escaped),str(record.hp_lost),str(record.income),("%.1f s" % record.seconds).replace(".",","),"Défaite" if record.result == "defeat" else "Terminée"]
			if record.result == "defeat": summary_rows[index].color = Color(0.8,0.3,0.2,0.15)
			var names: Array[String] = []
			for code in record.bonuses: names.append(Model.Campaign.BONUSES[code].name)
			var army: Array[String] = _army_description(record.army)
			summary_rows[index].tooltip_text = "Vague %d : %d ennemis prévus, %d apparus, %d encore en chemin à la fin.\nForteresse : %d → %d PV\nDéfense au départ :\n%s\nBonus actifs : %s" % [record.wave,record.planned,record.spawned,record.remaining,record.hp_before,record.hp_after,"\n".join(army) if not army.is_empty() else "Aucun défenseur"," · ".join(names) if not names.is_empty() else "Aucun"]
			if record.wave == 10: summary_rows[index].tooltip_text += "\n\n" + RunReport.boss_description(RunReport.boss_encounter(model))
		for column in range(values.size()): summary_cells[index][column].text = values[column]
	summary_totals.text = "Total : %d éliminés · %d passés · %d PV perdus au combat · %d or gagnés au combat" % [model.total_killed,model.total_escaped,lost,model.total_income]
	var army: Array[Dictionary] = []
	for slot in range(model.defenders.size()):
		if not model.defenders[slot].is_empty():
			var unit: Dictionary = model.defenders[slot].duplicate(true)
			unit.slot = slot
			army.append(unit)
	var lines: Array[String] = _army_description(army)
	for index in range(summary_army.size()): summary_army[index].text = lines[index] if index < lines.size() else "Aucun défenseur" if index == 0 else ""
	for index in range(summary_bonuses.size()):
		summary_bonuses[index].text = Model.Campaign.BONUSES[model.bonuses[index]].name if index < model.bonuses.size() else "Aucun bonus" if index == 0 else ""

func _build_enemy_inspector(screen: Control) -> void:
	enemy_prompt = _label(screen,"Survolez un ennemi pour l’inspecter.",Vector2(946,96),Vector2(310,22),12,Color("aabbb0"))
	enemy_prompt.visible = false
	enemy_inspector = _panel(screen,Rect2(946,96,310,190))
	enemy_name = _label(enemy_inspector,"",Vector2(14,10),Vector2(282,24),17,Color("e0dbbf"))
	enemy_health = _label(enemy_inspector,"",Vector2(14,38),Vector2(282,22),15,Color("e0e7db"))
	enemy_health_bar = ProgressBar.new()
	enemy_health_bar.position = Vector2(14,66)
	enemy_health_bar.show_percentage = false
	enemy_health_bar.step = 0.0
	enemy_health_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for key in ["background","fill"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("a8c779") if key == "fill" else Color("253a31")
		style.set_corner_radius_all(3)
		enemy_health_bar.add_theme_stylebox_override(key,style)
	enemy_inspector.add_child(enemy_health_bar)
	enemy_health_bar.size = Vector2(282,8) # Redimensionner après application des styles, sans la hauteur du thème par défaut.
	enemy_threat = _label(enemy_inspector,"",Vector2(14,84),Vector2(282,44),14,Color("e0dbbf"))
	enemy_reward = _label(enemy_inspector,"",Vector2(14,132),Vector2(282,22),14,Color("cdb47e"))
	enemy_status = _label(enemy_inspector,"",Vector2(14,160),Vector2(282,18),12,Color("aabbb0"))
	enemy_inspector.visible = false

func _update_enemy_inspector() -> void:
	if enemy_inspector == null: return
	enemy_inspector.visible = false
	enemy_prompt.visible = false
	map_view.inspected_enemy_id = -1
	if choosing_faction or pending_slot >= 0 or overview_open or not model.active: return
	enemy_prompt.visible = true
	var id: int = map_view.enemy_at(inspection_pointer)
	if id < 0: return
	for enemy in model.enemies:
		if enemy.id != id: continue
		map_view.inspected_enemy_id = id
		enemy_inspector.visible = true
		enemy_prompt.visible = false
		enemy_name.text = Model.Enemies.for_profile(enemy.type,model.faction).name + (" · BOSS" if enemy.type == 7 else "")
		enemy_health.text = "PV : %d / %d" % [ceili(enemy.hp),enemy.max_hp]
		enemy_health_bar.max_value = enemy.max_hp
		enemy_health_bar.value = enemy.hp
		var fatal: bool = enemy.fortress_damage >= model.fortress_hp
		enemy_threat.text = "S’il atteint la forteresse,\nelle perd %d PV%s" % [enemy.fortress_damage," · Défaite" if fatal else ""]
		enemy_threat.add_theme_color_override("font_color",Color("ed9989") if fatal else Color("e0dbbf"))
		enemy_reward.text = "Éliminé : vous gagnez %d or." % enemy.reward
		var cursed: bool = false
		for curse in model.curses:
			if curse.enemy_id == id: cursed = true; break
		var origin: String = Model.Enemies.origin_label(Model.Enemies.for_profile(enemy.type,model.faction).origin)
		enemy_status.text = origin + (" · Malédiction active" if cursed else " · Lecture sans pause")
		enemy_status.add_theme_color_override("font_color",Color("d3afe4") if cursed else Color("aabbb0"))
		return

func _build_faction_selector(screen: Control) -> void:
	faction_panel = ColorRect.new()
	faction_panel.color = Color(0.02, 0.04, 0.035, 0.94)
	faction_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(faction_panel)
	var panel: Panel = _panel(faction_panel, Rect2(240, 130, 800, 540))
	_label(panel, "Choisissez votre faction", Vector2(30, 28), Vector2(740, 42), 28, Color("e0dbbf"))
	_label(panel, "Chaque camp possède trois défenseurs pour les dix vagues.", Vector2(30, 88), Vector2(740, 30), 16, Color("aabbb0"))
	faction_buttons.append(_button(panel, "Alliance des Royaumes", Rect2(30, 138, 350, 52), _choose_faction.bind(0)))
	faction_buttons.append(_button(panel, "Horde des Cendres", Rect2(420, 138, 350, 52), _choose_faction.bind(1)))
	_label(panel, "Archer, arbalétrier et mage.\nPrécision et attaque de groupe.", Vector2(30, 204), Vector2(350, 52), 15, Color("bbcbbf"))
	_label(panel, "Lanceur de haches, sapeur et chaman.\nRebonds, explosifs et malédictions.", Vector2(420, 204), Vector2(350, 52), 15, Color("bbcbbf"))
	for camp in range(2):
		var x: float = 30+390*camp
		home_resources.append(_label(panel,"",Vector2(x,268),Vector2(350,26),17,Color("e6c987")))
		home_points.append(_label(panel,"",Vector2(x,300),Vector2(350,26),15,Color("bbcbbf")))
		home_hp.append(_label(panel,"",Vector2(x,330),Vector2(350,24),14,Color("bbcbbf")))
		home_hints.append(_label(panel,"",Vector2(x,362),Vector2(350,44),13,Color("aabbb0")))
		meta_buttons.append(_button(panel,"Préparer les talents",Rect2(x,412,350,38),_open_meta.bind(camp)))
		meta_buttons[-1].disabled = meta_profile == null
	meta_income = _label(panel,"",Vector2(30,468),Vector2(740,26),13,Color("cdb47e"))
	meta_income.mouse_filter = Control.MOUSE_FILTER_STOP
	_label(panel,"La Vallée du Gué · 150 or · Gains versés en fin de partie · Barème d’essai",Vector2(30,504),Vector2(740,24),13,Color("aabbb0"))

func _refresh_home_progress() -> void:
	if not choosing_faction: return
	var key: String = "none" if meta_profile == null else JSON.stringify([meta_profile.data.banks,meta_profile.blocked,meta_profile.error])
	if key == home_progress_key: return
	home_progress_key = key
	for camp in range(2):
		meta_buttons[camp].disabled = meta_profile == null
		meta_buttons[camp].text = "Préparer les talents"
		meta_buttons[camp].tooltip_text = "Acheter des points et les affecter aux arbres de cette faction avant de partir."
		if meta_profile == null:
			home_resources[camp].text = "Ressources : indisponibles"
			home_points[camp].text = "Talents non chargés"
			home_hp[camp].text = ""
			home_hints[camp].text = "Progression permanente indisponible."
			continue
		if meta_profile.blocked:
			home_resources[camp].text = "Ressources : à vérifier"
			home_points[camp].text = "Talents : à vérifier"
			home_hp[camp].text = ""
			home_hints[camp].text = "Consultez les talents pour le détail."
			continue
		var bank: Dictionary = meta_profile.data.banks[camp]
		var active: int = Model.MetaTalents.spent(bank.ranks)
		var free: int = int(bank.points)-active
		home_resources[camp].text = "%d ressource%s %s" % [bank.resource,"s" if bank.resource != 1 else "","Alliance" if camp == 0 else "Horde"]
		home_points[camp].text = "%d point%s actif%s · %d à placer" % [active,"s" if active != 1 else "","s" if active != 1 else "",free]
		home_hp[camp].text = "Forteresse au départ : %d PV" % [Model.INITIAL_HP+Model.MetaTalents.extra_hp(camp,bank.ranks)]
		var affordable: int = mini(int(bank.resource)/Model.MetaTalents.POINT_PRICE,Model.MetaTalents.MAX_POINTS-int(bank.points))
		if free > 0:
			meta_buttons[camp].text = "Talents · %d point%s à placer" % [free,"s" if free > 1 else ""]
			home_hints[camp].text = "Points déjà achetés : affectez-les avant de partir."
		elif int(bank.points) >= Model.MetaTalents.MAX_POINTS:
			home_hints[camp].text = "Tous les points ont été achetés."
		elif affordable > 0:
			home_hints[camp].text = "Vous pouvez acheter %d point%s de talent." % [affordable,"s" if affordable > 1 else ""]
		else:
			home_hints[camp].text = "Prochain point : encore %d ressources." % (Model.MetaTalents.POINT_PRICE-int(bank.resource))
	meta_income.text = "Chaque faction conserve ses ressources et ses talents."
	meta_income.tooltip_text = "Les points d’une faction ne peuvent pas être utilisés par l’autre."
	if meta_profile == null: meta_income.text = "Progression permanente indisponible."
	elif meta_profile.blocked:
		meta_income.text = "Sauvegarde à vérifier · Consultez les talents pour le détail."
		meta_income.tooltip_text = meta_profile.error

func _open_meta(camp: int) -> void:
	if choosing_faction and meta_profile != null: meta_menu.open(meta_profile,camp)

func _sync_meta_rewards(force: bool = false) -> bool:
	if meta_profile == null or choosing_faction: return false
	_record_provisional_rewards()
	if not _run_finished(): return false
	if not force and meta_retry_remaining > 0.0: return false
	if meta_run_id <= 0:
		meta_run_id = meta_profile.begin_run(model.faction)
		if meta_run_id <= 0:
			meta_retry_remaining = 2.0;return false
	var completed: int = 0
	for record in model.wave_history:
		if record.result == "cleared": completed = maxi(completed,int(record.wave))
	var before: int = int(meta_profile.data.banks[model.faction].resource)
	var previous: int = _previous_map_rewards()
	if meta_profile.credit(meta_run_id,model.faction,completed,model.phase == "victory",previous):
		meta_run_earned += int(meta_profile.data.banks[model.faction].resource)-before
		meta_retry_remaining = 0.0;return true
	meta_retry_remaining = 2.0
	return false

func _run_finished() -> bool:
	return not choosing_faction and (model.phase == "defeat" or (model.phase == "victory" and run_final_map))

func _cleared_wave_count() -> int:
	var completed: int = 0
	for record in model.wave_history:
		if record.result == "cleared": completed = maxi(completed,int(record.wave))
	return completed

func _record_provisional_rewards() -> void:
	if not choosing_faction: run_map_rewards[run_map_index] = MetaProfile.resource_total(_cleared_wave_count())

func _previous_map_rewards() -> int:
	var total: int = 0
	for index in run_map_rewards:
		if index != run_map_index: total += int(run_map_rewards[index])
	return total

func _meta_reward_summary() -> Dictionary:
	if meta_profile == null: return {}
	var completed: int = 0
	for record in model.wave_history:
		if record.result == "cleared": completed = maxi(completed,int(record.wave))
	var waves: int = MetaProfile.resource_total(completed)+_previous_map_rewards()
	var bonus: int = MetaProfile.WIN_REWARD if _run_finished() and model.phase == "victory" and completed == 10 else 0
	var eligible: bool = meta_run_id > 0 and meta_profile.data.run.id == meta_run_id and meta_profile.data.run.faction == model.faction
	var settled: bool = eligible and meta_profile.data.run.get("settled",false)
	var saved: int = MetaProfile.resource_total(int(meta_profile.data.run.completed),meta_profile.data.run.victory)+int(meta_profile.data.run.get("previous_maps",0)) if settled else 0
	var bank: Dictionary = meta_profile.data.banks[model.faction]
	return {"waves":waves,"bonus":bonus,"expected":waves+bonus,"saved":saved,"pending":maxi(0,waves+bonus-saved),"finished":_run_finished(),"ready":_run_finished() and settled and saved == waves+bonus,"balance":int(bank.resource),"affordable":mini(int(bank.resource)/MetaProfile.Talents.POINT_PRICE,maxi(0,MetaProfile.Talents.MAX_POINTS-int(bank.points))),"at_cap":bank.points >= MetaProfile.Talents.MAX_POINTS}

func _update_meta_summary() -> void:
	var visible_meta: bool = meta_profile != null
	summary_meta_card.visible = visible_meta;summary_meta_note.visible = visible_meta
	summary_talents_button.visible = visible_meta
	for index in range(3):
		summary_core_cards[index].position.x = 24+(234 if visible_meta else 314)*index
		summary_core_cards[index].size.x = 222 if visible_meta else 296
		summary_core_titles[index].size.x = 190 if visible_meta else 264
		summary_key_values[index].size.x = 190 if visible_meta else 264
	if not visible_meta: return
	var info: Dictionary = _meta_reward_summary()
	var camp: String = "Alliance" if model.faction == 0 else "Horde"
	if not info.finished:
		summary_meta_value.text = "+%d" % info.expected
		summary_meta_status.text = "Provisoires · Partie en cours"
		summary_meta_note.text = "Ces ressources seront versées après la victoire finale ou la défaite, pas entre les cartes."
		summary_talents_button.visible = false
		return
	summary_meta_value.text = "+%d" % info.saved if info.ready else "%d / %d" % [info.saved,info.expected]
	summary_meta_status.text = "Sauvegardées · "+camp if info.ready else "Enregistrement en attente"
	summary_meta_status.add_theme_color_override("font_color",Color("bbcbbf") if info.ready else Color("ef9b89"))
	if info.ready:
		var spending: String = "Tous les points actuels sont achetés" if info.at_cap else "%d point%s achetable%s" % [info.affordable,"s" if info.affordable > 1 else "","s" if info.affordable > 1 else ""] if info.affordable > 0 else "Encore %d ressources pour un point" % (MetaProfile.Talents.POINT_PRICE-info.balance)
		summary_meta_note.text = "Vagues : %d · Victoire : %d · Solde %s : %d · %s" % [info.waves,info.bonus,camp,info.balance,spending]
	else:
		summary_meta_note.text = "%d ressources en attente · Réessayez la sauvegarde avant de préparer vos talents." % info.pending
	summary_meta_note.tooltip_text = meta_profile.error
	summary_meta_note.mouse_filter = Control.MOUSE_FILTER_STOP
	summary_talents_button.text = "Préparer mes talents" if info.ready else "Réessayer la sauvegarde"
	summary_talents_button.disabled = meta_profile.blocked

func _summary_to_talents() -> void:
	if not summary_open or meta_profile == null or not _run_finished(): return
	var ready_before: bool = _meta_reward_summary().ready
	if not _sync_meta_rewards(true):
		_update_meta_summary();return
	_update_meta_summary()
	if not ready_before: return # Le premier clic de reprise confirme l'enregistrement ; le suivant quitte le bilan.
	var camp: int = model.faction
	_close_run_summary();_reset();_open_meta(camp)

func _choose_faction(choice: int) -> void:
	if meta_menu.visible: return
	forecast_wave = -1
	if choosing_faction and meta_profile != null and choice in [0,1]:
		model.meta_ranks = meta_profile.data.banks[choice].ranks.duplicate()
	if choosing_faction and model.select_faction(choice):
		meta_run_earned = 0
		run_final_map = true;run_map_index = 0;run_map_rewards.clear()
		if meta_profile != null: meta_run_id = meta_profile.begin_run(choice)
		meta_retry_remaining = 2.0 if meta_run_id <= 0 and meta_profile != null else 0.0
		choosing_faction = false
		_update_interface()

func _build_specialisation_selector(screen: Control) -> void:
	specialisation_panel = ColorRect.new()
	specialisation_panel.color = Color(0.02, 0.04, 0.035, 0.28)
	specialisation_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(specialisation_panel)
	var panel: Panel = _panel(specialisation_panel, Rect2(24, 104, 398, 654))
	specialisation_title = _label(panel, "Spécialisation", Vector2(18, 14), Vector2(362, 32), 22, Color("e0dbbf"))
	specialisation_cost = _label(panel, "", Vector2(18, 52), Vector2(362, 62), 13, Color("cdb47e"))
	for branch in range(2):
		var y: int = 126 + branch * 224
		_panel(panel,Rect2(10,y-10,378,212))
		specialisation_names.append(_label(panel, "", Vector2(18, y), Vector2(362, 24), 16, Color("e0dbbf")))
		specialisation_descriptions.append(_label(panel, "", Vector2(18, y+28), Vector2(362, 36), 13, Color("aabbb0")))
		specialisation_descriptions[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		specialisation_stats.append(_label(panel, "", Vector2(18, y+70), Vector2(362, 96), 13, Color("bbcbbf")))
		specialisation_buttons.append(_button(panel, "Choisir cette spécialisation", Rect2(18, y+180, 362, 32), _choose_branch.bind(branch)))
		specialisation_buttons[-1].add_theme_font_size_override("font_size",14)
		specialisation_buttons[-1].mouse_entered.connect(_branch_hover.bind(branch,true))
		specialisation_buttons[-1].mouse_exited.connect(_branch_hover.bind(branch,false))
		specialisation_buttons[-1].focus_entered.connect(_branch_focus.bind(branch,true))
		specialisation_buttons[-1].focus_exited.connect(_branch_focus.bind(branch,false))
	specialisation_numbers_button = _button(panel,"Voir les chiffres",Rect2(18,568,362,28),_toggle_specialisation_numbers)
	specialisation_numbers_button.add_theme_font_size_override("font_size",14)
	specialisation_cancel = _button(panel, "Annuler · Échap", Rect2(117, 604, 164, 32), _cancel_specialisation)

func _upgrade() -> void:
	if choosing_faction or overview_open or pending_slot >= 0 or selected < 0 or model.defenders[selected].is_empty():
		return
	var defender: Dictionary = model.defenders[selected]
	if defender.level == 3:
		if not model.upgrade_error(selected, 0).is_empty():
			return
		pending_slot = selected
		pending_instance = defender.instance_id
		specialisation_numbers_visible = false
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
	specialisation_cost.text = "%s\nSpécialisation : %d or" % [Model.ROSTER[type].name,model.upgrade_cost(pending_slot)]
	if specialisation_numbers_visible: specialisation_cost.text += "\nTotal investi après amélioration : %d or" % (defender.paid+model.upgrade_cost(pending_slot))
	specialisation_numbers_button.text = "Masquer les chiffres" if specialisation_numbers_visible else "Voir les chiffres"
	var current: Dictionary = model.get_stats(pending_slot)
	for branch in range(2):
		var stats: Dictionary = model.get_stats(pending_slot, branch)
		specialisation_names[branch].text = ("A · " if branch == 0 else "B · ") + stats.branch_name
		specialisation_names[branch].add_theme_font_size_override("font_size",16 if specialisation_numbers_visible else 17)
		specialisation_descriptions[branch].text = _specialisation_pitch(type,branch)
		specialisation_descriptions[branch].position.y = 154+branch*224 if specialisation_numbers_visible else 166+branch*224
		specialisation_descriptions[branch].size.y = 36 if specialisation_numbers_visible else 100
		specialisation_descriptions[branch].add_theme_font_size_override("font_size",13 if specialisation_numbers_visible else 18)
		specialisation_stats[branch].visible = specialisation_numbers_visible
		specialisation_stats[branch].text = _comparison_text(current,stats,true)
		if type in [2, 3, 4]:
			specialisation_stats[branch].text += "\n%s : %s → %s dégâts\nCibles : %d → %d · %s : <%s → <%s" % ["Rebonds" if type == 3 else "Explosion",_number(current.secondary_damage),_number(stats.secondary_damage),current.secondary_cap,stats.secondary_cap,"Distance" if type == 3 else "Rayon",_number(current.radius),_number(stats.radius)]
		elif type == 5:
			specialisation_stats[branch].text += "\nMalédiction : %s → %s dégâts\nÀ +1 s puis +2 s, même hors portée." % [_number(current.curse_damage),_number(stats.curse_damage)]
		specialisation_buttons[branch].disabled = not model.upgrade_error(pending_slot, branch).is_empty()
		var candidate: Dictionary = defender.duplicate(true)
		candidate.level = 4; candidate.branch = branch
		specialisation_buttons[branch].tooltip_text = _preview_synergy_tooltip(pending_slot,candidate)
		specialisation_buttons[branch].text = "Choisir · %d or" % model.upgrade_cost(pending_slot)

func _toggle_specialisation_numbers() -> void:
	if pending_slot < 0: return
	var unit: Dictionary = model.defenders[pending_slot]
	if unit.is_empty() or unit.instance_id != pending_instance:
		_cancel_specialisation()
		return
	specialisation_numbers_visible = not specialisation_numbers_visible
	_update_specialisation_choices()
	_update_interface()

func _specialisation_pitch(type: int, branch: int) -> String:
	return [
		"Des tirs puissants et lointains, mais moins fréquents.",
		"Des volées rapides, avec une portée plus courte.",
		"De très gros impacts, plus de temps entre les tirs.",
		"Une très longue portée pour surveiller le chemin.",
		"Un impact puissant, une explosion plus faible.",
		"Une grande explosion : jusqu’à 4 ennemis autour de la cible.",
		"Un gros premier impact, un rebond plus faible.",
		"La hache ricoche jusqu’à 3 fois sur des ennemis différents.",
		"Un impact puissant et jusqu’à 3 victimes autour.",
		"Une large explosion : jusqu’à 5 victimes autour.",
		"Un gros coup immédiat, une malédiction plus légère.",
		"Une forte malédiction, au détriment du coup initial."
	][type*2+branch]

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
	specialisation_numbers_visible = false
	hovered_branch = -1
	focused_branch = -1
	hovered_upgrade = false
	focused_upgrade = false
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

func _recruit_role(type: int) -> String:
	return ["Tirs rapides sur une cible", "Longue portée, tirs espacés", "Explosion autour de la cible", "Rebonds entre ennemis proches", "Explosion contre les groupes", "Dégâts immédiats puis malédiction"][type]

func _recruit_effect(stats: Dictionary, type: int) -> String:
	if type in [2,4]:
		return "Explosion : %s dégâts sur jusqu’à %d autres ennemis proches." % [_number(stats.secondary_damage), stats.secondary_cap]
	if type == 3:
		return "Rebond : %s dégâts sur jusqu’à %d autre ennemi proche." % [_number(stats.secondary_damage), stats.secondary_cap]
	if type == 5:
		return "Malédiction : %s dégâts après 1 s, puis %s après 2 s, même hors portée." % [_number(stats.curse_damage), _number(stats.curse_damage)]
	return "Chaque attaque touche un seul ennemi."

func _recruit_tooltip(type: int, error: String) -> String:
	var lines: Array[String] = [Model.ROSTER[type].name + " · " + _recruit_role(type)]
	var stats: Dictionary = model.purchase_preview_stats(selected,type)
	if not inspection_numbers_visible:
		return "" if error.is_empty() else "Achat impossible : " + error
	if not stats.is_empty():
		lines.append("Valeurs prévues à cet emplacement, bonus et synergies actuels inclus.")
		lines.append("%s dégâts directs · Une attaque toutes les %s s · Portée : %s" % [_number(stats.damage),_number(stats.interval),_number(stats.range)])
		lines.append(_recruit_effect(stats,type))
		if type in [2,3,4]: lines.append("%s : strictement moins de %s sur la carte." % ["Distance de rebond" if type == 3 else "Rayon de l’explosion",_number(stats.radius)])
		if type == 5: lines.append("Un nouveau tir de ce chaman renouvelle sa malédiction ; deux chamans conservent leurs effets séparés.")
		lines.append("La cible principale est l’ennemi à portée le plus avancé vers la forteresse.")
		lines.append("%d or · %d/2 exemplaires recrutés" % [model.purchase_cost(type),model.count_type(type)])
		if error.is_empty(): lines.append("Cliquez pour acheter.")
		if model.can_build(): lines.append("\n" + _preview_synergy_tooltip(selected,{"type":type,"level":1,"branch":-1}))
	if not error.is_empty(): lines.append("Achat impossible : " + error)
	return "\n".join(lines)

func _compact_damage(stats: Dictionary, type: int) -> String:
	var result: String = "Dégâts : %s" % _number(stats.damage)
	if type in [2,4]: result += " · Explosion : %s × %d autres max." % [_number(stats.secondary_damage),stats.secondary_cap]
	elif type == 3: result += " · Rebond : %s × %d max." % [_number(stats.secondary_damage),stats.secondary_cap]
	elif type == 5: result += " · Malédiction : %s après 1 s et 2 s" % _number(stats.curse_damage)
	return result

func _compact_upgrade(current: Dictionary, future: Dictionary, type: int) -> String:
	var result: String = "Dégâts : %s → %s" % [_number(current.damage),_number(future.damage)]
	if type in [2,3,4]: result += " · %s : %s → %s" % ["Rebond" if type == 3 else "Explosion",_number(current.secondary_damage),_number(future.secondary_damage)]
	elif type == 5: result += " · Malédiction : %s → %s" % [_number(current.curse_damage),_number(future.curse_damage)]
	return result

func _toggle_inspection_numbers() -> void:
	if choosing_faction or pending_slot >= 0 or overview_open or summary_open or model.phase == "bonus": return
	inspection_numbers_visible = not inspection_numbers_visible
	_update_interface()
	map_view.queue_redraw()

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
	var button := LiveTooltipButton.new()
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
	if choosing_faction or pending_slot >= 0 or model.phase == "bonus" or overview_open or summary_open:
		return
	if model.phase == "finished": model.prepare_next_wave()
	if model.start():
		start_button.tooltip_quiet = start_button.is_hovered()
		autoplay_started = true
		breach_remaining = 0.0
		map_view.breach_feedback = {}
	_update_interface()

func _toggle_speed() -> void:
	if _selection_blocked(): return
	speed = COMBAT_SPEEDS[(COMBAT_SPEEDS.find(speed)+1)%COMBAT_SPEEDS.size()]
	_update_interface()

func _reset() -> void:
	if model.active or _selection_blocked():
		return
	if not choosing_faction and not _run_finished(): return
	if meta_profile != null and not choosing_faction and not _sync_meta_rewards(true):
		_update_interface();return # Ne pas détruire un résultat dont le versement n'est pas enregistré.
	inspection_numbers_visible = false
	overview_open = false
	autoplay_started = false
	countdown_wave = -1
	countdown_remaining = -1.0
	start_button.tooltip_quiet = false
	purchase_quiet_rect = Rect2()
	breach_remaining = 0.0
	map_view.breach_feedback = {}
	bonus_contexts.assign(["","",""])
	bonus_impact_keys.assign(["","",""])
	bonus_detail_index = -1
	bonus_view_context = ""
	for scroll in bonus_impact_scrollers: scroll.scroll_vertical = 0
	model.reset()
	meta_run_id = -1;meta_run_earned = 0;meta_retry_remaining = 0.0
	loadout_key = ""
	run_final_map = true;run_map_index = 0;run_map_rewards.clear()
	summary_tab = 2
	performance_rows.clear()
	report_folder = ""
	report_status.text = ""
	report_status.tooltip_text = ""
	report_button.text = "Exporter le rapport"
	report_button.tooltip_text = "Enregistrer localement les vagues, bonus proposés et décisions de cette partie."
	choosing_faction = true
	speed = 1.0
	selected = -1
	map_view.selected = -1
	_update_interface()
	map_view.queue_redraw()

func _buy(type: int) -> void:
	if choosing_faction or pending_slot >= 0 or model.phase == "bonus" or overview_open:
		return
	var purchase_rect: Rect2 = buy_buttons[type].get_global_rect()
	if model.buy(selected, model.available_types()[type]) and purchase_rect.has_point(get_global_mouse_position()):
		purchase_quiet_rect = purchase_rect
	_update_interface()
	map_view.queue_redraw()

func _refresh_purchase_quiet(pointer: Vector2) -> void:
	if purchase_quiet_rect.has_area() and not purchase_quiet_rect.has_point(pointer):
		purchase_quiet_rect = Rect2()
	var quiet: bool = purchase_quiet_rect.has_area()
	sell_button.tooltip_quiet = quiet
	upgrade_button.tooltip_quiet = quiet

func _purchase_hover(type: int, entered: bool) -> void:
	if entered: hovered_purchase = type
	elif hovered_purchase == type: hovered_purchase = -1
	_update_interface()
	map_view.queue_redraw()

func _upgrade_hover(entered: bool) -> void:
	hovered_upgrade = entered
	_update_interface()
	map_view.queue_redraw()

func _upgrade_focus(entered: bool) -> void:
	if entered: purchase_quiet_rect = Rect2()
	focused_upgrade = entered
	_update_interface()
	map_view.queue_redraw()

func _branch_hover(branch: int, entered: bool) -> void:
	if entered: hovered_branch = branch
	elif hovered_branch == branch: hovered_branch = -1
	_update_interface()
	map_view.queue_redraw()

func _branch_focus(branch: int, entered: bool) -> void:
	if entered: focused_branch = branch
	elif focused_branch == branch: focused_branch = -1
	_update_interface()
	map_view.queue_redraw()

func _comparison_text(current: Dictionary, future: Dictionary, multiline: bool = false) -> String:
	var values: Array[String] = ["Dégâts : %s → %s" % [_number(current.damage),_number(future.damage)],"Intervalle : %s → %s s" % [_number(current.interval),_number(future.interval)],"Portée : %s → %s" % [_number(current.range),_number(future.range)]]
	return ("\n" if multiline else " · ").join(values)

func _refresh_upgrade_preview() -> void:
	map_view.upgrade_preview = {}
	if choosing_faction or overview_open or not model.can_build() or selected < 0 or model.defenders[selected].is_empty():
		hovered_upgrade = false; focused_upgrade = false
		hovered_branch = -1; focused_branch = -1
		return
	var branch: int = -1
	if pending_slot >= 0:
		if pending_slot != selected or model.defenders[selected].instance_id != pending_instance: return
		branch = hovered_branch if hovered_branch >= 0 else focused_branch
		if branch < 0: return
	elif (not hovered_upgrade or purchase_quiet_rect.has_area()) and not focused_upgrade: return
	var future: Dictionary = model.upgrade_preview_stats(selected,branch)
	if future.is_empty(): return
	map_view.upgrade_preview = future
	var candidate: Dictionary = model.defenders[selected].duplicate(true)
	candidate.level += 1
	if candidate.level == 4: candidate.branch = branch
	map_view.preview_synergy_unit = candidate
	if pending_slot >= 0: return # La fenêtre compare déjà les deux branches.
	var current: Dictionary = model.get_stats(selected)
	title_label.text = "E%d · APERÇU NIVEAU %d · %s" % [selected+1,model.defenders[selected].level+1,current.name.to_upper()]
	details_label.text = _comparison_text(current,future)
	var effect: String = _effect_text(future,model.defenders[selected].type)
	if not effect.is_empty(): details_label.text += "\nAprès amélioration : " + effect
	if not inspection_numbers_visible:
		details_label.text = _compact_upgrade(current,future,model.defenders[selected].type)
		details_label.text += "\nPrix : %d or" % model.upgrade_cost(selected)
		if model.gold >= model.upgrade_cost(selected): details_label.text += " · Or restant : %d" % (model.gold-model.upgrade_cost(selected))
	var error: String = model.upgrade_error(selected)
	hint_label.text = "Aperçu sans dépense · %d or · Cliquez pour améliorer · Route bleue : portée prévue" % model.upgrade_cost(selected) if error.is_empty() else "Aperçu sans dépense · " + error
	hint_label.tooltip_text = _preview_synergy_tooltip(selected,candidate)

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
	var candidate: Dictionary = {"type":type,"level":1,"branch":-1}
	map_view.preview_synergy_unit = candidate
	title_label.text = "E%d · APERÇU AVANT ACHAT · %s · NIVEAU 1" % [selected+1, stats.name.to_upper()]
	details_label.text = "Dégâts : %s · Une attaque toutes les %s s · Portée : %s · Prix : %d or\n%s" % [_number(stats.damage),_number(stats.interval),_number(stats.range),model.purchase_cost(type),_recruit_effect(stats,type)]
	if not inspection_numbers_visible:
		details_label.text = _recruit_role(type)+" · Prix : %d or\n" % model.purchase_cost(type)+_compact_damage(stats,type)
	var error: String = model.purchase_error(selected, type)
	hint_label.text = "Aperçu sans achat · Synergies prévues : %d · Route bleue : portée · Liens pointillés : partenaires" % stats.synergies.size() if error.is_empty() else "Aperçu sans achat · " + error
	hint_label.tooltip_text = _preview_synergy_tooltip(selected,candidate)

func _sell() -> void:
	if pending_slot >= 0 or overview_open:
		return
	model.sell(selected)
	_update_interface()
	map_view.queue_redraw()

func _update_interface() -> void:
	_refresh_loadout_label()
	_refresh_home_progress()
	_refresh_purchase_quiet(get_global_mouse_position())
	_sync_countdown()
	guidance_label.text = _guidance_text()
	map_view.preview_synergy_unit = {}
	var modal: bool = meta_menu.visible or choosing_faction or pending_slot >= 0 or overview_open or summary_open or model.phase == "bonus"
	if meta_profile != null:
		var pending: int = MetaProfile.resource_total(_cleared_wave_count())+_previous_map_rewards()
		meta_progress_label.text = "Gains provisoires : %d" % pending if not _run_finished() else "Progression : sauvegarde à vérifier" if not meta_profile.error.is_empty() else "Talents : +%d ressources %s" % [meta_run_earned,"Alliance" if model.faction == 0 else "Horde"]
		meta_progress_label.tooltip_text = "Ressources versées uniquement à la fin de la partie complète : victoire finale ou défaite." if not _run_finished() else meta_profile.error if not meta_profile.error.is_empty() else "Gains de la partie enregistrés."
		meta_progress_label.mouse_filter = Control.MOUSE_FILTER_STOP
	if summary_open: _update_meta_summary()
	for control in [start_button,speed_button,reset_button,sell_button,upgrade_button,bonus_summary_button,summary_button,inspection_numbers_button]+buy_buttons:
		control.set("tooltip_blocked",modal)
		control.focus_mode = Control.FOCUS_NONE if modal else Control.FOCUS_ALL
		if modal and control.has_focus(): control.release_focus()
	var terminal: bool = model.phase in ["victory","defeat"]
	summary_button.visible = terminal
	summary_button.disabled = modal
	summary_panel.visible = summary_open
	reset_button.size.x = 112 if terminal else 234
	reset_button.text = "Rejouer" if terminal else "Nouvel essai"
	hp_label.text = "FORTERESSE   %d / %d PV" % [model.fortress_hp,model.max_hp]
	hp_label.add_theme_color_override("font_color",Color("ef9b89") if breach_remaining > 0.0 else Color("e2d5ad"))
	gold_label.text = "OR DISPONIBLE     %d" % model.gold
	faction_panel.visible = choosing_faction
	faction_label.text = "CHOIX DE FACTION" if choosing_faction else ("ALLIANCE" if model.faction == 0 else "HORDE") + "  /  VAGUE %d SUR 10" % model.wave
	specialisation_panel.visible = pending_slot >= 0
	start_button.disabled = modal or model.phase not in ["preparation","finished"]
	start_button.text = "Lancer la vague %d" % (model.wave+1 if model.phase == "finished" else model.wave) if model.phase in ["preparation","finished"] else "Vague %d en cours" % model.wave if model.active else "Partie gagnée" if model.phase == "victory" else "Choisissez un bonus" if model.phase == "bonus" else "Partie terminée"
	if countdown_remaining >= 0.0:
		start_button.text = "En pause · %d s" % ceili(countdown_remaining) if _countdown_paused() else "Vague %d dans %d s" % [model.wave+1,ceili(countdown_remaining)]
	countdown_bar.visible = countdown_remaining >= 0.0
	countdown_bar.value = maxf(0.0,countdown_remaining)
	countdown_fill.bg_color = Color("77968e") if _countdown_paused() else Color("e49a7b") if countdown_remaining <= 5.0 else Color("d0b874")
	var preview_wave: int = mini(10, model.wave+1 if model.phase == "finished" else model.wave)
	var preview: Array[String] = []
	for group in Model.Campaign.WAVES[preview_wave-1]:
		preview.append("%d %s · %s" % [group[1],Model.Enemies.for_profile(group[0],model.faction).name,"ennemi unique" if group[1] == 1 else "intervalle %s s" % _number(group[2])])
	start_button.tooltip_text = "Vague %d\n%s\n4 s entre la dernière apparition d’un groupe et la première du suivant.\nHoraires et intervalles à vitesse ×1 ; divisés par 2 en ×2 et par 10 en ×10 debug." % [preview_wave,"\n".join(preview)]
	if countdown_remaining >= 0.0:
		start_button.tooltip_text += "\nDépart automatique après le décompte. Cliquez pour lancer maintenant."
	speed_button.text = "Vitesse ×%d%s" % [int(speed)," · debug" if speed == 10.0 else ""]
	speed_button.disabled = modal
	speed_button.tooltip_text = "Alterner entre ×1, ×2 et ×10 (débogage temporaire).\nSeul le combat accélère ; les 30 secondes de préparation restent inchangées."
	reset_button.disabled = not _run_finished() or modal
	reset_button.visible = _run_finished()
	reset_button.tooltip_text = "Retour à l’accueil uniquement après la victoire finale ou la défaite. Vos ressources et vos talents permanents sont conservés."
	match model.phase:
		"preparation": status_label.text = "Préparation · Vague %d/10\n%d ennemis" % [model.wave,model.spawn_schedule.size()]
		"combat": status_label.text = "Combat · Vague %d/10\nAchats et ventes bloqués" % model.wave
		"finished": status_label.text = "Vague %d terminée\nPréparez la vague %d" % [model.wave,model.wave+1]
		"bonus": status_label.text = "Vague %d terminée\nChoix roguelite obligatoire" % model.wave
		"victory": status_label.text = "VICTOIRE · Dix vagues\nLa forteresse a survécu" if _run_finished() else "Carte terminée\nLa partie continue"
		"defeat": status_label.text = "Forteresse détruite\nRelancez un nouvel essai"
	if countdown_remaining >= 0.0:
		status_label.text = "Vague %d terminée\n%s" % [model.wave,"Décompte suspendu" if _countdown_paused() else "Préparation : %d s" % ceili(countdown_remaining)]
	bonus_summary_button.text = "Bonus acquis · %d/3" % model.bonuses.size()
	bonus_summary_button.disabled = modal
	_update_bonus_panel()
	tally_label.text = "Apparus : %d / %d\nÉliminés : %d · Passés : %d\nEn chemin : %d" % [model.spawned, model.spawn_schedule.size(), model.killed, model.escaped, model.enemies.size()]
	time_label.text = ("Combat simulé : %.1f s" % (model.completed_time+model.elapsed)).replace(".", ",")
	hint_label.text = "Sélectionnez E1 à E6 (clic ou touches 1–6) pour construire ou inspecter."
	var occupied: bool = selected >= 0 and not model.defenders[selected].is_empty()
	inspection_numbers_button.visible = selected >= 0
	inspection_numbers_button.disabled = modal
	inspection_numbers_button.text = "Vue simplifiée" if inspection_numbers_visible else "Voir les chiffres"
	details_label.add_theme_font_size_override("font_size",14 if inspection_numbers_visible else 16)
	sell_button.visible = occupied
	sell_button.disabled = modal or not model.can_build()
	upgrade_button.visible = occupied
	for type in range(buy_buttons.size()):
		var button: Button = buy_buttons[type]
		var actual_type: int = model.available_types()[type]
		var offer: Dictionary = Model.ROSTER[actual_type]
		button.visible = not occupied
		button.text = "%s · %d or  (%d/2)" % [offer.get("short_name", offer.name), model.purchase_cost(actual_type), model.count_type(actual_type)]
		var purchase_error: String = model.purchase_error(selected, actual_type)
		button.tooltip_text = _recruit_tooltip(actual_type,purchase_error)
		button.disabled = modal or not purchase_error.is_empty()
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
		if not inspection_numbers_visible:
			details_label.text = (_specialisation_pitch(defender.type,defender.branch) if defender.level == 4 else _recruit_role(defender.type))+"\n"+_compact_damage(stats,defender.type)
		upgrade_button.text = "Niveau maximum" if defender.level == 4 else "Spécialisation · %d or" % model.upgrade_cost(selected) if defender.level == 3 else "Niveau %d · %d or" % [defender.level + 1, model.upgrade_cost(selected)]
		var improvement_error: String = model.upgrade_error(selected, 0 if defender.level == 3 else -1)
		upgrade_button.tooltip_text = _upgrade_tooltip(selected,improvement_error)
		upgrade_button.disabled = modal or not improvement_error.is_empty()
		sell_button.text = "Vendre · %d or" % model.refund(selected)
		sell_button.tooltip_text = "Vous récupérez %d or sur les %d or investis.\nPerte à la vente : %d or.\nOr disponible après vente : %d.\nLe défenseur est retiré de cet emplacement." % [model.refund(selected),defender.paid,defender.paid-model.refund(selected),model.gold+model.refund(selected)]
		if not model.can_build(): sell_button.tooltip_text += "\nVente possible uniquement entre les vagues."
	else:
		title_label.text = "E%d · EMPLACEMENT LIBRE" % (selected + 1)
		details_label.text = "Un défenseur par emplacement · Deux exemplaires maximum par type.\nSurvolez les recrues pour comparer leurs attaques et leur portée."
		if model.can_build(): hint_label.text = "Survolez un défenseur pour voir sa portée avant l’achat."
	if model.active:
		hint_label.text = "Les tirs sont automatiques. Vous pouvez inspecter les unités et changer la vitesse."
	elif model.phase == "finished":
		hint_label.text = "Achats, améliorations et ventes autorisés avant la vague suivante."
	if occupied:
		var effects: Dictionary = model.get_stats(selected)
		hint_label.text = "Synergies actives : %d · Partenaires reliés sur la carte · Survolez pour les détails" % effects.synergies.size() if not effects.synergies.is_empty() else "Aucune synergie active · Survolez pour voir les associations possibles"
		hint_label.tooltip_text = _synergy_tooltip(selected)
		hint_label.tooltip_text += "\nChemin doré : portions à portée du défenseur sélectionné."
	else:
		hint_label.tooltip_text = ""
	if model.phase in ["victory","defeat"]:
		hint_label.text = "%d éliminés · %d passés · %d or gagnés · Survolez pour les synergies" % [model.total_killed,model.total_escaped,model.total_income] if occupied else "%d éliminés · %d passés · %d or gagnés au combat." % [model.total_killed,model.total_escaped,model.total_income]
	_refresh_purchase_preview()
	_refresh_upgrade_preview()
	_update_enemy_inspector()
	_update_wave_forecast()
	_update_boss_status()
	_sync_keyboard_focus()

func _guidance_text() -> String:
	if model.phase == "victory" and not _run_finished(): return "Carte remportée. La partie continue ; ressources et talents restent en attente."
	if choosing_faction:
		return "Choisissez votre faction.\nChaque camp a ses défenseurs.\nLa première vague attendra."
	if pending_slot >= 0:
		return "Préparation en pause.\nChoisissez une spécialisation\nou annulez sans dépenser."
	if overview_open and model.can_build():
		return "Préparation en pause.\nFermez le récapitulatif pour\nreprendre votre préparation."
	if overview_open and model.active:
		return "Le combat continue.\nLisez vos bonus, puis fermez\nle panneau pour revenir au jeu."
	match model.phase:
		"preparation":
			return "Installez votre défense,\npuis lancez la première vague.\nEnsuite : 30 s entre les vagues." if model.wave == 1 else "La prochaine vague attend.\nAjustez vos défenseurs, puis\nlancez la vague suivante."
		"combat":
			return "Vos unités attaquent seules.\nInspectez unités et ennemis\nou changez la vitesse."
		"finished":
			return "La vague suivante part seule.\nAchetez, améliorez ou vendez\navant la fin du décompte." if countdown_remaining >= 0.0 else "Préparez la prochaine vague.\nAchetez, améliorez ou vendez,\npuis lancez la vague suivante."
		"bonus":
			return "Le jeu attend votre choix.\nChoisissez un bonus pour avoir\n30 s de préparation."
		"victory":
			return "La forteresse a tenu !\nConsultez le bilan de partie\nou tentez une autre stratégie."
		"defeat":
			return "La forteresse est détruite.\nLe bilan détaille les vagues.\nRejouez pour changer de plan."
	return "Préparez votre défense.\nInspectez vos unités pour\ncomparer leurs améliorations."

func _sync_keyboard_focus() -> void:
	if meta_menu.visible: return
	if syncing_keyboard_focus: return
	var context: String = ""
	var target: Button
	if choosing_faction:
		context = "faction"; target = faction_buttons[0]
	elif pending_slot >= 0:
		context = "specialisation:%d:%d" % [pending_slot,pending_instance]; target = specialisation_cancel
	elif model.phase == "bonus":
		context = "bonus:%d:%d:%d" % [model.faction,model.wave,bonus_detail_index]
		if bonus_detail_index >= 0: target = bonus_details_back
		elif not model.bonus_offer.is_empty(): target = bonus_buttons[0]
	elif overview_open:
		context = "overview:%d" % bonus_detail_index
		target = bonus_details_back if bonus_detail_index >= 0 else bonus_close
	elif summary_open:
		context = "summary"; target = summary_close
	else:
		target = start_button if not start_button.disabled else bonus_summary_button
	var current: Control = get_viewport().gui_get_focus_owner()
	if context == keyboard_focus_context and current != null and current.is_visible_in_tree() and (not current is BaseButton or not current.disabled): return
	keyboard_focus_context = context
	if target == null or not target.is_visible_in_tree() or target.disabled: return
	syncing_keyboard_focus = true
	target.grab_focus()
	syncing_keyboard_focus = false

func _synergy_gain_text(type: int, rule: Dictionary, side: int) -> String:
	var gains: Array[String] = []
	for i in range(4):
		var gain: float = rule.effects[side][i]
		if gain > 0 and (i != 1 or Model.ROSTER[type].has("secondary_damage")) and (i != 2 or Model.ROSTER[type].has("curse_damage")):
			gains.append("+%s %s" % [_number(gain if i == 3 else gain*100), ["% aux dégâts directs", "% aux dégâts des rebonds" if type == 3 else "% aux dégâts des explosions", "% aux dégâts de malédiction", "de portée"][i]])
	return ", ".join(gains)

func _preview_synergy_tooltip(slot: int, candidate: Dictionary) -> String:
	var type: int = candidate.type
	var lines: Array[String] = ["SYNERGIES PRÉVUES · " + Model.ROSTER[type].name,"Liens bleus pointillés : partenaires après confirmation."]
	var count: int = 0
	for rule in Model.Campaign.PROXIMITY + Model.Campaign.SPECIALISATIONS:
		var side: int = rule.types.find(type)
		if side < 0: continue
		var partners: Array[int] = model.synergy_partners(slot,rule,-1,candidate)
		if partners.is_empty(): continue
		count += 1
		var names: Array[String] = []
		for partner in partners: names.append("E%d · %s" % [partner+1,Model.ROSTER[model.defenders[partner].type].name])
		lines.append("\n%s avec %s" % ["Spécialisation" if rule.has("branches") else "Proximité"," ; ".join(names)])
		lines.append("Pour cette unité : " + _synergy_gain_text(type,rule,side))
	if count == 0: lines.append("\nAucune synergie avec votre défense actuelle pour ce choix.")
	lines.append("\nLes statistiques de l’aperçu incluent déjà ces effets.\nPlusieurs partenaires ne multiplient pas un même bonus.\nAucun achat ni changement avant confirmation.")
	return "\n".join(lines)

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
		descriptions.append("Pour cette unité : " + _synergy_gain_text(type,rule,side))
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
	return ("%.2f" % value).trim_suffix("0").trim_suffix("0").trim_suffix(".").replace(".", ",")

func _upgrade_tooltip(slot: int, error: String) -> String:
	var defender: Dictionary = model.defenders[slot]
	if defender.level >= 4: return "Niveau maximum atteint."
	if not inspection_numbers_visible:
		if not error.is_empty(): return "Amélioration impossible : " + error
		return "Choisissez une spécialisation ; aucun paiement avant confirmation." if defender.level == 3 else ""
	var cost: int = model.upgrade_cost(slot)
	var lines: Array[String] = ["Spécialisation au niveau 4" if defender.level == 3 else "Passage au niveau %d" % (defender.level+1),"Prix : %d or" % cost]
	if model.gold >= cost: lines.append("Or disponible après amélioration : %d." % (model.gold-cost))
	lines.append("Total investi après amélioration : %d or." % (defender.paid+cost))
	if defender.level == 3: lines.append("Choisissez l’une des deux branches. Aucun paiement avant confirmation.")
	if not error.is_empty(): lines.append("Amélioration impossible : " + error)
	return "\n".join(lines)

func _build_bonus_selector(screen: Control) -> void:
	bonus_panel = ColorRect.new()
	bonus_panel.color = Color(0.02,0.04,0.035,0.96)
	bonus_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(bonus_panel)
	var panel: Panel = _panel(bonus_panel,Rect2(100,166,1080,468))
	bonus_body = panel
	bonus_title = _label(panel,"",Vector2(28,24),Vector2(1024,40),26,Color("e0dbbf"))
	bonus_subtitle = _label(panel,"",Vector2(28,78),Vector2(1024,46),15,Color("aabbb0"))
	bonus_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for index in range(3):
		var x: int = 28+index*348
		bonus_cards.append(_panel(panel,Rect2(x,126,328,464)))
		bonus_names.append(_label(panel,"",Vector2(x,148),Vector2(328,54),18,Color("e0dbbf")))
		bonus_names[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bonus_effects.append(_label(panel,"",Vector2(x+18,218),Vector2(292,78),25,Color("e6c987")))
		bonus_scopes.append(_label(panel,"",Vector2(x+18,310),Vector2(292,60),16,Color("e0e7db")))
		bonus_notes.append(_label(panel,"",Vector2(x+18,382),Vector2(292,72),14,Color("aabbb0")))
		for label in [bonus_effects[-1],bonus_scopes[-1],bonus_notes[-1]]: label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bonus_detail_buttons.append(_button(panel,"Voir les détails",Rect2(x+18,468,292,36),_open_bonus_details.bind(index)))
		bonus_descriptions.append(_label(panel,"",Vector2(x,216),Vector2(320,108),16,Color("bbcbbf")))
		bonus_descriptions[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bonus_impact_titles.append(_label(panel,"Avec votre défense actuelle",Vector2(x,318),Vector2(328,24),14,Color("cdb47e")))
		var scroll := ScrollContainer.new()
		scroll.position = Vector2(x,346)
		scroll.size = Vector2(328,168)
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		panel.add_child(scroll)
		bonus_impact_scrollers.append(scroll)
		var impact := Label.new()
		impact.custom_minimum_size.x = 302
		impact.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		impact.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		impact.add_theme_font_size_override("font_size",13)
		impact.add_theme_color_override("font_color",Color("bbcbbf"))
		scroll.add_child(impact)
		bonus_impacts.append(impact)
		bonus_buttons.append(_button(panel,"Choisir ce bonus",Rect2(x+18,532,292,48),_choose_bonus.bind(index)))
	bonus_close = _button(panel,"Fermer · Échap",Rect2(442,408,196,36),_close_bonuses)
	bonus_details_back = _button(panel,"Retour · Échap",Rect2(28,532,240,48),_close_bonus_details)

func _show_bonuses() -> void:
	if choosing_faction or pending_slot >= 0 or model.phase == "bonus" or summary_open: return
	overview_open = true
	bonus_detail_index = -1
	_update_interface()

func _close_bonuses() -> void:
	overview_open = false
	bonus_detail_index = -1
	_update_interface()

func _open_bonus_details(index: int) -> void:
	if not bonus_panel.visible: return
	var entries: Array[int] = model.bonus_offer if model.phase == "bonus" else model.bonuses
	if index < 0 or index >= entries.size(): return
	bonus_detail_index = index
	_update_interface()

func _close_bonus_details() -> void:
	var previous: int = bonus_detail_index
	bonus_detail_index = -1
	_update_interface()
	if previous >= 0 and previous < bonus_detail_buttons.size() and bonus_detail_buttons[previous].is_visible_in_tree():
		bonus_detail_buttons[previous].grab_focus()

func _choose_bonus(index: int) -> void:
	if model.phase != "bonus" or index < 0 or index >= model.bonus_offer.size(): return
	if bonus_detail_index >= 0 and bonus_detail_index != index: return
	model.choose_bonus(model.bonus_offer[index])
	bonus_detail_index = -1
	_update_interface()
	map_view.queue_redraw()

func _update_bonus_panel() -> void:
	var choosing: bool = model.phase == "bonus"
	bonus_panel.visible = choosing or overview_open
	if not bonus_panel.visible:
		bonus_detail_index = -1
		bonus_view_context = ""
		return
	var entries: Array[int] = model.bonus_offer if choosing else model.bonuses
	var view_context: String = JSON.stringify([choosing,model.faction,model.wave,entries])
	if view_context != bonus_view_context: bonus_detail_index = -1
	bonus_view_context = view_context
	var detailed: bool = bonus_detail_index >= 0 and bonus_detail_index < entries.size()
	bonus_body.position.y = 95 if choosing or detailed else 166
	bonus_body.size.y = 610 if choosing or detailed else 468
	bonus_title.text = Model.Campaign.BONUSES[entries[bonus_detail_index]].name if detailed else "Choisissez un bonus" if choosing else "Vos bonus de partie"
	bonus_subtitle.text = "Règle complète et effet sur votre défense." if detailed and choosing else "Ce bonus reste actif pour cette partie." if detailed else "Vague %d terminée · Prenez votre temps. Après le choix : 30 s de préparation." % model.wave if choosing else "Aucun bonus acquis." if entries.is_empty() else "Actifs jusqu’à la fin de cette partie."
	# Le choix suspend le combat ; recalculer uniquement si une donnée d’aperçu change.
	var impact_key: String = JSON.stringify([model.faction,model.wave,model.bonus_offer,model.bonuses,model.defenders,model.gold,model.fortress_hp,model.max_hp,model.synergies_enabled]) if choosing else ""
	for index in range(3):
		var x: int = 28+index*348
		var listed: bool = index < entries.size() and not detailed
		var selected_detail: bool = detailed and index == bonus_detail_index
		bonus_cards[index].visible = listed
		bonus_cards[index].size.y = 464 if choosing else 250
		bonus_names[index].visible = listed
		bonus_names[index].position = Vector2(x+18,148)
		bonus_names[index].size = Vector2(292,56)
		bonus_names[index].add_theme_font_size_override("font_size",20)
		bonus_effects[index].visible = listed
		bonus_effects[index].position.y = 218 if choosing else 210
		bonus_effects[index].size.y = 78 if choosing else 54
		bonus_effects[index].add_theme_font_size_override("font_size",25 if choosing else 21)
		bonus_scopes[index].visible = listed
		bonus_scopes[index].position.y = 310 if choosing else 270
		bonus_scopes[index].size.y = 60 if choosing else 48
		bonus_notes[index].visible = listed and choosing
		bonus_detail_buttons[index].visible = listed
		bonus_detail_buttons[index].position.y = 468 if choosing else 330
		bonus_descriptions[index].visible = selected_detail
		bonus_descriptions[index].position = Vector2(28,96)
		bonus_descriptions[index].size = Vector2(1024,88)
		bonus_descriptions[index].add_theme_font_size_override("font_size",18)
		bonus_impact_titles[index].visible = selected_detail
		bonus_impact_titles[index].position = Vector2(28,202)
		bonus_impact_titles[index].text = "Avec votre défense actuelle" if choosing else "Bénéficiaires"
		bonus_impact_scrollers[index].visible = selected_detail
		bonus_impact_scrollers[index].position = Vector2(28,240)
		bonus_impact_scrollers[index].size = Vector2(1024,250)
		bonus_impacts[index].custom_minimum_size.x = 994
		bonus_impacts[index].add_theme_font_size_override("font_size",15)
		bonus_buttons[index].visible = choosing and (listed or selected_detail)
		bonus_buttons[index].position = Vector2(768,532) if selected_detail else Vector2(x+18,532)
		if index < entries.size():
			var data: Dictionary = Model.Campaign.BONUSES[entries[index]]
			var card: Dictionary = _bonus_card_content(entries[index])
			bonus_names[index].text = data.name
			bonus_effects[index].text = card.effect
			bonus_scopes[index].text = card.scope
			bonus_notes[index].text = _bonus_audience_text(entries[index])+"\n"+card.note
			bonus_descriptions[index].text = Model.Campaign.bonus_description(entries[index],model.faction)
			if choosing and bonus_impact_keys[index] != impact_key:
				var impact_text: String = _bonus_impact_text(entries[index])
				var context: String = "%d:%d:%d" % [model.faction,model.wave,entries[index]]
				if bonus_impacts[index].text != impact_text or bonus_contexts[index] != context:
					bonus_impacts[index].text = impact_text
					bonus_impact_scrollers[index].scroll_vertical = 0
					bonus_contexts[index] = context
				bonus_impact_keys[index] = impact_key
			elif not choosing:
				bonus_impacts[index].text = card.scope+"\n\n"+_bonus_audience_text(entries[index])+"\n"+card.note
	bonus_close.visible = not choosing and not detailed
	bonus_details_back.visible = detailed

func _bonus_audience_text(code: int) -> String:
	if code == 8: return "Effet immédiat."
	if code in [9,10]: return "Pour vos prochains achats."
	var count: int = 0
	for unit in model.defenders:
		if unit.is_empty() or unit.type not in model.available_types(): continue
		if code == 1 and unit.type == 5: continue
		if code in [3,4] and unit.type not in [2,3,4]: continue
		if code == 6 and unit.level > 2: continue
		if code == 7 and unit.level < 3: continue
		count += 1
	return "Aucun défenseur actuel concerné." if count == 0 else "%d défenseur%s concerné%s actuellement." % [count,"s" if count > 1 else "","s" if count > 1 else ""]

func _bonus_card_content(code: int) -> Dictionary:
	var alliance: bool = model.faction == 0
	match code:
		0: return {"effect":"+10 % à tous les dégâts","scope":"Tous vos défenseurs.","note":"Actuels et futurs."}
		1: return {"effect":"Tirs 12 % plus rapides","scope":"Archers, arbalétriers et mages." if alliance else "Lanceurs de haches et sapeurs.","note":"Spécialisations incluses."}
		2: return {"effect":"Portée +0,5","scope":"Tous vos défenseurs.","note":"Le cercle d’attaque s’agrandit."}
		3: return {"effect":"Dégâts d’explosion +20 %" if alliance else "Dégâts rebonds et\nexplosions +20 %","scope":"Vos mages." if alliance else "Lanceurs de haches et sapeurs.","note":"Tirs directs inchangés."}
		4: return {"effect":"Rayon d’explosion +0,2" if alliance else "Explosions / rebonds\n+0,2 de distance","scope":"Vos mages." if alliance else "Lanceurs de haches et sapeurs.","note":"Maximum de cibles inchangé."}
		5: return {"effect":"Dégâts des tirs +15 %","scope":"Tous vos défenseurs.","note":"Explosions inchangées." if alliance else "Rebonds, explosions et malédictions inchangés."}
		6: return {"effect":"Dégâts +15 %","scope":"Défenseurs de niveau 1 ou 2.","note":"Le gain cesse au niveau 3."}
		7: return {"effect":"Dégâts +12 %","scope":"Défenseurs de niveau 3 ou 4.","note":"Actuels et futurs."}
		8: return {"effect":"+4 PV actuels et maximum","scope":"Votre forteresse.","note":"Sans régénération automatique."}
		9: return {"effect":"Améliorations −10 %","scope":"Prochaines améliorations et spécialisations.","note":"Achats passés inchangés."}
		10: return {"effect":"Recrutement −10 %","scope":"Vos prochaines recrues.","note":"Achats passés inchangés."}
		11: return {"effect":"Dégâts +20 %","scope":"Ours, unités lourdes, gardes d’élite et boss.","note":"Priorité des cibles inchangée."}
	return {"effect":"","scope":"","note":""}

func _bonus_impact_text(code: int) -> String:
	var preview: Dictionary = model.bonus_preview(code)
	if preview.is_empty(): return "Ce bonus est déjà actif."
	if code == 8:
		return "PV actuels : %d → %d\nPV maximum : %d → %d\n\nEffet immédiat, sans soin automatique ensuite." % [preview.hp_before,preview.hp_after,preview.max_before,preview.max_after]
	var lines: Array[String] = []
	if code == 9:
		lines.append("Prochaines améliorations uniquement :")
		for index in range(3):
			lines.append("%s : %d → %d or" % [["Niveau 2","Niveau 3","Spécialisation"][index],preview.upgrades[index].before,preview.upgrades[index].after])
		lines.append("Aucun remboursement des achats passés.")
		return "\n".join(lines)
	if code == 10:
		for purchase in preview.purchases:
			lines.append("%s :\n%d → %d or" % [Model.ROSTER[purchase.type].get("short_name",Model.ROSTER[purchase.type].name),purchase.before,purchase.after])
		lines.append("Prochaines recrues uniquement.")
		return "\n".join(lines)
	if code == 11: lines.append("Cibles uniquement : " + Model.Enemies.robust_names(model.faction) + ".")
	var affected: int = 0
	for unit in preview.units:
		var changes: Array[String] = []
		if code == 11:
			for component in ["direct","secondary","curse"]:
				if not is_equal_approx(unit.large_before[component],unit.large_after[component]):
					changes.append("%s : %s → %s" % [{"direct":"Dégâts directs","secondary":"Rebonds" if unit.type == 3 else "Explosion","curse":"Malédiction"}[component],_number(unit.large_before[component]),_number(unit.large_after[component])])
		else:
			for field in ["damage","secondary_damage","curse_damage","interval","range","radius"]:
				if not is_equal_approx(unit.before[field],unit.after[field]):
					var label: String = {"damage":"Dégâts directs","secondary_damage":"Rebonds" if unit.type == 3 else "Explosion","curse_damage":"Malédiction","interval":"Intervalle (s)","range":"Portée","radius":"Distance de rebond" if unit.type == 3 else "Rayon d’explosion"}[field]
					changes.append("%s : %s → %s" % [label,_number(unit.before[field]),_number(unit.after[field])])
		if changes.is_empty(): continue
		affected += 1
		lines.append("E%d · %s\n%s" % [unit.slot+1,Model.ROSTER[unit.type].get("short_name",Model.ROSTER[unit.type].name),"\n".join(changes)])
	if affected == 0:
		lines.append("Aucun défenseur actuel concerné.\nPeut servir aux futures recrues selon ses conditions.")
	return "\n\n".join(lines)
