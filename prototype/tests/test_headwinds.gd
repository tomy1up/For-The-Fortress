extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
const Talents = preload("res://scripts/meta_talents_linked.gd")
const AFFIX = {"id":"headwinds","cadence_percent":90}
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	var control := Model.new()
	var wind := Model.new()
	var supplied := AFFIX.duplicate()
	check(wind.configure_combat_affix(supplied),"Affixe appliqué avant la mission")
	supplied.cadence_percent = 1
	check(wind.combat_affix.cadence_percent==90,"Configuration copiée indépendamment de son appelant")
	for invalid in [null,90,[],{"id":"unknown","cadence_percent":90},{"id":"headwinds"},{"id":"headwinds","cadence_percent":true},{"id":"headwinds","cadence_percent":90.5},{"id":"headwinds","cadence_percent":0},{"id":"headwinds","cadence_percent":101},{"id":"headwinds","cadence_percent":INF},{"id":"headwinds","cadence_percent":90,"extra":1}]:
		check(not wind.configure_combat_affix(invalid) and wind.combat_affix==AFFIX,"Affixe invalide refusé sans modifier le réglage")
	for type in range(Model.ROSTER.size()):
		control.faction = 0 if type in [0,1,2,6,7] else 1
		wind.faction = control.faction
		for level in range(1,5):
			for branch in ([0,1] if level==4 else [-1]):
				for bonus in [[],[1]]:
					control.bonuses.assign(bonus);wind.bonuses.assign(bonus)
					var candidate := {"type":type,"level":level,"branch":branch}
					var normal: Dictionary = control.get_stats(0,-1,candidate)
					var affected: Dictionary = wind.get_stats(0,-1,candidate)
					check(is_equal_approx(affected.interval,normal.interval/0.9),"Cadence réduite aussi en aperçu, avec bonus et spécialisations")
					affected.interval = normal.interval
					check(affected==normal,"Dégâts, portée et effets secondaires restent identiques")
	control.elapsed = 2.0;wind.elapsed = 2.0
	control._apply_curse(1,0,4.8);wind._apply_curse(1,0,4.8)
	check(control.curses==wind.curses and wind.curses[0].next_at==3.0,"Malédiction déjà appliquée inchangée en dégâts et échéance")
	wind.bonuses.clear()
	check(wind.select_faction(1) and not wind.configure_combat_affix({}),"Affixe verrouillé dès le choix de faction")
	for affix in [{},AFFIX]:
		var model := Model.new()
		check(model.configure_combat_affix(affix) and model.select_faction(0),"Combat de référence initialisé")
		check(model.start(),"Vague démarrée")
		model.advance(10000)
		while model.phase != "defeat":
			if model.phase=="bonus": model.choose_bonus(Model.reference_bonus(model.bonus_offer))
			model.prepare_next_wave();model.start();model.advance(10000)
		var report: Dictionary = _report(model)
		check(report.has("combat_affix")==not affix.is_empty(),"Seuls les nouveaux combats affectés enregistrent un affixe")
		check(Replay.verify(report).ok,"Rapport avec ou sans affixe rejouable")
		if not affix.is_empty():
			check(Report.markdown(report).contains("−10 %"),"Rapport lisible avec le dosage de l'affixe")
			report.combat_affix.cadence_percent = "90"
			check(not Replay.verify(report).ok,"Rapport contenant un affixe invalide refusé")
	for case in [[0,31],[1,31],[0,32],[1,32],[0,33],[1,33],[0,34],[1,34],[0,35],[1,35],[0,36],[1,36],[0,37],[1,37],[0,38],[1,38],[0,39],[1,39],[0,40],[1,40]]:
		var camp: int = case[0]
		var mission: int = case[1]
		var game := Main.new()
		root.add_child(game);game.set_process(false)
		var profile_path: String = "user://test_headwinds_final_%d_%d.json" % [Time.get_ticks_usec(),camp] if mission==40 else ""
		var profile := Profile.new(profile_path)
		game.meta_profile = profile
		game._open_campaign(camp,4)
		game.campaign_menu._select(mission-31)
		check(game.campaign_menu.start_button.disabled and game.campaign_menu.mission_detail.text.contains("Vents contraires") and game.campaign_menu.mission_detail.tooltip_text.contains("10 %"),"Affixe expliqué avant le déblocage de la mission")
		for number in range(1,mission):
			var run: int = profile.begin_mission(camp,Main.CampaignCatalogue.id_for(number),60,10,100)
			check(profile.credit_mission(run,camp,10,true),"Préparation du parcours isolé")
		var first: int = 5 if camp==0 else 0
		if camp==1 and mission in [32,36,37]: first = 10
		var tree: int = Talents.coordinates(first).x
		for index in [first,first,first,first,first,Talents.index_for(tree,1)]:
			check(profile.allocate(camp,index),"Talents de départ financés par les missions préalables")
		var priority: Array = [5,7,9,16,18] if camp==1 and mission in [35,39,40] else []
		priority.append_array(range(21))
		while Model.MetaTalents.spent(profile.data.banks[camp].ranks)<profile.data.banks[camp].points:
			var allocated := false
			for local in priority:
				var index: int = Talents.index_for(tree,local)
				if profile.allocate(camp,index):
					allocated = true
					break
			check(allocated,"Répartition des seuls points gagnés avant cette mission")
			if not allocated: break
		if camp==1 and mission==35:
			check(profile.data.banks[camp].ranks[Talents.index_for(0,9)]==1 and Talents.spent(profile.data.banks[camp].ranks)==17,"Talent majeur acquis avec dix-sept points légalement gagnés")
		game._open_campaign(camp,4)
		game.campaign_menu._select(mission-31)
		check(not game.campaign_menu.start_button.disabled,"Mission accessible après sa précédente")
		game.campaign_menu._launch()
		check(game.model.combat_affix==AFFIX and game.model.enemy_hp_percent == Main.CampaignCatalogue.faction_hp_percent(mission,game.model.faction) and game.model.gold==150,"Affixe appliqué par le lancement réel de campagne")
		check(game.affix_label.visible and game.affix_label.text.contains("−10 %"),"Affixe visible pendant la préparation")
		var model = game.model
		model.rng.seed = 7
		var types: Array = [0,1,1] if camp==0 else [3,3,5]
		if mission==32: types = [1,1,0] if camp==0 else [4,4,3]
		if camp==0 and mission==33: types = [1,1,0]
		if mission==36: types = [1,1,0] if camp==0 else [4,4,3]
		if camp==1 and mission==37: types = [4,4,3]
		if camp==0 and mission==39: types = [1,1,0]
		if camp==0 and mission==40: types = [1,0,1]
		if camp==1 and mission==40: types = [3,5,4]
		var slots := [3,4,2]
		if camp==0 and mission in [32,33,34,35,36,39]: slots = [4,3,2]
		if camp==0 and mission in [31,40]: slots = [2,3,4]
		if camp==1 and mission==35: slots = [4,3,2]
		if mission==37: slots = [4,3,2]
		if mission==38: slots = [4,3,2]
		if camp==1 and mission==40: slots = [4,3,2]
		var extra: Array = [[0,3,3]] if camp==1 and mission==32 else [[0,0,3]] if camp==0 and mission in [32,33,36,39] else []
		if camp==1 and mission==40: extra = [[0,3,3]]
		var seed_value: int = 42 if camp==1 and mission==39 else 7
		play_policy(model,types,slots,extra,seed_value)
		check(model.phase=="victory","Victoire avec les ressources et talents normalement accessibles (mission %d, faction %d)" % [mission,camp])
		var spent := 0
		for action in model.action_history:
			if action.kind in ["buy","upgrade"]: spent += int(action.cost)
		check(model.gold==150+model.total_income-spent and model.gold>=0,"Tous les recrutements et améliorations sont financés par les revenus du combat")
		if camp==1 and mission==32:
			check(model.defenders.filter(func(unit):return not unit.is_empty()).size()==4 and model.defenders.filter(func(unit):return unit.get("type",-1)==3).size()==2 and model.defenders.filter(func(unit):return unit.get("type",-1)==4).size()==2,"Défense à quatre unités conforme à la limite de deux exemplaires par type")
		check(Replay.verify(_report(model)).ok,"Rapport complet de mission affectée rejouable")
		game._sync_meta_rewards(true);game._sync_meta_rewards(true);game._update_interface()
		check(profile.campaign_status(camp).completed==mission and profile.data.banks[camp].xp==100*mission and profile.data.banks[camp].resource==60*mission,"Crédit unique de première victoire")
		check(profile.data.banks[camp].points==Profile.Experience.points_for_xp(100*mission),"Points de talents acquis selon la courbe d'XP de la faction")
		check(game.affix_label.visible,"Affixe reste affiché en fin de combat")
		check(profile.campaign_status(1-camp).completed==0,"Le parcours adverse reste indépendant")
		if model.phase=="victory":
			game._show_run_summary();game._summary_to_campaign()
			check(game.choosing_faction and game.campaign_menu.visible,"Retour réel au parcours après le bilan")
			if mission==40:
				var status: Dictionary = profile.campaign_status(camp)
				check(status.chapters.slice(0,4).all(func(count):return count==10) and status.first_hundred==40 and not status.infinite_eligible,"Quatre chapitres terminés sans déblocage anticipé de l'infini")
				game.campaign_menu._chapter(4)
				check(game.campaign_menu.nodes.all(func(node):return node.state=="completed") and game.campaign_menu.start_button.text=="Rejouer sans nouveau gain","Le chapitre terminé propose le rejeu sans faux gain")
				game.campaign_menu._chapter(5)
				check(game.campaign_menu.nodes[0].state=="available" and game.campaign_menu.nodes.slice(1).all(func(node):return node.state=="locked") and not game.campaign_menu.start_button.disabled,"Les marais se débloquent après la fin du chapitre 4")
				game.campaign_menu._chapter(4);game.campaign_menu._select(9);game.campaign_menu._launch()
				check(game.model.gold==150 and game.model.bonuses.is_empty() and game.model.combat_affix==AFFIX,"Rejouer la finale repart avec les règles normales de la mission")
				play_policy(game.model,types,slots,extra,seed_value)
				check(game.model.phase=="victory","La mission finale peut être remportée une seconde fois")
				game._sync_meta_rewards(true)
				check(profile.data.banks[camp].xp==4000 and profile.data.banks[camp].resource==2400 and profile.data.banks[camp].points==20,"Le rejeu de fin de chapitre ne permet de farmer ni PO ni XP ni points")
				Profile.Codec.cache.clear()
				var reopened := Profile.new(profile_path)
				check(not reopened.blocked and reopened.campaign_status(camp).completed==40 and reopened.data.banks[camp].xp==4000 and reopened.data.banks[camp].resource==2400 and reopened.data.banks[camp].points==20 and reopened.campaign_status(1-camp).completed==0,"Fin des quatre chapitres et gains relus depuis la sauvegarde isolée")
				game._show_run_summary();game._summary_to_campaign()
			game.campaign_menu._chapter(1);game.campaign_menu._select(0);game.campaign_menu._launch()
			check(not game.choosing_faction and game.mission_definition.id=="campaign.001" and game.model.combat_affix.is_empty() and not game.affix_label.visible,"Rejouer une mission antérieure ne conserve aucun vent ni son annonce")
			var candidate := {"type":camp*3,"level":1,"branch":-1}
			var actual: Dictionary = game.model.get_stats(0,-1,candidate)
			check(is_equal_approx(actual.interval,Model.ROSTER[camp*3].interval),"La cadence d'origine est restaurée sans modifier les talents")
		game.free()
		if not profile_path.is_empty():
			for suffix in ["",".bak",".tmp"]:
				if FileAccess.file_exists(profile_path+suffix): DirAccess.remove_absolute(profile_path+suffix)
	verify_headwinds_sheet()
	print("HEADWINDS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

## Rafales au sol (v0.241, lot 208a6aa de Codex) : planche `effect.headwinds/idle` étirée sur le rectangle du plateau,
## sous le décor et les unités, pendant le combat, à la phase donnée par le temps de combat.
func verify_headwinds_sheet() -> void:
	var View = load("res://scripts/valley_view.gd")
	var Library = load("res://scripts/animation_library.gd")
	var Catalogue = load("res://scripts/campaign_catalogue.gd")
	var spec: Dictionary = Library.spec_for("effect.headwinds")
	check(not spec.is_empty() and spec.animations.has("idle"),"Planche des rafales chargée")
	var anim: Dictionary = spec.animations.idle
	check(int(anim.frames)==60 and int(anim.fps)==24 and str(anim.mode)=="time" and Vector2i(int(anim.frame_size[0]),int(anim.frame_size[1]))==Vector2i(256,140),"Rafales : 60 images de 256 × 140 à 24 par seconde")
	check(Library.sheet_size("effect.headwinds",anim)==Vector2i(15360,140),"Planche des rafales complète")
	var source: String = FileAccess.get_file_as_string("res://scripts/valley_view.gd")
	var draw_start: int = source.find("func _draw() -> void:")
	var sheet_call: int = source.find("_draw_headwinds_sheet()",draw_start)
	check(sheet_call > draw_start and sheet_call < source.find("_draw_decor_props(model.map_definition)",draw_start) and sheet_call < source.find("var actors: Array[Dictionary] = []",draw_start),"Rafales dessinées avant le décor et les unités")
	var view = View.new()
	for number in range(31,41):
		var model := Model.new(true,Model.Maps.for_id(str(Catalogue.definition(number).map_id)))
		check(model.configure_combat_affix(Catalogue.definition(number).combat_affix) and model.select_faction(number%2),"Mission %d sous Vents contraires" % number)
		view.model = model
		check(not view.headwinds_sheet_visible(),"Pas de rafales en préparation (mission %d), le bandeau reste affiché" % number)
		check(model.start() and view.headwinds_sheet_visible(),"Rafales affichées pendant le combat (mission %d)" % number)
		var board := Vector2(model.map_definition.size)
		var corners: Array = [Vector2.ZERO,Vector2(board.x,0),board,Vector2(0,board.y)].map(func(corner): return View.project(corner))
		var area: Rect2 = view.headwinds_area()
		check(corners.all(func(point: Vector2) -> bool: return area.grow(0.01).has_point(point)) and corners.any(func(point: Vector2) -> bool: return is_equal_approx(point.x,area.position.x)) and corners.any(func(point: Vector2) -> bool: return is_equal_approx(point.y,area.end.y)),"Rafales étirées sur le rectangle des quatre coins projetés (mission %d)" % number)
		for case in [[0.0,0],[1.02,24],[2.49,59],[2.52,0],[3.02,12],[10.27,6]]: # Instants au milieu des images : la frontière exacte dépend de l'arrondi.
			model.elapsed = case[0]
			check(view.headwinds_frame()==case[1],"Image des rafales donnée par le temps de combat (%.2f s, mission %d)" % [case[0],number])
		model.elapsed = 4.02
		var before: int = view.headwinds_frame()
		model.advance(0.5)
		check(view.headwinds_frame()==(before+12)%60 or model.phase!="combat","Une demi-seconde de combat avance la boucle de douze images")
	var calm := Model.new(true,Model.Maps.for_id(str(Catalogue.definition(21).map_id)))
	check(calm.select_faction(0) and calm.start(),"Mission sans affixe démarrée")
	view.model = calm
	check(not view.headwinds_sheet_visible(),"Aucune rafale sans Vents contraires")
	view.free()

func play_policy(model: RefCounted, types: Array, slots: Array, extra: Array, seed_value: int = 7) -> void:
	model.rng.seed = seed_value # Règles de bonus actuelles depuis la v0.235 (douze bonus historiques auparavant)
	var army_slots: Array = slots.duplicate()
	for recruit in extra: army_slots.append(recruit[0])
	check(model.buy(slots[0],types[0]) and model.buy(slots[1],types[1]),"Défense initiale dans le budget normal")
	for wave in range(1,11):
		if wave==2: model.upgrade(slots[0])
		if wave>=2 and model.defenders[slots[2]].is_empty(): model.buy(slots[2],types[2])
		for recruit in extra:
			if wave>=recruit[2] and model.defenders[recruit[0]].is_empty(): model.buy(recruit[0],recruit[1])
		if wave>=5:
			for slot in army_slots:
				if not model.defenders[slot].is_empty(): model.upgrade(slot,0 if model.defenders[slot].level==3 else -1)
		check(model.start(),"Départ d'une vague sous Vents contraires")
		model.advance(10000)
		if model.phase=="defeat": break
		if model.phase=="bonus": model.choose_bonus(Model.reference_bonus(model.bonus_offer))
		if wave<10: model.prepare_next_wave()

## Rapport rejouable : un modèle aux anciennes règles de tirage (douze bonus) porte la version antérieure à la 0.232.
func _report(model) -> Dictionary:
	var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
	if not model.rules_v232: report.game_version = "0.231"
	return report
