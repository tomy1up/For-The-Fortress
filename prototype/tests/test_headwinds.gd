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
			if model.phase=="bonus": model.choose_bonus(model.bonus_offer[0])
			model.prepare_next_wave();model.start();model.advance(10000)
		var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
		check(report.has("combat_affix")==not affix.is_empty(),"Seuls les nouveaux combats affectés enregistrent un affixe")
		check(Replay.verify(report).ok,"Rapport avec ou sans affixe rejouable")
		if not affix.is_empty():
			check(Report.markdown(report).contains("−10 %"),"Rapport lisible avec le dosage de l'affixe")
			report.combat_affix.cadence_percent = "90"
			check(not Replay.verify(report).ok,"Rapport contenant un affixe invalide refusé")
	for case in [[0,31],[1,31],[0,32],[1,32],[0,33],[1,33]]:
		var camp: int = case[0]
		var mission: int = case[1]
		var game := Main.new()
		root.add_child(game);game.set_process(false)
		var profile := Profile.new("")
		game.meta_profile = profile
		game._open_campaign(camp,4)
		game.campaign_menu._select(mission-31)
		check(game.campaign_menu.start_button.disabled and game.campaign_menu.mission_detail.text.contains("−10 %"),"Affixe expliqué avant le déblocage de la mission")
		for number in range(1,mission):
			var run: int = profile.begin_mission(camp,Main.CampaignCatalogue.id_for(number),60,10,100)
			check(profile.credit_mission(run,camp,10,true),"Préparation du parcours isolé")
		var first: int = 5 if camp==0 else 0
		if camp==1 and mission==32: first = 10
		var tree: int = Talents.coordinates(first).x
		for index in [first,first,first,first,first,Talents.index_for(tree,1)]:
			check(profile.allocate(camp,index),"Talents de départ financés par les missions préalables")
		while Model.MetaTalents.spent(profile.data.banks[camp].ranks)<profile.data.banks[camp].points:
			var allocated := false
			for local in range(21):
				var index: int = Talents.index_for(tree,local)
				if profile.allocate(camp,index):
					allocated = true
					break
			check(allocated,"Répartition des seuls points gagnés avant cette mission")
			if not allocated: break
		game._open_campaign(camp,4)
		game.campaign_menu._select(mission-31)
		check(not game.campaign_menu.start_button.disabled,"Mission accessible après sa précédente")
		game.campaign_menu._launch()
		check(game.model.combat_affix==AFFIX and game.model.enemy_hp_percent==99+mission and game.model.gold==150,"Affixe appliqué par le lancement réel de campagne")
		check(game.affix_label.visible and game.affix_label.text.contains("−10 %"),"Affixe visible pendant la préparation")
		var model = game.model
		model.rng.seed = 7
		var types: Array = [0,1,2] if camp==0 else [3,3,5]
		if mission==32: types = [0,0,2] if camp==0 else [4,4,3]
		var slots := [3,4,2]
		var army_slots: Array = slots.duplicate()
		if camp==1 and mission==32: army_slots.append(0)
		check(model.buy(slots[0],types[0]) and model.buy(slots[1],types[1]),"Défense initiale dans le budget normal")
		for wave in range(1,11):
			if wave==2: model.upgrade(slots[0])
			if wave>=2 and model.defenders[slots[2]].is_empty(): model.buy(slots[2],types[2])
			if camp==1 and mission==32 and wave>=3 and model.defenders[0].is_empty(): model.buy(0,3)
			if wave>=5:
				for slot in army_slots:
					if not model.defenders[slot].is_empty(): model.upgrade(slot,0 if model.defenders[slot].level==3 else -1)
			check(model.start(),"Départ d'une vague sous Vents contraires")
			model.advance(10000)
			if model.phase=="defeat": break
			if model.phase=="bonus": model.choose_bonus(model.bonus_offer[0])
			if wave<10: model.prepare_next_wave()
		check(model.phase=="victory","Victoire avec les ressources et talents normalement accessibles")
		var spent := 0
		for action in model.action_history:
			if action.kind in ["buy","upgrade"]: spent += int(action.cost)
		check(model.gold==150+model.total_income-spent and model.gold>=0,"Tous les recrutements et améliorations sont financés par les revenus du combat")
		if camp==1 and mission==32:
			check(model.defenders.filter(func(unit):return not unit.is_empty()).size()==4 and model.defenders.filter(func(unit):return unit.get("type",-1)==3).size()==2 and model.defenders.filter(func(unit):return unit.get("type",-1)==4).size()==2,"Défense à quatre unités conforme à la limite de deux exemplaires par type")
		check(Replay.verify(JSON.parse_string(JSON.stringify(Report.build(model)))).ok,"Rapport complet de mission affectée rejouable")
		game._sync_meta_rewards(true);game._sync_meta_rewards(true);game._update_interface()
		check(profile.campaign_status(camp).completed==mission and profile.data.banks[camp].xp==100*mission and profile.data.banks[camp].resource==60*mission,"Crédit unique de première victoire")
		check(profile.data.banks[camp].points==Profile.Experience.points_for_xp(100*mission),"Points de talents acquis selon la courbe d'XP de la faction")
		check(game.affix_label.visible,"Affixe reste affiché en fin de combat")
		check(profile.campaign_status(1-camp).completed==0,"Le parcours adverse reste indépendant")
		if model.phase=="victory":
			game._show_run_summary();game._summary_to_campaign()
			check(game.choosing_faction and game.campaign_menu.visible,"Retour réel au parcours après le bilan")
			game.campaign_menu._chapter(3);game.campaign_menu._select(0);game.campaign_menu._launch()
			check(not game.choosing_faction and game.mission_definition.id=="campaign.021" and game.model.combat_affix.is_empty() and not game.affix_label.visible,"Rejouer une mission antérieure ne conserve aucun vent ni son annonce")
			var candidate := {"type":camp*3,"level":1,"branch":-1}
			var actual: Dictionary = game.model.get_stats(0,-1,candidate)
			check(is_equal_approx(actual.interval,Model.ROSTER[camp*3].interval),"La cadence d'origine est restaurée sans modifier les talents")
		game.free()
	print("HEADWINDS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
